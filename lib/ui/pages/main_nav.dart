import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import 'home_page.dart';
import 'services_page.dart';
import 'community_page.dart';
import 'applications_page.dart';
import 'profile_page.dart';
import '../widgets/ai_assistant_orb.dart';

class MainNav extends ConsumerStatefulWidget {
  const MainNav({super.key});

  @override
  ConsumerState<MainNav> createState() => _MainNavState();
}

class _MainNavState extends ConsumerState<MainNav> {
  int _index = 0;
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      HomePage(onNavigateToTab: (index) => setState(() => _index = index)),
      const ServicesPage(),
      const CommunityPage(),
      const ApplicationsPage(), // Applications/Summits
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [pages[_index], if (_index == 0) const AiAssistantOrb()],
      ),
      bottomNavigationBar: _CustomBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        ref: ref,
      ),
    );
  }
}

/// Custom bottom navigation bar with semicircular community tab
class _CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final WidgetRef ref;

  const _CustomBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCommunitySelected = currentIndex == 2;
    return SizedBox(
      height: 70,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Clipped nav background (carved notch)
          ClipPath(
            clipper: _NavBarNotchClipper(radius: 50, depth: 26),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
            ),
          ),

          // Removed white glow under the center button to avoid visible white space

          // Standard bottom nav items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, 'Home'),
              _buildNavItem(1, Icons.business_center_outlined, 'Services'),
              // Spacer for the semicircular button
              const SizedBox(width: 80),
              _buildNavItem(3, Icons.track_changes, 'Track'),
              _buildNavItem(4, Icons.more_horiz, 'More'),
            ],
          ),

          // "Create" button positioned above and to the right of bottom nav (only on Community page)
          if (currentIndex == 2)
            Positioned(
              right: 16,
              bottom: 70,
              child: FloatingActionButton(
                heroTag: 'create_button',
                onPressed: () {
                  _showCreatePostOptions(context);
                },
                backgroundColor: AppColors.purple,
                elevation: 6,
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),

          // Community label under the center tab
          Positioned(
            left: 0,
            right: 0,
            bottom: 6,
            child: IgnorePointer(
              ignoring: true,
              child: Center(
                child: Text(
                  'Community',
                  style: TextStyle(
                    fontSize: 11,
                    color: isCommunitySelected ? AppColors.purple : Colors.grey,
                    fontWeight: isCommunitySelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),

          // Semicircular Community button (drawn above everything, not clipped)
          Positioned(
            left: width / 2 - 50,
            top: -26,
            child: _buildSemicircularButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.purple : Colors.grey,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppColors.purple : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemicircularButton() {
    final selected = currentIndex == 2;
    return Semantics(
      label: 'Community Tab',
      button: true,
      child: Tooltip(
        message: 'Community',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap(2);
          },
          child: AnimatedScale(
            scale: selected ? 1.03 : 1.0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            child: SizedBox(
              width: 100,
              height: 90,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Inverted semicircle (∩-shape)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    width: 100,
                    height: 62,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7A5AF8), Color(0xFF9B7BFF)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF7A5AF8,
                          ).withOpacity(0.35),
                          blurRadius: 18,
                          spreadRadius: 1,
                          offset: const Offset(0, -4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                        width: 1,
                      ),
                    ),
                  ),
                  // Icon capsule
                  Positioned(
                    top: 6,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: selected ? 58 : 54,
                      height: selected ? 58 : 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.28),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.25),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  // Removed inner label; the label now sits under the tab in the bar baseline
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCreatePostOptions(BuildContext context) {
    // Call the community page's create options menu
    CommunityPage.showCreateOptionsMenu(context, ref);
  }
}

/// Clipper that carves a concave circular notch at the top center
class _NavBarNotchClipper extends CustomClipper<Path> {
  final double radius;
  final double depth;
  _NavBarNotchClipper({required this.radius, required this.depth});

  @override
  Path getClip(Size size) {
    final rectPath = Path()..addRect(Offset.zero & size);
    // Carve a shallow concave notch by placing the circle center ABOVE the top edge.
    // `depth` is the vertical depth (in px) that the notch cuts into the bar from the top.
    final center = Offset(size.width / 2, -(radius - depth));
    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    return Path.combine(PathOperation.difference, rectPath, circlePath);
  }

  @override
  bool shouldReclip(covariant _NavBarNotchClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.depth != depth;
  }
}
