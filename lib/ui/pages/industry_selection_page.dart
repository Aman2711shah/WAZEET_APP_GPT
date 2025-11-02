import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_profile.dart';
import '../../providers/user_profile_provider.dart';
import '../theme.dart';

class IndustrySelectionPage extends ConsumerStatefulWidget {
  const IndustrySelectionPage({super.key});

  @override
  ConsumerState<IndustrySelectionPage> createState() =>
      _IndustrySelectionPageState();
}

class _IndustrySelectionPageState extends ConsumerState<IndustrySelectionPage> {
  final Set<String> _selectedIndustries = {};

  @override
  void initState() {
    super.initState();
    // Load current user's industries
    Future.microtask(() {
      final user = ref.read(userProfileProvider);
      if (user != null) {
        setState(() {
          _selectedIndustries.addAll(user.industries);
        });
      }
    });
  }

  void _toggleIndustry(String industryId) {
    setState(() {
      if (_selectedIndustries.contains(industryId)) {
        _selectedIndustries.remove(industryId);
      } else {
        _selectedIndustries.add(industryId);
      }
    });
  }

  void _savePreferences() {
    final user = ref.read(userProfileProvider);
    if (user != null) {
      final updatedUser = user.copyWith(
        industries: _selectedIndustries.toList(),
      );
      ref.read(userProfileProvider.notifier).updateUser(updatedUser);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Industry preferences saved! 🎯')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Your Industries'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.purple.withValues(alpha: 0.1)),
            child: Column(
              children: [
                Icon(Icons.business_center, size: 48, color: AppColors.purple),
                const SizedBox(height: 12),
                const Text(
                  'Choose Your Industries',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select industries you\'re interested in to personalize your feed',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_selectedIndustries.length} selected',
                  style: TextStyle(
                    color: AppColors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Industry List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: availableIndustries.length,
              itemBuilder: (context, index) {
                final industry = availableIndustries[index];
                final isSelected = _selectedIndustries.contains(industry.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isSelected ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.purple
                          : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _toggleIndustry(industry.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.purple.withValues(alpha: 0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                industry.icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  industry.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? AppColors.purple
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  industry.description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Checkbox
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.purple,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            )
                          else
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Save Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedIndustries.isEmpty
                      ? null
                      : _savePreferences,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: Text(
                    _selectedIndustries.isEmpty
                        ? 'Select at least one industry'
                        : 'Save Preferences',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
