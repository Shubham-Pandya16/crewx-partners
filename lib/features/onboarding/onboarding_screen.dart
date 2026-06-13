import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/crewx_button.dart';
import '../../core/widgets/crewx_text_field.dart';
import '../../providers/organiser_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1
  final _companyNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _websiteController = TextEditingController();
  final _formKey1 = GlobalKey<FormState>();

  // Step 2
  final _contactNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _designationController = TextEditingController();
  final _formKey2 = GlobalKey<FormState>();
  File? _logoFile;

  @override
  void dispose() {
    _pageController.dispose();
    _companyNameController.dispose();
    _cityController.dispose();
    _websiteController.dispose();
    _contactNameController.dispose();
    _emailController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _logoFile = File(image.path);
      });
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey1.currentState!.validate()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_formKey2.currentState!.validate()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => _currentStep++);
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _submit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    String? logoUrl;
    if (_logoFile != null) {
      logoUrl = await ref
          .read(organiserProvider.notifier)
          .uploadLogo(uid, _logoFile!);
    }

    await ref.read(organiserProvider.notifier).completeOnboarding(
          uid,
          contactName: _contactNameController.text.trim(),
          companyName: _companyNameController.text.trim(),
          city: _cityController.text.trim(),
          logoUrl: logoUrl,
        );

    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final organiserState = ref.watch(organiserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Profile'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _prevStep,
              )
            : null,
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: AppColors.kSurfaceAlt,
            color: AppColors.kYellow,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildStep1(), _buildStep2(), _buildStep3()],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: CrewXButton(
              label: _currentStep == 2 ? 'Complete Setup' : 'Continue',
              onPressed: _currentStep == 2 ? _submit : _nextStep,
              isLoading: organiserState.isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tell us about your organisation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            CrewXTextField(
              label: 'Company Name',
              controller: _companyNameController,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            CrewXTextField(
              label: 'Organisation Type',
              controller: TextEditingController(text: 'Supplier'),
              readOnly: true,
            ),
            const SizedBox(height: 24),
            CrewXTextField(
              label: 'City',
              controller: _cityController,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            CrewXTextField(
              label: 'Website (Optional)',
              controller: _websiteController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Who should we contact?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.kSurfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.kBorder),
                    image: _logoFile != null
                        ? DecorationImage(
                            image: FileImage(_logoFile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _logoFile == null
                      ? const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: AppColors.kTextSecondary,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 32),
            CrewXTextField(
              label: 'Contact Name',
              controller: _contactNameController,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            CrewXTextField(
              label: 'Email Address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v!.isEmpty) return 'Required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v))
                  return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 24),
            CrewXTextField(
              label: 'Designation (Optional)',
              controller: _designationController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Looking good!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.kSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.kBorder),
            ),
            child: Column(
              children: [
                _buildReviewRow('Company Name', _companyNameController.text),
                _buildReviewRow('City', _cityController.text),
                _buildReviewRow('Contact Name', _contactNameController.text),
                _buildReviewRow('Email', _emailController.text),
                _buildReviewRow('Type', 'Supplier'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.kTextSecondary)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
