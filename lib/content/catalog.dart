import 'package:flutter/material.dart';
import 'scan.dart' as scan;

void main() {
  runApp(const EdibleApp());
}

class EdibleApp extends StatelessWidget {
  const EdibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edible App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4332),
          surface: const Color(0xFFF4FAFD),
          primary: const Color(0xFF1B4332),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontFamily: 'SourceSerif4',
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B4332),
          ),
          titleLarge: TextStyle(
            fontFamily: 'SourceSerif4',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const PlantCatalogScreen(),
    );
  }
}

/// Model data sederhana untuk satu entri tanaman di katalog.
class Plant {
  final String scientificName;
  final String commonName;
  final String description;
  final String imageUrl;
  final bool isEdible;

  const Plant({
    required this.scientificName,
    required this.commonName,
    required this.description,
    required this.imageUrl,
    required this.isEdible,
  });
}

/// Daftar tanaman utama. Tambah/ubah data di sini saja — otomatis akan
/// muncul di katalog, ikut kena filter, dan ikut kena pencarian.
const List<Plant> kPlants = [
  Plant(
    scientificName: 'Begoniaceae',
    commonName: 'Begonia',
    description:
        'Daun dan bunganya memiliki rasa asam segar, beberapa jenis biasa dijadikan campuran lalapan...',
    imageUrl: 'assets/icons/Image/Begonia.jpg',
    isEdible: true,
  ),
  Plant(
    scientificName: 'IMPERATA CYLINDRICA',
    commonName: 'Alang-alang',
    description:
        'Rimpang dapat dimanfaatkan sebagai bahan obat tradisional dan memiliki khasiat...',
    imageUrl: 'assets/icons/Image/alang-alang006.jpg',
    isEdible: true,
  ),
  Plant(
    scientificName: 'MORUS ALBA',
    commonName: 'Buah Murbei',
    description:
        'Buah yang kaya antioksidan dan vitamin C. Dapat dikonsumsi langsung atau diolah...',
    imageUrl: 'assets/icons/Image/buah-merbei018.jpg',
    isEdible: true,
  ),
  Plant(
    scientificName: 'PHYSALIS ANGULATA',
    commonName: 'Ciplukan',
    description:
        'Buah kecil yang sering ditemukan liar. Dipercaya memiliki khasiat sebagai obat...',
    imageUrl: 'assets/icons/Image/ciplukan011.jpg',
    isEdible: true,
  ),
  Plant(
    scientificName: 'ETLINGERA ELATIOR',
    commonName: 'Honje',
    description:
        'Bunga dan batang muda sering digunakan sebagai bumbu masakan tradisional...',
    imageUrl: 'assets/icons/Image/honje017.jpg',
    isEdible: true,
  ),
  Plant(
    scientificName: 'DIPLAZIUM ESCULENTUM',
    commonName: 'Paku Sayur',
    description:
        'Pucuk muda pakis ini populer sebagai sayuran, kaya serat dan zat besi...',
    imageUrl: 'assets/icons/Image/Paku sayur.jpg',
    isEdible: true,
  ),
  Plant(
    scientificName: 'PILEA MELASTOMOIDES',
    commonName: 'Pohpohan',
    description:
        'Daun yang biasa dikonsumsi sebagai lalapan segar di Jawa Barat...',
    imageUrl: 'assets/icons/Image/Pohpohan.jpg',
    isEdible: true,
  ),
  Plant(
    scientificName: 'VACCINIUM VARINGIAEFOLIUM',
    commonName: 'Cantigi Gunung',
    description:
        'Tumbuhan khas dataran tinggi, buahnya kecil dan biasa ditemukan di area pegunungan...',
    imageUrl: 'assets/icons/Image/Cantigi_gunung.jpg',
    isEdible: true,
  ),
  Plant(
    scientificName: 'CLIDEMIA HIRTA',
    commonName: 'Daun Senggani',
    description:
        'Daun dan buahnya dikenal dalam pengobatan tradisional, sering tumbuh liar di semak...',
    imageUrl: 'assets/icons/Image/Daun Senggani.jpg',
    isEdible: true,
  ),
  Plant(
    scientificName: 'MARCHANTIA POLYMORPHA',
    commonName: 'Lumut Hati',
    description:
        'Tumbuhan lumut yang tumbuh di tempat lembap, umumnya tidak dikonsumsi manusia...',
    imageUrl: 'assets/icons/Image/LumutHati.jpg',
    isEdible: true,
  ),
  Plant(
    scientificName: 'SELAGINELLA PLANA',
    commonName: 'Rane',
    description:
        'Tumbuhan paku-pakuan yang biasa tumbuh di tempat teduh dan lembap, bukan untuk dikonsumsi...',
    imageUrl: 'assets/icons/Image/rane054.jpg',
    isEdible: true,
  ),
  Plant(
    scientificName: 'OXALIS CORNICULATA',
    commonName: 'Semanggi',
    description:
        'Daun berbentuk trifoliate, rasanya asam segar dan biasa diolah menjadi urap...',
    imageUrl: 'assets/icons/Image/Semanggi (5).jpg',
    isEdible: true,
  ),
  Plant(
    scientificName: 'RICINUS COMMUNIS',
    commonName: 'Jarak',
    description:
        'Bijinya mengandung racun ricin yang sangat berbahaya jika tertelan, meski minyaknya dimanfaatkan untuk keperluan industri...',
    imageUrl: 'assets/icons/Image/Ricinus.jpg',
    isEdible: false,
  ),
  Plant(
    scientificName: 'AMANITA MUSCARIA',
    commonName: 'Jamur',
    description:
        'Beberapa jenis jamur liar mengandung racun berbahaya dan mudah dikira mirip dengan jamur yang bisa dikonsumsi...',
    imageUrl: 'assets/icons/Image/Jamur.jpg',
    isEdible: false,
  ),
];

class PlantCatalogScreen extends StatefulWidget {
  final bool showBottomNavigationBar;

  const PlantCatalogScreen({super.key, this.showBottomNavigationBar = true});

  @override
  State<PlantCatalogScreen> createState() => _PlantCatalogScreenState();
}

class _PlantCatalogScreenState extends State<PlantCatalogScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomePage(),
          const DiscoverPage(),
          scan.PlantScanScreen(onClose: () => _onItemTapped(0)),
          _buildSavedPage(),
        ],
      ),
      bottomNavigationBar: widget.showBottomNavigationBar
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF1B4332),
              unselectedItemColor: Colors.grey,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore),
                  label: 'Discover',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.center_focus_strong_outlined),
                  label: 'Scan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark_outline),
                  label: 'Saved',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildHomePage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Home', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang di Edible App',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gunakan menu untuk melihat katalog tanaman, memindai tanaman, dan menyimpan referensi favorit Anda.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedPage() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_outline,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Menu Saved sudah siap',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Daftar tanaman yang Anda simpan dapat dikembangkan lebih lanjut di sini.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kategori filter yang tersedia untuk katalog.
enum PlantFilter { semua, aman, berbahaya }

/// Halaman "Discover" — berisi search bar dan filter chip yang aktif
/// menyaring daftar tanaman berdasarkan kata kunci dan status aman/berbahaya.
class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  PlantFilter _selectedFilter = PlantFilter.semua;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Plant> get _filteredPlants {
    return kPlants.where((plant) {
      final matchesFilter = switch (_selectedFilter) {
        PlantFilter.semua => true,
        PlantFilter.aman => plant.isEdible,
        PlantFilter.berbahaya => !plant.isEdible,
      };

      if (!matchesFilter) return false;

      if (_searchQuery.isEmpty) return true;

      final query = _searchQuery.toLowerCase();
      return plant.commonName.toLowerCase().contains(query) ||
          plant.scientificName.toLowerCase().contains(query);
    }).toList();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  // --- Header, disamakan gayanya dengan _buildTopAppBar() di home.dart:
  // avatar bulat dengan border hijau, judul serif, dan tombol search bulat.
  // Saat _isSearching aktif, judul berubah menjadi kolom input pencarian.
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: _CatalogColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          if (!_isSearching) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFC1ECD4),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/icons/Image/Begonia.jp',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: _CatalogColors.surfaceContainerLow,
                    child: const Icon(
                      Icons.person,
                      color: _CatalogColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(
                      color: _CatalogColors.primary,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari nama tanaman...',
                      hintStyle: TextStyle(color: _CatalogColors.outline),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  )
                : Text(
                    'Edible App',
                    style: const TextStyle(
                      fontFamily: 'Source Serif 4',
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      color: _CatalogColors.primary,
                    ),
                  ),
          ),
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            color: _CatalogColors.primary,
            style: IconButton.styleFrom(
              shape: const CircleBorder(),
              highlightColor: _CatalogColors.surfaceContainerLow,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredPlants;

    return Scaffold(
      backgroundColor: _CatalogColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                'Katalog Tanaman',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            FilterChips(
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() => _selectedFilter = filter);
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada tanaman yang cocok.',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final plant = results[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: PlantCard(
                            scientificName: plant.scientificName,
                            commonName: plant.commonName,
                            description: plant.description,
                            imageUrl: plant.imageUrl,
                            isEdible: plant.isEdible,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Warna lokal yang meniru AppColors dari home.dart, supaya header
/// di sini terlihat identik tanpa perlu import silang antar file.
class _CatalogColors {
  static const primary = Color(0xFF012D1D);
  static const surface = Color(0xFFF4FAFD);
  static const surfaceContainerLow = Color(0xFFEEF5F7);
  static const outline = Color(0xFF717973);
}

class FilterChips extends StatelessWidget {
  final PlantFilter selectedFilter;
  final ValueChanged<PlantFilter> onFilterChanged;

  const FilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Semua'),
            selected: selectedFilter == PlantFilter.semua,
            onSelected: (_) => onFilterChanged(PlantFilter.semua),
            selectedColor: const Color(0xFF1B4332),
            labelStyle: TextStyle(
              color: selectedFilter == PlantFilter.semua
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Aman Dikonsumsi'),
            selected: selectedFilter == PlantFilter.aman,
            onSelected: (_) => onFilterChanged(PlantFilter.aman),
            selectedColor: const Color(0xFF88D4AB),
            labelStyle: TextStyle(
              color: selectedFilter == PlantFilter.aman
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Berbahaya'),
            selected: selectedFilter == PlantFilter.berbahaya,
            onSelected: (_) => onFilterChanged(PlantFilter.berbahaya),
            selectedColor: const Color(0xFFB91C1C),
            labelStyle: TextStyle(
              color: selectedFilter == PlantFilter.berbahaya
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class PlantCard extends StatelessWidget {
  final String scientificName;
  final String commonName;
  final String description;
  final String imageUrl;
  final bool isEdible;

  const PlantCard({
    super.key,
    required this.scientificName,
    required this.commonName,
    required this.description,
    required this.imageUrl,
    required this.isEdible,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.asset(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isEdible
                        ? const Color(0xFF88D4AB)
                        : const Color(0xFFB91C1C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isEdible ? Icons.eco : Icons.warning,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isEdible ? 'Aman Dikonsumsi' : 'Berbahaya',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scientificName,
                  style: const TextStyle(
                    color: Color(0xFF1B4332),
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(commonName, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}