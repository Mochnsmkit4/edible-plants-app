import 'package:flutter/material.dart';

void main() {
  runApp(const EdibleApp());
}

class EdibleApp extends StatelessWidget {
  const EdibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edible App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4332),
          surface: const Color(0xFFF4FAFD),
          primary: const Color(0xFF1B4332),
          secondary: const Color(0xFF88D4AB),
          error: const Color(0xFFB91C1C),
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
      home: const PlantDetailScreen(),
    );
  }
}

class PlantDetailScreen extends StatelessWidget {
  const PlantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                backgroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    child: const BackButton(color: Colors.black87),
                  ),
                ),
                actions: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    child: IconButton(
                      icon: const Icon(
                        Icons.share_outlined,
                        color: Colors.black87,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    child: IconButton(
                      icon: const Icon(
                        Icons.bookmark_border,
                        color: Colors.black87,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    'https://images.unsplash.com/photo-1544070078-a212eda27b49?auto=format&fit=crop&q=80&w=800',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -30),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Wild Raspberry',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                const Text(
                                  'Rubus idaeus',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF88D4AB,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.eco,
                                    size: 16,
                                    color: Color(0xFF1B4332),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'EDIBLE',
                                    style: TextStyle(
                                      color: Color(0xFF1B4332),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildInfoBadge(
                              Icons.calendar_today_outlined,
                              'June - Aug',
                            ),
                            const SizedBox(width: 12),
                            _buildInfoBadge(
                              Icons.location_on_outlined,
                              'Forest Edge',
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'BOTANICAL DESCRIPTION',
                          style: TextStyle(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'The wild raspberry is a deciduous shrub characterized by its woody stems with small prickles. The fruit is a composite of drupelets that pulls away from its core when ripe, leaving a hollow center. Unlike cultivated varieties, wild raspberries are smaller but possess a much more intense, aromatic flavor profile.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildSafetyGuidelines(),
                        const SizedBox(height: 32),
                        const Text(
                          'KEY FEATURES',
                          style: TextStyle(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFeatureCard(
                                Icons.waves,
                                'Leaf Type',
                                'Pinnate, Serrated',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFeatureCard(
                                Icons.height,
                                'Stem Height',
                                '0.5m – 2.0m',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          Icons.verified_user_outlined,
                          'Toxicity Risk',
                          'Zero (100% Non-toxic)',
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'SIMILAR LOOK-ALIKES',
                              style: TextStyle(
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('View Comparison'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildLookAlikes(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Local Range'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.center_focus_strong),
                      label: const Text('Verify with Scan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4332),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyGuidelines() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFB91C1C).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFB91C1C).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFB91C1C)),
              SizedBox(width: 8),
              Text(
                'Safety Guidelines',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB91C1C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuidelineItem(
            'Always look for the hollow center to distinguish from look-alikes.',
          ),
          _buildGuidelineItem(
            'Wash thoroughly before consumption to remove forest debris or insects.',
          ),
          _buildGuidelineItem(
            'Avoid berries near low-lying paths frequented by domestic animals.',
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 18,
            color: Color(0xFF1B4332),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String label,
    String value, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1B4332)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (isFullWidth) ...[
            const Spacer(),
            const Icon(Icons.verified, color: Colors.green),
          ],
        ],
      ),
    );
  }

  Widget _buildLookAlikes() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildLookAlikeItem(
            'https://images.unsplash.com/photo-1544070078-a212eda27b49?auto=format&fit=crop&q=80&w=200',
          ),
          _buildLookAlikeItem(
            'https://images.unsplash.com/photo-1620986701391-f92576926955?auto=format&fit=crop&q=80&w=200',
          ),
          _buildLookAlikeItem(
            'https://images.unsplash.com/photo-1615485240314-cd9a043a29bc?auto=format&fit=crop&q=80&w=200',
          ),
        ],
      ),
    );
  }

  Widget _buildLookAlikeItem(String url) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }
}
