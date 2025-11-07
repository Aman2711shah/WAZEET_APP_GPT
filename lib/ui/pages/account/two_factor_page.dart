import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TwoFactorPage extends StatefulWidget {
  const TwoFactorPage({super.key});

  @override
  State<TwoFactorPage> createState() => _TwoFactorPageState();
}

class _TwoFactorPageState extends State<TwoFactorPage> {
  bool _isLoading = true;
  List<MultiFactorInfo> _enrolledFactors = [];

  @override
  void initState() {
    super.initState();
    _loadEnrolledFactors();
  }

  Future<void> _loadEnrolledFactors() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        final factors = await user.multiFactor.getEnrolledFactors();
        setState(() {
          _enrolledFactors = factors;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load MFA factors: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _enrollMfa() async {
    final phoneController = TextEditingController();

    // Step 1: Get phone number
    final phone = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Phone Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your phone number with country code:'),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1234567890',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final phone = phoneController.text.trim();
              if (phone.isNotEmpty) {
                Navigator.of(context).pop(phone);
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (phone == null || phone.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'No user signed in';

      // Get MFA session
      final session = await user.multiFactor.getSession();

      // Send verification code
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        multiFactorSession: session,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval on Android
          await _completeEnrollment(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Verification failed: ${e.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          setState(() => _isLoading = false);
          // Show code entry dialog
          await _showCodeDialog(verificationId, phone);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() => _isLoading = false);
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to enroll MFA: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showCodeDialog(String verificationId, String phone) async {
    final codeController = TextEditingController();

    final code = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enter Verification Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('We sent a code to $phone'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Code',
                hintText: '123456',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final code = codeController.text.trim();
              if (code.isNotEmpty) {
                Navigator.of(context).pop(code);
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );

    if (code == null || code.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );

      await _completeEnrollment(credential);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeEnrollment(PhoneAuthCredential credential) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'No user signed in';

      final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
      await user.multiFactor.enroll(assertion, displayName: 'Primary Phone');

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Two-factor authentication enrolled!'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadEnrolledFactors();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete enrollment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unenrollMfa(MultiFactorInfo factor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Two-Factor Authentication'),
        content: Text(
          'Are you sure you want to remove "${factor.displayName ?? 'this factor'}" from your account?\n\n'
          'Your account will be less secure without two-factor authentication.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'No user signed in';

      await user.multiFactor.unenroll(multiFactorInfo: factor);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Two-factor authentication removed'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadEnrolledFactors();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove MFA: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Two-Factor Authentication')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.security,
                          color: Colors.purple[700],
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Secure Your Account',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add an extra layer of security',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'What is 2FA?',
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Two-Factor Authentication (2FA) adds an extra security step when signing in. '
                          'Even if someone knows your password, they won\'t be able to access your account without the second factor.',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Enrolled Factors Section
                  if (_enrolledFactors.isEmpty) ...[
                    Text(
                      'No Authentication Methods',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You haven\'t set up any additional authentication methods yet.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      onPressed: _enrollMfa,
                      icon: const Icon(Icons.add),
                      label: const Text('Add SMS Authentication'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Active Authentication Methods',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    ..._enrolledFactors.map((factor) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[100],
                            child: Icon(
                              Icons.phone_android,
                              color: Colors.green[700],
                            ),
                          ),
                          title: Text(
                            factor.displayName ?? 'SMS Authentication',
                          ),
                          subtitle: Text(
                            'Enrolled: ${DateTime.fromMillisecondsSinceEpoch(factor.enrollmentTimestamp.toInt() * 1000).toString().split(' ')[0]}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _unenrollMfa(factor),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    OutlinedButton.icon(
                      onPressed: _enrollMfa,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Another Method'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Security Tips
                  Text(
                    'Security Tips',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),

                  _SecurityTip(
                    icon: Icons.check_circle_outline,
                    text: 'Use a strong, unique password',
                  ),
                  const SizedBox(height: 8),
                  _SecurityTip(
                    icon: Icons.check_circle_outline,
                    text: 'Enable 2FA for maximum security',
                  ),
                  const SizedBox(height: 8),
                  _SecurityTip(
                    icon: Icons.check_circle_outline,
                    text: 'Keep your recovery codes safe',
                  ),
                  const SizedBox(height: 8),
                  _SecurityTip(
                    icon: Icons.check_circle_outline,
                    text: 'Never share your authentication codes',
                  ),
                ],
              ),
            ),
    );
  }
}

class _SecurityTip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SecurityTip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[700], height: 1.4),
          ),
        ),
      ],
    );
  }
}
