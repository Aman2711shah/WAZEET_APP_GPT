import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_profile_provider.dart';
import '../theme.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: profile?.name ?? '');
    _titleController = TextEditingController(text: profile?.title ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(userProfileProvider.notifier);

    await notifier.updateProfile(
      name: _nameController.text.trim(),
      title: _titleController.text.trim().isEmpty
          ? null
          : _titleController.text.trim(),
      bio: _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(onPressed: _saveProfile, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile photo section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profile?.photoUrl != null
                        ? NetworkImage(profile!.photoUrl!)
                        : null,
                    child: profile?.photoUrl == null
                        ? Text(
                            profile?.name.isNotEmpty == true
                                ? profile!.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(fontSize: 32),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.purple,
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // TODO: Implement image picker
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Image picker coming soon!'),
                            ),
                          );
                        },
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email (read-only)
            TextFormField(
              initialValue: profile?.email ?? '',
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                enabled: false,
              ),
            ),
            const SizedBox(height: 16),

            // Title/Position
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title/Position',
                hintText: 'e.g., Entrepreneur',
                prefixIcon: Icon(Icons.work_outline),
              ),
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+971 XX XXX XXXX',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Bio
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell us about yourself...',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
