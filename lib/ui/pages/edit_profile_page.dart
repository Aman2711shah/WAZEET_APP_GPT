import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  late TextEditingController _emailController;
  // Title is now a dropdown selection
  String? _selectedTitle;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _designationController;
  late TextEditingController _qualificationController;
  String _selectedCountryCode = '+971';
  bool _isUploadingImage = false;

  // Preset titles
  static const List<String> _titles = <String>[
    'Founder',
    'CEO',
    'Entrepreneur',
    'Manager',
    'Consultant',
    'Freelancer',
  ];

  // Minimal country list with flags
  static const List<Map<String, String>> _countries = [
    {'flag': '🇦🇪', 'code': '+971', 'name': 'United Arab Emirates'},
    {'flag': '🇺🇸', 'code': '+1', 'name': 'United States'},
    {'flag': '🇬🇧', 'code': '+44', 'name': 'United Kingdom'},
    {'flag': '🇮🇳', 'code': '+91', 'name': 'India'},
    {'flag': '🇸🇬', 'code': '+65', 'name': 'Singapore'},
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: profile?.name ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    // Title selection
    _selectedTitle = _titles.contains(profile?.title) ? profile?.title : null;
    _bioController = TextEditingController(text: profile?.bio ?? '');
    // Phone & country code: try to infer from saved phone/countryCode
    final savedPhone = profile?.phone ?? '';
    final savedCode = profile?.countryCode;
    if (savedCode != null && _countries.any((c) => c['code'] == savedCode)) {
      _selectedCountryCode = savedCode;
    } else {
      // Try match code prefix from phone
      for (final c in _countries) {
        final code = c['code']!;
        if (savedPhone.startsWith(code)) {
          _selectedCountryCode = code;
          break;
        }
      }
    }
    // Remove code from the editing phone field if present
    String phoneWithoutCode = savedPhone;
    if (phoneWithoutCode.startsWith(_selectedCountryCode)) {
      phoneWithoutCode = phoneWithoutCode
          .substring(_selectedCountryCode.length)
          .trim();
    }
    _phoneController = TextEditingController(text: phoneWithoutCode);
    _designationController = TextEditingController(
      text: profile?.designation ?? '',
    );
    _qualificationController = TextEditingController(
      text: profile?.qualification ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _designationController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      // Pick image file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;

      // Validate file size (max 5MB)
      if (file.size > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image size must be less than 5MB'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() => _isUploadingImage = true);

      final profile = ref.read(userProfileProvider);
      if (profile == null) return;

      // Upload to Firebase Storage
      final fileName =
          '${profile.id}_${DateTime.now().millisecondsSinceEpoch}.${file.extension}';
      final storageRef = FirebaseStorage.instance.ref().child(
        'profile_pictures/$fileName',
      );

      // Upload file bytes
      if (file.bytes != null) {
        await storageRef.putData(
          file.bytes!,
          SettableMetadata(contentType: 'image/${file.extension}'),
        );

        // Get download URL
        final downloadUrl = await storageRef.getDownloadURL();

        // Update profile with new photo URL
        await ref
            .read(userProfileProvider.notifier)
            .updateProfile(photoUrl: downloadUrl);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(userProfileProvider.notifier);

    // Build full phone with country code
    String? fullPhone;
    final phoneTrim = _phoneController.text.trim();
    if (phoneTrim.isNotEmpty) {
      fullPhone = '$_selectedCountryCode $phoneTrim';
    }

    await notifier.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      title: _selectedTitle,
      bio: _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
      phone: fullPhone,
      countryCode: _selectedCountryCode,
      designation: _designationController.text.trim().isEmpty
          ? null
          : _designationController.text.trim(),
      qualification: _qualificationController.text.trim().isEmpty
          ? null
          : _qualificationController.text.trim(),
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
                    backgroundColor: AppColors.purple.withValues(alpha: 0.1),
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
                  if (_isUploadingImage)
                    Positioned.fill(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.black54,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.purple,
                      child: IconButton(
                        icon: Icon(
                          _isUploadingImage
                              ? Icons.hourglass_empty
                              : Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                        onPressed: _isUploadingImage
                            ? null
                            : _pickAndUploadImage,
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

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                // Basic email validation
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Title/Position (Dropdown)
            DropdownButtonFormField<String>(
              initialValue: _selectedTitle,
              items: _titles
                  .map(
                    (t) => DropdownMenuItem<String>(value: t, child: Text(t)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedTitle = v),
              decoration: const InputDecoration(
                labelText: 'Title/Position',
                hintText: 'Select your title',
                prefixIcon: Icon(Icons.work_outline),
                suffixIcon: Icon(Icons.keyboard_arrow_down),
              ),
            ),
            const SizedBox(height: 16),

            // Phone with country code dropdown
            Row(
              children: [
                // Country dropdown (flat style)
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 0.8,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCountryCode,
                      isDense: true,
                      onChanged: (v) =>
                          setState(() => _selectedCountryCode = v ?? '+971'),
                      items: _countries
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c['code'],
                              child: Row(
                                children: [
                                  Text(c['flag']!),
                                  const SizedBox(width: 6),
                                  Text(c['code']!),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '50 123 4567',
                      helperText: 'Format: 50 123 4567 (without country code)',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        // Remove spaces for validation
                        final phone = value.replaceAll(' ', '');
                        // Check if it's a valid number (7-10 digits)
                        if (phone.length < 7 || phone.length > 10) {
                          return 'Please enter a valid phone number';
                        }
                        // Check if it contains only digits
                        if (!RegExp(r'^\d+$').hasMatch(phone)) {
                          return 'Phone number should contain only digits';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // About Me (Bio)
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'About Me',
                hintText: 'Tell us about yourself...',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              maxLength: 500,
            ),

            const SizedBox(height: 16),

            // Designation (Optional)
            TextFormField(
              controller: _designationController,
              decoration: const InputDecoration(
                labelText: 'Designation (Optional)',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Qualification (Optional)
            TextFormField(
              controller: _qualificationController,
              decoration: const InputDecoration(
                labelText: 'Qualification (Optional)',
                prefixIcon: Icon(Icons.school_outlined),
              ),
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
