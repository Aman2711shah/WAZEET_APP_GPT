import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../services/auth_service.dart';

class DeleteAccountConfirmSheet extends StatefulWidget {
  const DeleteAccountConfirmSheet({super.key});

  @override
  State<DeleteAccountConfirmSheet> createState() =>
      _DeleteAccountConfirmSheetState();
}

class _DeleteAccountConfirmSheetState extends State<DeleteAccountConfirmSheet> {
  final _authService = AuthService();
  final _passwordController = TextEditingController();
  bool _isDeleting = false;
  bool _obscurePassword = true;
  bool _confirmChecked = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (!_confirmChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm you understand this action'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isDeleting = true);

    try {
      // Step 1: Reauthenticate if using password
      final isPasswordProvider = user.providerData.any(
        (info) => info.providerId == 'password',
      );

      if (isPasswordProvider) {
        final password = _passwordController.text.trim();
        if (password.isEmpty) {
          throw 'Please enter your password to confirm';
        }
        await _authService.reauthenticateWithPassword(password);
      } else {
        // For social providers, reauthenticate with their flow
        final providerId = user.providerData.first.providerId;
        if (providerId == 'google.com') {
          await _authService.reauthenticateWithGoogle();
        } else if (providerId == 'apple.com') {
          await _authService.reauthenticateWithApple();
        }
      }

      // Step 2: Call Cloud Function to delete user data
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('deleteUserData');
      await callable.call();

      // Step 3: Delete the Firebase Auth user
      await user.delete();

      // Step 4: Navigate to welcome page
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account has been permanently deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isPasswordProvider =
        user?.providerData.any((info) => info.providerId == 'password') ??
        false;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.warning_outlined,
                    color: Colors.red[700],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delete Account',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'This action cannot be undone',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Warning Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The following will be permanently deleted:',
                    style: TextStyle(
                      color: Colors.red[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DeleteItem('Your profile and account information'),
                  _DeleteItem('All your preferences and settings'),
                  _DeleteItem('Your activity history'),
                  _DeleteItem('Uploaded files and media'),
                  _DeleteItem('All associated data'),
                  const SizedBox(height: 12),
                  Text(
                    'This action is immediate and cannot be reversed.',
                    style: TextStyle(
                      color: Colors.red[900],
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Password field for email/password users
            if (isPasswordProvider) ...[
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Confirm your password',
                  hintText: 'Enter your password to proceed',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Confirmation Checkbox
            CheckboxListTile(
              value: _confirmChecked,
              onChanged: (value) {
                setState(() {
                  _confirmChecked = value ?? false;
                });
              },
              title: const Text(
                'I understand this action is permanent and cannot be undone',
                style: TextStyle(fontSize: 14),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isDeleting
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isDeleting ? null : _deleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isDeleting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Delete Account'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteItem extends StatelessWidget {
  final String text;

  const _DeleteItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.close, size: 18, color: Colors.red[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.red[900],
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to show the delete account sheet
Future<void> showDeleteAccountSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const DeleteAccountConfirmSheet(),
  );
}
