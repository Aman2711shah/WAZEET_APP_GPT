import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme.dart';
import '../../../services/auth_service.dart';

/// Email verification page shown after sign up
class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _authService = AuthService();
  Timer? _pollingTimer;
  bool _isCheckingVerification = false;
  bool _isResending = false;
  String? _message;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    // Start polling for verification status every 10 seconds
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkVerification(silent: true);
    });
  }

  Future<void> _checkVerification({bool silent = false}) async {
    if (_isCheckingVerification) return;

    if (!silent) {
      setState(() {
        _isCheckingVerification = true;
        _message = null;
      });
    }

    try {
      await _authService.reloadUser();
      final user = _authService.currentUser;

      if (user != null && user.emailVerified) {
        // Email verified - navigation will be handled by AppRouter
        _pollingTimer?.cancel();
        if (!silent && mounted) {
          setState(() {
            _message = 'Email verified successfully!';
            _isError = false;
          });
        }
      } else if (!silent && mounted) {
        setState(() {
          _message = 'Email not yet verified. Please check your inbox.';
          _isError = true;
        });
      }
    } catch (e) {
      if (!silent && mounted) {
        setState(() {
          _message = 'Failed to check verification status. Please try again.';
          _isError = true;
        });
      }
    } finally {
      if (!silent && mounted) {
        setState(() {
          _isCheckingVerification = false;
        });
      }
    }
  }

  Future<void> _resendVerification() async {
    if (_isResending) return;

    setState(() {
      _isResending = true;
      _message = null;
    });

    try {
      await _authService.resendEmailVerification();
      if (mounted) {
        setState(() {
          _message = 'Verification email sent! Please check your inbox.';
          _isError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = e.toString();
          _isError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _openMailApp() async {
    final mailtoUri = Uri(scheme: 'mailto');
    try {
      if (await canLaunchUrl(mailtoUri)) {
        await launchUrl(mailtoUri);
      } else {
        setState(() {
          _message = 'Could not open mail app';
          _isError = true;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Could not open mail app';
        _isError = true;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      // Navigation handled by AppRouter
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = e.toString();
          _isError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _signOut,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Envelope icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientHeader,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Check your email',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1C1E),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Subtitle
                Text(
                  'We sent a verification link to',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 4),

                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.purple,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Click the link in the email to verify your account.',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Message display
                if (_message != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isError
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isError
                              ? Icons.error_outline
                              : Icons.check_circle_outline,
                          color: _isError
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _message!,
                            style: TextStyle(
                              color: _isError
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Container with action buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Resend verification button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isResending ? null : _resendVerification,
                          icon: _isResending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(
                            _isResending ? 'Sending...' : 'Resend verification',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            disabledBackgroundColor: AppColors.purple
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Open mail app button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _openMailApp,
                          icon: const Icon(Icons.mail_outline),
                          label: const Text('Open Mail'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.purple,
                            side: const BorderSide(color: AppColors.purple),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Check verification button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _isCheckingVerification
                              ? null
                              : () => _checkVerification(silent: false),
                          icon: _isCheckingVerification
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: Text(
                            _isCheckingVerification
                                ? 'Checking...'
                                : 'I\'ve verified - Continue',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.purple,
                            side: const BorderSide(color: AppColors.purple),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Help text
                Text(
                  'Didn\'t receive the email? Check your spam folder or try resending.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Sign out button
                TextButton(
                  onPressed: _signOut,
                  child: const Text(
                    'Sign out',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
