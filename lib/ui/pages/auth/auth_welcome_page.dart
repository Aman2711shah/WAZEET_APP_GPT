import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/color_tokens.dart';
import '../../../services/auth_service.dart';
import 'email_auth_page.dart';
import 'dart:io' show Platform;

const bool kAllowGuest = false; // Toggle guest mode

/// Welcome screen with SSO and email auth options
class AuthWelcomePage extends StatefulWidget {
  const AuthWelcomePage({super.key});

  @override
  State<AuthWelcomePage> createState() => _AuthWelcomePageState();
}

class _AuthWelcomePageState extends State<AuthWelcomePage> {
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithGoogle();
      // Navigation handled by AppRouter
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithApple();
      // Navigation handled by AppRouter
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToEmailAuth({required bool isSignUp}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmailAuthPage(isSignUp: isSignUp),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF8B5CF6).withOpacity(0.15), // Purple tint
              const Color(0xFF6366F1).withOpacity(0.1), // Indigo tint
              const Color(0xFFEC4899).withOpacity(0.05), // Pink tint
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative blur circles
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withOpacity(0.2),
                      const Color(0xFF8B5CF6).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFEC4899).withOpacity(0.15),
                      const Color(0xFFEC4899).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Subtle top overlay to guarantee title contrast on all backgrounds
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 260,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),

                      // App icon with premium gradient and enhanced glow
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          gradient:
                              (Theme.of(
                                    context,
                                  ).extension<AppColors>()?.primaryGradient
                                  as LinearGradient?) ??
                              const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF9333EA),
                                  Color(0xFF7C3AED),
                                  Color(0xFF6366F1),
                                ],
                              ),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF8B5CF6,
                              ).withOpacity(0.6),
                              blurRadius: 60,
                              spreadRadius: 8,
                              offset: const Offset(0, 20),
                            ),
                            BoxShadow(
                              color: const Color(
                                0xFF7C3AED,
                              ).withOpacity(0.4),
                              blurRadius: 90,
                              spreadRadius: 15,
                              offset: const Offset(0, 30),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 2.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.business_center_rounded,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Enhanced title with better contrast
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'WELCOME TO Wazeet',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: -1.0,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.7),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                              Shadow(
                                color: Colors.white.withOpacity(0.5),
                                blurRadius: 24,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Enhanced subtitle with stronger contrast
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Simplify Your Business',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.7),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                              Shadow(
                                color: Colors.white.withOpacity(0.5),
                                blurRadius: 22,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Enhanced auth card with glass morphism
                      Container(
                        padding: const EdgeInsets.all(36),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.98),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF8B5CF6,
                              ).withOpacity(0.15),
                              blurRadius: 50,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 100,
                              spreadRadius: 10,
                              offset: const Offset(0, 30),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Error message
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.shade100,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      color: Colors.red.shade700,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Google sign in button with enhanced design
                            _AuthButton(
                              onPressed: _isLoading
                                  ? null
                                  : _handleGoogleSignIn,
                              backgroundColor: const Color(0xFFF0F4FF),
                              borderColor: const Color(0xFFE0E8FF),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFE0E8FF),
                                        width: 1,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: SvgPicture.asset(
                                      'assets/images/google_g_logo.svg',
                                      width: 18,
                                      height: 18,
                                      fit: BoxFit.contain,
                                      semanticsLabel: 'Google logo',
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1C1C1E),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Apple sign in button (iOS only)
                            if (!kIsWeb && Platform.isIOS) ...[
                              _AuthButton(
                                onPressed: _isLoading
                                    ? null
                                    : _handleAppleSignIn,
                                backgroundColor: const Color(0xFFF0F4FF),
                                borderColor: const Color(0xFFE0E8FF),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.apple_rounded,
                                      size: 24,
                                      color: Color(0xFF1C1C1E),
                                    ),
                                    const SizedBox(width: 14),
                                    const Text(
                                      'Continue with Apple',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1C1C1E),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ] else
                              const SizedBox(height: 20),

                            // Enhanced divider
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.grey.shade300,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.grey.shade300,
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Existing user button
                            _AuthButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => _navigateToEmailAuth(isSignUp: false),
                              backgroundColor: const Color(0xFFF8F9FC),
                              borderColor: const Color(0xFFE5E8F0),
                              child: const Text(
                                'Existing user',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1C1C1E),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Create account button
                            _AuthButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => _navigateToEmailAuth(isSignUp: true),
                              backgroundColor: const Color(0xFFF8F9FC),
                              borderColor: const Color(0xFFE5E8F0),
                              child: const Text(
                                'Create account',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1C1C1E),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),

                            // Continue as guest (if enabled)
                            if (kAllowGuest) ...[
                              const SizedBox(height: 20),
                              TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        // Handle guest mode
                                      },
                                child: Text(
                                  'Continue as guest',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Loading indicator with enhanced styling
                      if (_isLoading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),

                      const SizedBox(height: 20),

                      // Footer legal text with subtle styling
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              height: 1.5,
                              letterSpacing: 0.1,
                            ),
                            children: [
                              const TextSpan(
                                text: 'By continuing, you agree to Wazeet\'s ',
                              ),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () =>
                                      _launchUrl('https://wazet.com/terms'),
                                  child: Text(
                                    'Terms',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.5),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: ' & '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () =>
                                      _launchUrl('https://wazet.com/privacy'),
                                  child: Text(
                                    'Privacy Policy',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.5),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom auth button widget with enhanced styling
class _AuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color? borderColor;

  const _AuthButton({
    required this.onPressed,
    required this.child,
    required this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: (borderColor ?? backgroundColor).withValues(
                    alpha: 0.15,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.black87,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: 1.5)
                : BorderSide.none,
          ),
          disabledBackgroundColor: backgroundColor.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: child,
      ),
    );
  }
}
