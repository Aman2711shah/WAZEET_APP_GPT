import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../../services/auth_service.dart';

/// Email authentication page for sign in and sign up
class EmailAuthPage extends StatefulWidget {
  final bool isSignUp;

  const EmailAuthPage({super.key, required this.isSignUp});

  @override
  State<EmailAuthPage> createState() => _EmailAuthPageState();
}

class _EmailAuthPageState extends State<EmailAuthPage> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String _selectedCountryCode = '+1';

  // Common country codes
  final List<Map<String, String>> _countryCodes = [
    {'code': '+1', 'country': 'US/CA'},
    {'code': '+44', 'country': 'UK'},
    {'code': '+91', 'country': 'IN'},
    {'code': '+61', 'country': 'AU'},
    {'code': '+81', 'country': 'JP'},
    {'code': '+86', 'country': 'CN'},
    {'code': '+49', 'country': 'DE'},
    {'code': '+33', 'country': 'FR'},
    {'code': '+39', 'country': 'IT'},
    {'code': '+34', 'country': 'ES'},
    {'code': '+55', 'country': 'BR'},
    {'code': '+52', 'country': 'MX'},
    {'code': '+7', 'country': 'RU'},
    {'code': '+82', 'country': 'KR'},
    {'code': '+971', 'country': 'AE'},
    {'code': '+966', 'country': 'SA'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.isSignUp) {
        await _authService.signUpWithEmail(
          _emailController.text,
          _passwordController.text,
        );
        // Navigation handled by AppRouter (will show VerifyEmailPage)
      } else {
        await _authService.signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
        // Navigation handled by AppRouter
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      }
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

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }
    // Remove spaces and special characters for validation
    final digits = value.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.length < 10) {
      return 'Please enter a valid mobile number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (widget.isSignUp && value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
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
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Back button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black87,
                              size: 28,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Title
                        Text(
                          widget.isSignUp ? 'Create an account' : 'Sign in',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1C1E),
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          widget.isSignUp
                              ? 'Enter your details to get started'
                              : 'Welcome back! Sign in to continue',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            letterSpacing: 0.2,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Form container with glass morphism effect
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                blurRadius: 40,
                                spreadRadius: 0,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 80,
                                spreadRadius: 0,
                                offset: const Offset(0, 30),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Error message with enhanced styling
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFFFE5E5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline_rounded,
                                        color: Color(0xFFDC2626),
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(
                                            color: Color(0xFFDC2626),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                              // Name field (sign up only)
                              if (widget.isSignUp) ...[
                                TextFormField(
                                  controller: _nameController,
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.name],
                                  validator: _validateName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    hintText: 'Your full name',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    labelStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person_outline_rounded,
                                      color: Colors.grey.shade600,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: AppColors.purple,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFDC2626),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFDC2626),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFB),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                              ],

                              // Mobile Number field (sign up only)
                              if (widget.isSignUp) ...[
                                TextFormField(
                                  controller: _mobileController,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.telephoneNumber,
                                  ],
                                  validator: _validateMobile,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Mobile Number',
                                    hintText: '(555) 123-4567',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    labelStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    prefixIcon: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.phone_outlined,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 8),
                                          DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: _selectedCountryCode,
                                              isDense: true,
                                              icon: Icon(
                                                Icons.arrow_drop_down,
                                                color: Colors.grey.shade600,
                                                size: 20,
                                              ),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade800,
                                              ),
                                              items: _countryCodes.map((
                                                country,
                                              ) {
                                                return DropdownMenuItem<String>(
                                                  value: country['code'],
                                                  child: Text(country['code']!),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedCountryCode = value!;
                                                });
                                              },
                                            ),
                                          ),
                                          Container(
                                            height: 24,
                                            width: 1,
                                            color: Colors.grey.shade300,
                                            margin: const EdgeInsets.only(
                                              left: 8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: AppColors.purple,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFDC2626),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFDC2626),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFB),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                              ],

                              // Email field with enhanced styling
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                validator: _validateEmail,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'E-mail ID',
                                  hintText: 'you@example.com',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Colors.grey.shade600,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: AppColors.purple,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFDC2626),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFDC2626),
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 18,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // Password field with enhanced styling
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: widget.isSignUp
                                    ? TextInputAction.next
                                    : TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                validator: _validatePassword,
                                onFieldSubmitted: (_) {
                                  if (!widget.isSignUp) _handleSubmit();
                                },
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Enter Password',
                                  hintText: '••••••••',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: Colors.grey.shade600,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: Colors.grey.shade600,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: AppColors.purple,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFDC2626),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFDC2626),
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 18,
                                  ),
                                ),
                              ),

                              // Confirm password field (sign up only)
                              if (widget.isSignUp) ...[
                                const SizedBox(height: 18),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  textInputAction: TextInputAction.done,
                                  validator: _validateConfirmPassword,
                                  onFieldSubmitted: (_) => _handleSubmit(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Re-enter Password',
                                    hintText: '••••••••',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    labelStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline_rounded,
                                      color: Colors.grey.shade600,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        color: Colors.grey.shade600,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: AppColors.purple,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFDC2626),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFDC2626),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFB),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 18,
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 32),

                              // Submit button with gradient and glow effect
                              Container(
                                width: double.infinity,
                                height: 58,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: _isLoading
                                      ? null
                                      : const LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Color(0xFF9333EA),
                                            Color(0xFF7C3AED),
                                          ],
                                        ),
                                  boxShadow: _isLoading
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF8B5CF6,
                                            ).withOpacity(0.4),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleSubmit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    disabledBackgroundColor: AppColors.purple
                                        .withOpacity(0.6),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          widget.isSignUp
                                              ? 'Create an account'
                                              : 'Sign in',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Toggle sign in/sign up with enhanced styling
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.isSignUp
                                        ? 'Already have an account? '
                                        : 'Don\'t have an account? ',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                            Navigator.of(
                                              context,
                                            ).pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EmailAuthPage(
                                                      isSignUp:
                                                          !widget.isSignUp,
                                                    ),
                                              ),
                                            );
                                          },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      widget.isSignUp
                                          ? 'Sign in'
                                          : 'Create an account',
                                      style: const TextStyle(
                                        color: AppColors.purple,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.purple,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
