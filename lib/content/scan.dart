import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PlantScanScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const PlantScanScreen({super.key, this.onClose});

  @override
  State<PlantScanScreen> createState() => _PlantScanScreenState();
}

class _PlantScanScreenState extends State<PlantScanScreen>
    with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _cameraError = false;
  File? _selectedImage;
  String _statusMessage = 'Mengaktifkan kamera...';
  String? _debugErrorDetail;
  bool _isInitializing = false;
  bool _isTorchOn = false;

  // Ekstensi gambar yang diizinkan untuk diunggah, baik lewat galeri
  // maupun lewat file browser sistem.
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png'];

  bool _hasAllowedExtension(String path) {
    final ext = path.split('.').last.toLowerCase();
    return _allowedExtensions.contains(ext);
  }

  void _showUnsupportedFileMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hanya file JPG, JPEG, atau PNG yang diperbolehkan.'),
      ),
    );
  }

  // Menandai bahwa kita sedang membuka galeri/file picker milik sistem.
  // Selama flag ini true, perubahan lifecycle (pause/resume) yang terjadi
  // akibat membuka picker TIDAK boleh memicu dispose/reinit kamera, karena
  // itu bukan benar-benar user meninggalkan aplikasi — hanya efek samping
  // dari membuka activity/sheet sistem di atasnya.
  bool _isPickingMedia = false;

  // --- State untuk panel Pengaturan ---
  // Daftar kamera yang tersedia di perangkat (misal: belakang & depan).
  List<CameraDescription> _availableCamerasList = [];
  // Index kamera yang sedang aktif di dalam _availableCamerasList.
  int _activeCameraIndex = 0;
  // Preset resolusi yang lebih disukai user. Proses init tetap akan
  // fallback ke preset lebih rendah kalau preset ini gagal di perangkat.
  ResolutionPreset _preferredResolution = ResolutionPreset.high;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  // Menangani siklus hidup aplikasi (minimize/resume), yang sering jadi
  // penyebab kamera macet di beberapa merk HP (termasuk OPPO/ColorOS).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Abaikan event lifecycle yang dipicu oleh proses kita sendiri saat
    // membuka galeri atau file picker — bukan app benar-benar di-background.
    if (_isPickingMedia) {
      debugPrint('LIFECYCLE IGNORED: sedang membuka galeri/file picker');
      return;
    }

    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      controller.dispose();
      _cameraController = null;
      _isCameraReady = false;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  // Preset yang dicoba secara berurutan, dimulai dari preferensi user lalu
  // fallback ke preset yang lebih ringan kalau perangkat menolaknya.
  List<ResolutionPreset> _presetsToTryFrom(ResolutionPreset preferred) {
    const order = [
      ResolutionPreset.high,
      ResolutionPreset.medium,
      ResolutionPreset.low,
    ];
    final startIndex = order.indexOf(preferred);
    return order.sublist(startIndex < 0 ? 0 : startIndex);
  }

  Future<void> _initializeCamera() async {
    // Cegah pemanggilan berulang/bersamaan yang menyebabkan
    // PlatformException "A request for permissions is already running".
    if (_isInitializing) {
      debugPrint('CAMERA INIT SKIPPED: already initializing');
      return;
    }
    _isInitializing = true;

    setState(() {
      _cameraError = false;
      _isCameraReady = false;
      _statusMessage = 'Mengaktifkan kamera...';
      _debugErrorDetail = null;
      _isTorchOn = false;
    });

    try {
      PermissionStatus status = await Permission.camera.status;
      if (!status.isGranted) {
        status = await Permission.camera.request();
      }
      if (!mounted) return;

      debugPrint('CAMERA PERMISSION STATUS: $status');

      if (status.isPermanentlyDenied || status.isDenied) {
        setState(() {
          _cameraError = true;
          _statusMessage = 'Izin kamera ditolak';
          _debugErrorDetail = 'Permission status: $status';
        });
        return;
      }

      // Ambil ulang daftar kamera hanya kalau belum pernah didapat,
      // supaya index kamera yang dipilih user di pengaturan tidak berubah.
      if (_availableCamerasList.isEmpty) {
        _availableCamerasList = await availableCameras();
      }
      debugPrint('AVAILABLE CAMERAS: ${_availableCamerasList.length}');
      if (!mounted) return;

      if (_availableCamerasList.isEmpty) {
        setState(() {
          _cameraError = true;
          _statusMessage = 'Kamera tidak tersedia';
          _debugErrorDetail = 'availableCameras() returned an empty list';
        });
        return;
      }

      // Pastikan index kamera aktif masih valid (misal setelah kamera
      // eksternal dicabut), jatuhkan kembali ke kamera belakang bila perlu.
      if (_activeCameraIndex >= _availableCamerasList.length) {
        _activeCameraIndex = _availableCamerasList.indexWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
        );
        if (_activeCameraIndex < 0) _activeCameraIndex = 0;
      }

      final selectedCamera = _availableCamerasList[_activeCameraIndex];

      // Coba beberapa preset resolusi mulai dari preferensi user. Beberapa
      // HP (termasuk sebagian perangkat OPPO/ColorOS) menolak preset tinggi
      // untuk kombinasi kamera+encoder tertentu, dan itu bisa membuat
      // kamera langsung "disconnect" tanpa exception yang jelas di Flutter.
      final presetsToTry = _presetsToTryFrom(_preferredResolution);

      CameraController? workingController;
      Object? lastError;

      for (final preset in presetsToTry) {
        final controller = CameraController(
          selectedCamera,
          preset,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        try {
          debugPrint('TRYING CAMERA PRESET: $preset');
          await controller.initialize();
          workingController = controller;
          debugPrint('CAMERA INITIALIZED SUCCESSFULLY WITH PRESET: $preset');
          break;
        } catch (e, st) {
          lastError = e;
          debugPrint('CAMERA PRESET $preset FAILED: $e');
          debugPrint('STACK TRACE: $st');
          await controller.dispose();
        }
      }

      if (!mounted) {
        await workingController?.dispose();
        return;
      }

      if (workingController == null) {
        setState(() {
          _cameraError = true;
          _statusMessage = 'Gagal membuka kamera';
          _debugErrorDetail = 'Semua preset resolusi gagal. Error terakhir: $lastError';
        });
        return;
      }

      setState(() {
        _cameraController = workingController;
        _isCameraReady = true;
        _statusMessage = 'Kamera siap';
      });
    } catch (e, st) {
      debugPrint('CAMERA ERROR DETAIL: $e');
      debugPrint('STACK TRACE: $st');
      if (!mounted) return;
      setState(() {
        _cameraError = true;
        _statusMessage = 'Gagal membuka kamera';
        _debugErrorDetail = e.toString();
      });
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      setState(() => _statusMessage = 'Kamera belum siap');
      return;
    }

    try {
      final photo = await _cameraController!.takePicture();
      if (!mounted) return;

      setState(() {
        _selectedImage = File(photo.path);
        _statusMessage = 'Foto berhasil diambil';
      });
    } catch (e, st) {
      debugPrint('CAPTURE ERROR: $e');
      debugPrint('STACK TRACE: $st');
      if (!mounted) return;
      setState(() => _statusMessage = 'Gagal mengambil foto');
    }
  }

  Future<void> _pickFromGallery() async {
    // Tandai bahwa kita sedang membuka picker sistem, supaya listener
    // lifecycle di atas tidak ikut mematikan/menyalakan ulang kamera.
    _isPickingMedia = true;
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (!mounted || image == null) {
        return;
      }

      if (!_hasAllowedExtension(image.path)) {
        debugPrint('GALLERY PICK REJECTED: unsupported extension (${image.path})');
        _showUnsupportedFileMessage();
        return;
      }

      setState(() {
        _selectedImage = File(image.path);
        _statusMessage = 'File berhasil dipilih';
      });
    } catch (e, st) {
      debugPrint('GALLERY PICK ERROR: $e');
      debugPrint('STACK TRACE: $st');
      if (!mounted) return;
      setState(() => _statusMessage = 'Gagal memilih file');
    } finally {
      _isPickingMedia = false;
    }
  }

  // Membuka file browser sistem, dibatasi hanya untuk file JPG/JPEG/PNG
  // (filter diterapkan lewat FileType.custom + allowedExtensions, jadi
  // file selain itu tidak akan muncul/bisa dipilih di dialog pemilih file).
  Future<void> _pickFile() async {
    _isPickingMedia = true;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
      );

      if (!mounted || result == null || result.files.isEmpty) {
        return;
      }

      final pickedPath = result.files.single.path;
      if (pickedPath == null || !_hasAllowedExtension(pickedPath)) {
        debugPrint('FILE PICK REJECTED: unsupported extension ($pickedPath)');
        _showUnsupportedFileMessage();
        return;
      }

      setState(() {
        _selectedImage = File(pickedPath);
        _statusMessage = 'File berhasil dipilih';
      });
    } catch (e, st) {
      debugPrint('FILE PICK ERROR: $e');
      debugPrint('STACK TRACE: $st');
      if (!mounted) return;
      setState(() => _statusMessage = 'Gagal memilih file');
    } finally {
      _isPickingMedia = false;
    }
  }

  // Menyalakan/mematikan senter (flash) kamera.
  Future<void> _toggleTorch() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      debugPrint('TORCH: camera not ready');
      return;
    }

    try {
      final newMode = _isTorchOn ? FlashMode.off : FlashMode.torch;
      await controller.setFlashMode(newMode);
      if (!mounted) return;
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    } catch (e, st) {
      debugPrint('TORCH ERROR: $e');
      debugPrint('STACK TRACE: $st');
    }
  }

  // Kembali ke mode preview kamera setelah foto/gambar dipilih,
  // supaya pengguna bisa mengambil foto lagi.
  void _retakePhoto() {
    setState(() {
      _selectedImage = null;
      _statusMessage = _isCameraReady ? 'Kamera siap' : 'Mengaktifkan kamera...';
    });

    // Kalau controller kamera sempat di-dispose (misal karena app
    // sempat inactive), inisialisasi ulang.
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _initializeCamera();
    }
  }

  // Beralih ke kamera berikutnya (misal dari belakang ke depan), lalu
  // menutup & membuka ulang controller dengan kamera yang baru dipilih.
  Future<void> _switchCamera() async {
    if (_availableCamerasList.length < 2) return;

    Navigator.of(context).pop(); // tutup panel pengaturan

    setState(() {
      _activeCameraIndex =
          (_activeCameraIndex + 1) % _availableCamerasList.length;
      _isCameraReady = false;
    });

    await _cameraController?.dispose();
    _cameraController = null;
    await _initializeCamera();
  }

  // Mengganti preset resolusi kamera, lalu menginisialisasi ulang supaya
  // perubahan langsung terasa.
  Future<void> _changeResolution(ResolutionPreset preset) async {
    if (preset == _preferredResolution) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pop();

    setState(() {
      _preferredResolution = preset;
      _isCameraReady = false;
    });

    await _cameraController?.dispose();
    _cameraController = null;
    await _initializeCamera();
  }

  String _resolutionLabel(ResolutionPreset preset) {
    switch (preset) {
      case ResolutionPreset.high:
        return 'Tinggi';
      case ResolutionPreset.medium:
        return 'Sedang';
      case ResolutionPreset.low:
        return 'Rendah';
      default:
        return preset.name;
    }
  }

  // Panel pengaturan kamera: ganti kamera, kualitas resolusi, dan
  // garis bantu (grid) di dalam bingkai pemindaian.
  void _openSettingsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Pengaturan Kamera',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B4332),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // --- Ganti Kamera ---
                    ListTile(
                      leading: const Icon(Icons.cameraswitch_outlined),
                      title: const Text('Ganti Kamera'),
                      subtitle: Text(
                        _availableCamerasList.length < 2
                            ? 'Hanya satu kamera tersedia di perangkat ini'
                            : (_availableCamerasList[_activeCameraIndex]
                                        .lensDirection ==
                                    CameraLensDirection.back
                                ? 'Sedang memakai kamera belakang'
                                : 'Sedang memakai kamera depan'),
                      ),
                      enabled: _availableCamerasList.length > 1,
                      onTap: _switchCamera,
                    ),
                    const Divider(height: 1),

                    // --- Kualitas Resolusi ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                      child: Text(
                        'Kualitas Resolusi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    ...[
                      RadioGroup<ResolutionPreset>(
                        groupValue: _preferredResolution,
                        onChanged: (value) {
                          if (value != null) _changeResolution(value);
                        },
                        child: Column(
                          children: [
                            ResolutionPreset.high,
                            ResolutionPreset.medium,
                            ResolutionPreset.low,
                          ].map((preset) {
                            final selected = preset == _preferredResolution;
                            return RadioListTile<ResolutionPreset>(
                              value: preset,
                              activeColor: const Color(0xFF1B4332),
                              title: Text(_resolutionLabel(preset)),
                              subtitle: preset == ResolutionPreset.high
                                  ? const Text('Hasil paling tajam, lebih berat')
                                  : preset == ResolutionPreset.low
                                      ? const Text('Paling ringan & cepat')
                                      : const Text(
                                          'Seimbang antara kualitas & performa'),
                              selected: selected,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_selectedImage != null)
            Positioned.fill(
              child: Image.file(_selectedImage!, fit: BoxFit.cover),
            )
          else if (_isCameraReady && _cameraController != null)
            Positioned.fill(child: CameraPreview(_cameraController!))
          else
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F172A), Color(0xFF111827)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _cameraError
                          ? 'Kamera tidak tersedia'
                          : 'Mengaktifkan kamera...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _cameraError
                          ? 'Izinkan akses kamera untuk mulai memindai tanaman.'
                          : 'Silakan tunggu sebentar...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                    if (_cameraError) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeCamera,
                        child: const Text('Coba Lagi'),
                      ),
                      if (_debugErrorDetail != null) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _debugErrorDetail!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.redAccent.withValues(alpha: 0.9),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          // Gradient Overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
          // Top Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(Icons.close, () {
                    if (widget.onClose != null) {
                      widget.onClose!();
                    } else {
                      Navigator.of(context).pop();
                    }
                  }),
                  Row(
                    children: [
                      if (_selectedImage != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildCircleButton(
                            Icons.refresh,
                            _retakePhoto,
                          ),
                        )
                      else ...[
                        _buildCircleButton(
                          _isTorchOn
                              ? Icons.flashlight_on
                              : Icons.flashlight_on_outlined,
                          _toggleTorch,
                          highlighted: _isTorchOn,
                        ),
                        const SizedBox(width: 12),
                        _buildCircleButton(
                          Icons.settings_outlined,
                          _openSettingsSheet,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          // AI Status Badge
          Positioned(
            bottom: 220,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _statusMessage.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom Interaction Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MENGANALISIS...',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _selectedImage == null
                                ? 'Chamomile'
                                : 'Gambar siap dianalisis',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF88D4AB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'AI SCAN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: _pickFromGallery,
                        child: _buildActionItem(Icons.image_outlined, 'Unggah'),
                      ),
                      GestureDetector(
                        onTap: _selectedImage != null
                            ? _retakePhoto
                            : _captureImage,
                        child: Column(
                          children: [
                            _buildShutterButton(),
                            const SizedBox(height: 8),
                            Text(
                              _selectedImage != null ? 'Ambil Ulang' : 'Kamera',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickFile,
                        child: _buildActionItem(Icons.upload_file, 'File'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(
    IconData icon,
    VoidCallback onPressed, {
    bool highlighted = false,
  }) {
    return CircleAvatar(
      backgroundColor: highlighted
          ? const Color(0xFF88D4AB)
          : Colors.white.withValues(alpha: 0.2),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildShutterButton() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF1B4332), width: 2),
      ),
      child: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: Color(0xFF1B4332),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _selectedImage != null
              ? Icons.refresh
              : Icons.center_focus_strong,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}