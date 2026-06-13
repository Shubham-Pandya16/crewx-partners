import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/crewx_badge.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/applications_provider.dart';

class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen> {
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return const Scaffold(body: Center(child: Text('Unauthorized')));

    final applicationsAsync = ref.watch(applicationsStreamProvider(uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Applications')),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: applicationsAsync.when(
              data: (apps) {
                final filteredApps = _activeFilter == 'All'
                    ? apps
                    : apps
                          .where(
                            (a) =>
                                a.status.toLowerCase() ==
                                _activeFilter.toLowerCase(),
                          )
                          .toList();

                if (filteredApps.isEmpty) {
                  return EmptyState(
                    title: 'No applications found',
                    subtitle: 'Applications for your events will appear here.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredApps.length,
                  itemBuilder: (context, index) {
                    final app = filteredApps[index];
                    return _buildApplicationCard(app);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.kYellow),
              ),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['All', 'Pending', 'Accepted', 'Rejected'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: filters.map((f) {
          final isActive = _activeFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f),
              selected: isActive,
              onSelected: (selected) {
                if (selected) setState(() => _activeFilter = f);
              },
              selectedColor: AppColors.kYellow,
              backgroundColor: AppColors.kSurface,
              labelStyle: TextStyle(
                color: isActive ? AppColors.kBlack : AppColors.kTextSecondary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildApplicationCard(dynamic app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CrewXBadge(
                label: app.role,
                color: AppColors.kYellow.withOpacity(0.2),
              ),
              const Spacer(),
              _buildStatusBadge(app.status),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Applied for Event Name',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Applied on 24 Jun 2025',
            style: const TextStyle(
              color: AppColors.kTextSecondary,
              fontSize: 12,
            ),
          ),
          if (app.note != null && app.note!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              app.note!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.kTextSecondary,
                fontSize: 13,
              ),
            ),
          ],
          if (app.status == 'pending') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => ref
                        .read(applicationsProvider.notifier)
                        .respondToApplication(app.applicationId, 'accepted'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kYellow,
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(color: AppColors.kBlack),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(app.applicationId),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = AppColors.kYellow;
    if (status == 'rejected') color = AppColors.kError;
    if (status == 'accepted') color = AppColors.kSuccess;
    return CrewXBadge(label: status, color: color);
  }

  void _showRejectDialog(String appId) {
    final reasonController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.kSurface,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reject Application',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please provide a reason for rejection (optional)',
              style: TextStyle(color: AppColors.kTextSecondary),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'e.g. Profile does not match requirements',
              ),
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(applicationsProvider.notifier)
                    .respondToApplication(
                      appId,
                      'rejected',
                      rejectionReason: reasonController.text.trim(),
                    );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kError,
              ),
              child: const Text(
                'Confirm Reject',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
