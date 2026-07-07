import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../content/catalog.dart' as catalog;
import '../../content/scan.dart' as scan;
import '../saved_screen.dart';
import 'widgets/home_content.dart';
import '../../discoveries/home_bottom_nav.dart';

/// HomeDashboardScreen HANYA bertugas merangkai 3 bagian:
/// - CONTENT (HomeContent, yang di dalamnya sudah memuat HomeHeader)
/// - MENU (HomeBottomNav)
/// - dan mengatur perpindahan tab (Home / Discover / Scan / Saved).
///
/// Semua detail tampilan header/content/menu TIDAK ada di sini lagi,
/// melainkan di masing-masing file widget-nya sendiri.
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _selectedTab = 0;

  // Setiap tab hanya dibangun sekali, saat pertama kali benar-benar
  // dibuka (biar tab Scan tidak otomatis menyalakan kamera di background
  // sebelum pernah dibuka oleh user).
  final List<Widget?> _tabCache = List<Widget?>.filled(4, null);

  void _navigateToTab(int index) {
    setState(() {
      _selectedTab = index;
      _tabCache[index] ??= _buildTab(index);
    });
  }

  Widget _buildTab(int index) {
    switch (index) {
      case 0:
        return HomeContent(onScanTap: () => _navigateToTab(2));
      case 1:
        return catalog.PlantCatalogScreen(showBottomNavigationBar: false);
      case 2:
        return scan.PlantScanScreen(onClose: () => _navigateToTab(0));
      case 3:
        return const SavedScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    _tabCache[_selectedTab] ??= _buildTab(_selectedTab);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: IndexedStack(
        index: _selectedTab,
        children: List.generate(4, (i) => _tabCache[i] ?? const SizedBox.shrink()),
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _selectedTab,
        onTap: _navigateToTab,
      ),
    );
  }
}