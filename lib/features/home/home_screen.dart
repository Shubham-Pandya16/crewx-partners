import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/crewx_badge.dart';
import '../../providers/organiser_provider.dart';
import '../applications/applications_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return const Scaffold(body: Center(child: Text('Unauthorized')));

    final organiserAsync = ref.watch(organiserStreamProvider(uid));

    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: const Text('crewX Partners',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kYellow)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () => context.push('/notifications'),
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () => context.push('/profile'),
                ),
              ],
            )
          : null,
      body: _buildBody(uid, organiserAsync),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event),
              label: 'Events'),
          BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              activeIcon: Icon(Icons.group),
              label: 'Applications'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody(String uid, AsyncValue organiserAsync) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab(organiserAsync);
      case 1:
        return SizedBox();
      case 2:
        return ApplicationsScreen();
      case 3:
        return ProfileScreen();
      default:
        return SizedBox();
    }
  }

  Widget _buildHomeTab(AsyncValue organiserAsync) {
    return organiserAsync.when(
      data: (org) {
        if (org == null)
          return const Center(child: Text('Organiser not found'));
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.kSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome back,',
                            style: TextStyle(color: AppColors.kTextSecondary)),
                        Text(org.companyName ?? 'Organiser',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.kYellow)),
                      ],
                    ),
                    const Spacer(),
                    if (org.verified)
                      const CrewXBadge(
                          label: 'Verified', color: AppColors.kSuccess)
                    else
                      const CrewXBadge(
                          label: 'Pending KYC', color: AppColors.kError),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Stats Row
              Row(
                children: [
                  _buildStatCard(
                      'Events Posted', org.totalEventsPosted.toString()),
                  const SizedBox(width: 12),
                  _buildStatCard(
                      'Crew Hired', org.totalVolunteersHired.toString()),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Quick Actions',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildActionCard(Icons.add_circle_outline, 'Post an Event',
                      () => context.push('/events/create')),
                  _buildActionCard(Icons.event_note, 'My Events',
                      () => setState(() => _currentIndex = 1)),
                  _buildActionCard(Icons.people_outline, 'Applications',
                      () => setState(() => _currentIndex = 2)),
                ],
              ),
              const SizedBox(height: 24),
              if (org.kycStatus != 'approved')
                _buildKycBanner(org.kycStatus, org.kycRejectionReason),
            ],
          ),
        );
      },
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.kYellow)),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kYellow)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.kTextSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.kBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.kYellow, size: 32),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildKycBanner(String status, String? reason) {
    Color bannerColor =
        status == 'rejected' ? AppColors.kError : AppColors.kYellow;
    String bannerText = status == 'not_submitted'
        ? 'Complete KYC to start hiring'
        : status == 'pending'
            ? 'KYC under review'
            : 'KYC rejected';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bannerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bannerText,
              style:
                  TextStyle(color: bannerColor, fontWeight: FontWeight.bold)),
          if (reason != null && status == 'rejected') ...[
            const SizedBox(height: 4),
            Text(reason,
                style: const TextStyle(
                    color: AppColors.kTextSecondary, fontSize: 12)),
          ],
          const SizedBox(height: 12),
          if (status != 'pending')
            ElevatedButton(
              onPressed: () => context.push('/profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: bannerColor,
                minimumSize: const Size(double.infinity, 40),
              ),
              child: Text(status == 'rejected' ? 'Resubmit KYC' : 'Submit KYC',
                  style: const TextStyle(color: AppColors.kBlack)),
            ),
        ],
      ),
    );
  }
}
