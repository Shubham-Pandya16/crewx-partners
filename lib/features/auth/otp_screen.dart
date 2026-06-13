import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/firebase_service.dart';
import '../../core/widgets/crewx_button.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phone;

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phone,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  int _timerValue = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerValue == 0) {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      } else {
        setState(() {
          _timerValue--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify(String code) async {
    final res = await ref.read(authProvider.notifier).verifyOtp(widget.verificationId, code);
    if (res != null) {
      final user = res.user!;
      final exists = await FirebaseService().userExists(user.uid);
      if (!exists) {
        await FirebaseService().createUserDoc(user.uid, user.phoneNumber ?? widget.phone);
        if (mounted) context.go('/onboarding');
      } else {
        final onboarded = await FirebaseService().onboardingComplete(user.uid);
        if (mounted) context.go(onboarded ? '/home' : '/onboarding');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP'), backgroundColor: AppColors.kError),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final defaultPinTheme = PinTheme(
      width: 44,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: AppColors.kSurfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.kBorder),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.kYellow),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Text(
                'Enter OTP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'OTP sent to +91 ${widget.phone}',
                style: const TextStyle(color: AppColors.kTextSecondary, fontSize: 16),
              ),
              const SizedBox(height: 40),
              Center(
                child: Pinput(
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyDecorationWith(
                    border: Border.all(color: AppColors.kYellow, width: 2),
                  ),
                  onCompleted: _verify,
                  enabled: !authState.isLoading,
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: _canResend
                    ? TextButton(
                        onPressed: () {
                          // TODO: Resend OTP
                          setState(() {
                            _timerValue = 60;
                            _canResend = false;
                          });
                          _startTimer();
                        },
                        child: const Text('Resend OTP', style: TextStyle(color: AppColors.kYellow)),
                      )
                    : Text(
                        'Resend OTP in $_timerValue s',
                        style: const TextStyle(color: AppColors.kYellow),
                      ),
              ),
              const Spacer(),
              CrewXButton(
                label: 'Verify',
                onPressed: () {
                  // Pinput handles it onCompleted, but here for completeness
                },
                isLoading: authState.isLoading,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
