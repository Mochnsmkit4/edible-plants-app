import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// HEADER halaman Home: avatar bulat + judul aplikasi + tombol search.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC1ECD4), width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/icons/Image/Begonia.jp',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceContainerLow,
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Edible App',
                style: TextStyle(
                  fontFamily: 'Source Serif 4',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            color: AppColors.primary,
            style: IconButton.styleFrom(
              shape: const CircleBorder(),
              highlightColor: AppColors.surfaceContainerLow,
            ),
          ),
        ],
      ),
    );
  }
}