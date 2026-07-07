import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../discoveries/plant_cards.dart';
import 'home_header.dart';

/// CONTENT halaman Home: header + hero + search + Discoveries + info
/// prompt, dibungkus scroll view, plus tombol scan (FAB) yang
/// menghilang saat user scroll ke bawah.
class HomeContent extends StatefulWidget {
  final VoidCallback onScanTap;

  const HomeContent({super.key, required this.onScanTap});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ScrollController _scrollController = ScrollController();
  bool _showFab = true;
  double _lastOffset = 0;

  final List<String> _filterOptions = ['Semua', 'Edible', 'Non-Edible'];
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final offset = _scrollController.offset;
    final goingDown = offset > _lastOffset && offset > 100;
    if (goingDown && _showFab) {
      setState(() => _showFab = false);
    } else if (!goingDown && !_showFab) {
      setState(() => _showFab = true);
    }
    _lastOffset = offset;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Filter Tanaman',
                    style: TextStyle(
                      fontFamily: 'Source Serif 4',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ..._filterOptions.map((option) {
                  final selected = option == _selectedFilter;
                  return ListTile(
                    onTap: () {
                      setState(() => _selectedFilter = option);
                      Navigator.of(context).pop();
                    },
                    title: Text(
                      option,
                      style: TextStyle(
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                    trailing: selected
                        ? Icon(Icons.check_circle, color: AppColors.secondary)
                        : null,
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              const HomeHeader(),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHero(context),
                      _buildSearchBar(),
                      _buildDiscoveriesSection(context),
                      _buildInfoPrompt(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
          bottom: _showFab ? 96 : -24,
          right: 20,
          child: SizedBox(
            width: 64,
            height: 64,
            child: FloatingActionButton(
              onPressed: widget.onScanTap,
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimaryContainer,
              elevation: 6,
              shape: const CircleBorder(),
              child: const Icon(Icons.center_focus_strong, size: 32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome, Survivors.',
            style: TextStyle(
              fontFamily: 'Source Serif 4',
              fontSize: 28,
              height: 34 / 28,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Text(
              'Temukan keajaiban botani di sekitar Anda hari ini.',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final bool filterActive = _selectedFilter != 'Semua';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search plants, flowers, or herbs...',
          hintStyle: TextStyle(color: AppColors.outline),
          prefixIcon: Icon(Icons.search, color: AppColors.outline),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.filter_list,
              color: filterActive ? AppColors.secondary : AppColors.primary,
            ),
            onPressed: _openFilterSheet,
          ),
          filled: true,
          fillColor: AppColors.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoveriesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Discoveries',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontSize: 24),
              ),
              Text(
                'VIEW ALL',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const FeaturedPlantCard(),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: SmallPlantCard(
                  imageAsset: 'assets/icons/Image/Jamur.jpg',
                  label: 'Toxic',
                  labelIcon: Icons.warning,
                  labelColor: AppColors.error,
                  labelBg: AppColors.errorContainer,
                  title: 'Fly Agaric',
                  subtitle: 'Forest Floor',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: SmallPlantCard(
                  imageAsset: 'assets/icons/Image/honje017.jpg',
                  label: 'Edible',
                  labelIcon: Icons.medical_services,
                  labelColor: AppColors.onSecondaryContainer,
                  labelBg: AppColors.secondaryContainer,
                  title: 'Kecombrang',
                  subtitle: 'Etlingera elatior',
                  cornerBadge: 'New',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPrompt() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              bottom: -40,
              child: Transform.rotate(
                angle: 0.2,
                child: Icon(
                  Icons.eco,
                  size: 160,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Foraging Wisdom',
                  style: TextStyle(
                    fontFamily: 'Source Serif 4',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Jika ragu, jangan diambil! Mengenali tanaman beracun yang mirip '
                  'dengan tanaman yang bisa dimakan adalah langkah awal dalam '
                  'keberhasilan mencari bahan pangan di alam liar.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Read Field Safety',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}