import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/crewx_badge.dart';
import '../../core/widgets/crewx_button.dart';
import '../../core/widgets/crewx_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organiser_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _gstController = TextEditingController();
  final _panController = TextEditingController();

  @override
  void dispose() {
    _gstController.dispose();
    _panController.dispose();
    super.dispose();
  }

  void _submitKyc(String uid) {
    if (_gstController.text.length != 15) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid GST Number')));
      return;
    }
    if (_panController.text.length != 10) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid PAN Number')));
      return;
    }

    ref.read(organiserProvider.notifier).updateProfile(uid, {
      'gstNumber': _gstController.text.toUpperCase(),
      'panNumber': _panController.text.toUpperCase(),
      'kycStatus': 'pending',
      'kycSubmittedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return const Scaffold(body: Center(child: Text('Unauthorized')));

    final organiserAsync = ref.watch(organiserStreamProvider(uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: organiserAsync.when(
        data: (org) {
          if (org == null)
            return const Center(child: Text('Organiser not found'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCompanyCard(org),
                const SizedBox(height: 16),
                _buildKycCard(org),
                const SizedBox(height: 16),
                _buildAccountCard(org),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.kSurface,
                        title: const Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          'Are you sure you want to sign out?',
                          style: TextStyle(color: AppColors.kTextSecondary),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(authProvider.notifier).signOut();
                              context.go('/auth');
                            },
                            child: const Text(
                              'Sign Out',
                              style: TextStyle(color: AppColors.kError),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: AppColors.kError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.kYellow),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildCompanyCard(dynamic org) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.kSurfaceAlt,
            backgroundImage: org.logoUrl != null
                ? CachedNetworkImageProvider(org.logoUrl!)
                : null,
            child: org.logoUrl == null
                ? Text(
                    org.companyName?[0] ?? 'C',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kYellow,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  org.companyName ?? 'Company',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  org.city ?? 'City',
                  style: const TextStyle(color: AppColors.kTextSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.kYellow),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildKycCard(dynamic org) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'KYC Verification',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              _buildKycStatusBadge(org.kycStatus),
            ],
          ),
          const SizedBox(height: 20),
          if (org.kycStatus == 'not_submitted' ||
              org.kycStatus == 'rejected') ...[
            if (org.kycStatus == 'rejected') ...[
              Text(
                org.kycRejectionReason ?? 'Rejection reason not provided',
                style: const TextStyle(color: AppColors.kError, fontSize: 13),
              ),
              const SizedBox(height: 12),
            ],
            CrewXTextField(
              label: 'GST Number',
              controller: _gstController,
              maxLength: 15,
              hint: '15-digit GSTIN',
            ),
            const SizedBox(height: 16),
            CrewXTextField(
              label: 'PAN Number',
              controller: _panController,
              maxLength: 10,
              hint: '10-digit PAN',
            ),
            const SizedBox(height: 24),
            CrewXButton(
              label: 'Submit KYC',
              onPressed: () => _submitKyc(org.uid),
            ),
          ] else ...[
            _buildDetailRow('GST Number', org.gstNumber ?? 'N/A'),
            _buildDetailRow('PAN Number', org.panNumber ?? 'N/A'),
            if (org.kycStatus == 'pending')
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Your documents are under review.',
                  style: TextStyle(
                    color: AppColors.kTextSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountCard(dynamic org) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Phone', org.phone),
          _buildDetailRow('Contact Name', org.contactName ?? 'N/A'),
          _buildDetailRow('Organisation Type', org.organisationType),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.kTextSecondary)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycStatusBadge(String status) {
    Color color = AppColors.kYellow;
    if (status == 'rejected') color = AppColors.kError;
    if (status == 'approved') color = AppColors.kSuccess;
    if (status == 'not_submitted') color = AppColors.kTextSecondary;
    return CrewXBadge(label: status.replaceAll('_', ' '), color: color);
  }
}
