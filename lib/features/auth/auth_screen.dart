import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/crewx_button.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (_formKey.currentState!.validate()) {
      final phone = _phoneController.text.trim();
      ref
          .read(authProvider.notifier)
          .sendOtp(
            phone: phone,
            onCodeSent: (vId) {
              context.push(
                '/otp',
                extra: {'verificationId': vId, 'phone': phone},
              );
            },
            onFailed: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error),
                  backgroundColor: AppColors.kError,
                ),
              );
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Row(
                  children: [
                    Text(
                      AppStrings.appName,
                      style: Theme.of(
                        context,
                      ).textTheme.displayLarge?.copyWith(color: Colors.white),
                    ),
                    Text(
                      'X',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.kYellow,
                      ),
                    ),
                  ],
                ),
                Text(
                  AppStrings.appSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.manageCrew,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                const Text(
                  'Enter your mobile number',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  maxLength: 10,
                  decoration: InputDecoration(
                    hintText: 'Mobile number',
                    prefixIcon: Container(
                      width: 80,
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🇮🇳', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Text(
                            '+91',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    counterText: '',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Enter your mobile number';
                    if (v.length != 10) return 'Enter a valid 10-digit number';
                    if (!RegExp(r'^[6-9]').hasMatch(v))
                      return 'Invalid mobile number';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                CrewXButton(
                  label: 'Send OTP',
                  onPressed: _sendOtp,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
