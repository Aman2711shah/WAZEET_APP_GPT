import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class TwoFactorPage extends StatefulWidget {
  const TwoFactorPage({super.key});

  @override
  State<TwoFactorPage> createState() => _TwoFactorPageState();
}

class _TwoFactorPageState extends State<TwoFactorPage> {
  final _authService = AuthService();
  bool _isLoading = true;
  List<dynamic> _enrolledFactors = [];

  @override
  void initState() {
    super.initState();
    _loadEnrolledFactors();
  }

  Future<void> _loadEnrolledFactors() async {
    setState(() => _isLoading = true);
    try {
      final factors = await _authService.getEnrolledMfaFactors();
      setState(() {
        _enrolledFactors = factors;
        _isLoading = false;
      });
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
    // For now, show a message that this is coming soon
    // Full implementation requires phone number verification flow
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text(
          'SMS-based Two-Factor Authentication enrollment will be available in a future update.\n\n'
          'This feature requires additional Firebase configuration and phone number verification.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _unenrollMfa(String factorUid, String displayName) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Two-Factor Authentication'),
        content: Text(
          'Are you sure you want to remove "$displayName" from your account?\n\n'
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
      await _authService.unenrollMfa(factorUid);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove MFA: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
                    // No factors enrolled
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

                    // Enroll Button
                    OutlinedButton.icon(
                      onPressed: _enrollMfa,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Authentication Method'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Factors enrolled
                    Text(
                      'Active Authentication Methods',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // List of enrolled factors
                    ..._enrolledFactors.map((factor) {
                      final displayName =
                          factor.displayName ?? 'Unnamed Factor';
                      final factorId = factor.factorId ?? 'unknown';
                      final enrollmentDate = factor.enrollmentTime != null
                          ? DateTime.fromMillisecondsSinceEpoch(
                              factor.enrollmentTime! * 1000,
                            )
                          : null;

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
                          title: Text(displayName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Type: ${factorId.toUpperCase()}'),
                              if (enrollmentDate != null)
                                Text(
                                  'Added: ${enrollmentDate.year}-${enrollmentDate.month.toString().padLeft(2, '0')}-${enrollmentDate.day.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                _unenrollMfa(factor.uid, displayName),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Add another button
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
