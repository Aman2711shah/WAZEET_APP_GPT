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
  late TextEditingController _phoneController;
  late TextEditingController _companyController;
  String _selectedCountryCode = '+971';
  bool _isUploadingImage = false;

  // Preset titles
  // Expanded common job/role titles (approx 60) for better variety
  static const List<String> _titles = <String>[
    'Founder',
    'Co-Founder',
    'CEO',
    'President',
    'Managing Director',
    'General Manager',
    'Chief Operating Officer',
    'COO',
    'Chief Technology Officer',
    'CTO',
    'Chief Marketing Officer',
    'CMO',
    'Chief Financial Officer',
    'CFO',
    'Chief Product Officer',
    'CPO',
    'Chief Strategy Officer',
    'Chief Revenue Officer',
    'Vice President',
    'VP of Engineering',
    'VP of Product',
    'VP of Sales',
    'Director of Engineering',
    'Director of Product',
    'Director of Marketing',
    'Director of Sales',
    'Product Manager',
    'Senior Product Manager',
    'Associate Product Manager',
    'Project Manager',
    'Program Manager',
    'Operations Manager',
    'Business Development Manager',
    'Marketing Manager',
    'Sales Manager',
    'Finance Manager',
    'HR Manager',
    'Recruiter',
    'Talent Acquisition Specialist',
    'Software Engineer',
    'Senior Software Engineer',
    'Frontend Developer',
    'Backend Developer',
    'Full Stack Developer',
    'Mobile Developer',
    'Data Scientist',
    'Data Analyst',
    'UX Designer',
    'UI Designer',
    'UX/UI Designer',
    'Graphic Designer',
    'Content Strategist',
    'Copywriter',
    'Digital Marketing Specialist',
    'SEO Specialist',
    'Social Media Manager',
    'Customer Success Manager',
    'Account Manager',
    'Consultant',
    'Strategy Consultant',
    'Management Consultant',
    'Entrepreneur',
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
    // Bio field removed from edit screen (retain existing value silently)
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
    _companyController = TextEditingController(text: profile?.company ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
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

      // Ask user to confirm before uploading
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Use this photo?'),
            content: file.bytes != null
                ? Image.memory(file.bytes!, height: 160, fit: BoxFit.cover)
                : const Text('Preview not available'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
      if (confirmed != true) return; // user cancelled

      setState(() => _isUploadingImage = true);
      final profile = ref.read(userProfileProvider);
      if (profile == null) return;
      final fileName =
          '${profile.id}_${DateTime.now().millisecondsSinceEpoch}.${file.extension}';
      final storageRef = FirebaseStorage.instance.ref().child(
        'profile_pictures/${profile.id}/$fileName',
      );
      if (file.bytes != null) {
        await storageRef.putData(
          file.bytes!,
          SettableMetadata(contentType: 'image/${file.extension}'),
        );
        final downloadUrl = await storageRef.getDownloadURL();
        await ref
            .read(userProfileProvider.notifier)
            .updateProfile(photoUrl: downloadUrl);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Profile picture updated. Tap Save to confirm other changes.',
              ),
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
      // Bio not editable here; omit parameter to keep existing value
      phone: fullPhone,
      countryCode: _selectedCountryCode,
      company: _companyController.text.trim().isEmpty
          ? null
          : _companyController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
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

            // Phone with country code and number (equal sizing)
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCountryCode,
                    decoration: const InputDecoration(
                      labelText: 'Code',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
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
                    onChanged: (v) =>
                        setState(() => _selectedCountryCode = v ?? '+971'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'XX XXX XXXX',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Company Name (replaces designation field)
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Company Name',
                hintText: 'Your company or employer',
                prefixIcon: Icon(Icons.business_outlined),
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
