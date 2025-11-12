import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/service_item.dart';
import '../../models/service_tier.dart';
import '../../services/tier_rules.dart';
import '../theme.dart';
import '../widgets/tier_selector.dart';
import 'applications_page.dart';
import '../../providers/user_activity_provider.dart';
import '../../models/user_activity.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/payment_utils.dart';

class SubServiceDetailPage extends ConsumerStatefulWidget {
  final SubService subService;
  final String serviceTypeName;
  final String categoryIcon;

  const SubServiceDetailPage({
    super.key,
    required this.subService,
    required this.serviceTypeName,
    required this.categoryIcon,
  });

  @override
  ConsumerState<SubServiceDetailPage> createState() =>
      _SubServiceDetailPageState();
}

class _SubServiceDetailPageState extends ConsumerState<SubServiceDetailPage> {
  late ServiceTier _selectedTier;
  late TierPair _tiers;
  final Map<String, PlatformFile?> _uploadedFiles = {};
  final Map<String, bool> _uploadingStatus = {};
  final Map<String, String> _uploadedUrls = {};
  // Pre-upload details (Step 1) state
  final GlobalKey<FormState> _detailsFormKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  Map<String, dynamic> _preUploadDetails = {};
  bool _detailsCompleted = false;
  int _currentUploadStep = 0; // 0: details, 1: uploads
  bool _bottomSheetActive = false;
  bool _submitting = false; // prevent double submit & show progress

  @override
  void initState() {
    super.initState();
    // Parse existing timeline to extract base days
    final premiumTimeline = widget.subService.premium.timeline;

    // Extract days from timeline strings like "7-10 days" or "5 days"
    final premiumDays = _parseTimeline(premiumTimeline);

    // Calculate base timeline from premium (since it's faster)
    // Reverse-engineer the base from the premium timeline
    final baseMinDays = premiumDays.min + kPremiumMinusMin;
    final baseMaxDays =
        premiumDays.max +
        kPremiumMinusMax; // Build tiers with proper adjustments
    _tiers = buildTiers(
      standardName: 'Standard',
      premiumName: 'Premium',
      baseMinDays: baseMinDays,
      baseMaxDays: baseMaxDays,
      standardPrice: _parsePrice(widget.subService.standardCostDisplay),
      premiumPrice: _parsePrice(widget.subService.premiumCostDisplay),
    );

    _selectedTier = _tiers.standard;
  }

  /// Parse timeline string like "7-10 days" or "5 days" to extract min/max
  ({int min, int max}) _parseTimeline(String timeline) {
    final numbers = RegExp(
      r'\d+',
    ).allMatches(timeline).map((m) => int.parse(m.group(0)!)).toList();
    if (numbers.isEmpty) return (min: 5, max: 7); // fallback
    if (numbers.length == 1) return (min: numbers[0], max: numbers[0]);
    return (min: numbers[0], max: numbers[1]);
  }

  /// Parse price string like "AED 2000" to extract number
  int _parsePrice(String priceStr) {
    final match = RegExp(r'\d+').firstMatch(priceStr);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            // Reduced header height for a more compact sub-service detail view
            // Previously used Responsive.heroHeight which was quite tall.
            // Choose a smaller adaptive value capped at 180.
            expandedHeight: () {
              final h = MediaQuery.of(context).size.height;
              return h < 600 ? 150.0 : 170.0; // simple adaptive heuristic
            }(),
            backgroundColor: AppColors.purple,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            elevation: 4,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final settings = context
                    .dependOnInheritedWidgetOfExactType<
                      FlexibleSpaceBarSettings
                    >();
                final collapsed =
                    settings != null &&
                    settings.currentExtent <= settings.minExtent + 2;
                return FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: !collapsed
                      ? Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF6200EE),
                                Color(0xFF7E3FF2),
                                Color(0xFF9D4EDD),
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withValues(alpha: 0.12),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.4],
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 32,
                                    bottom: 20,
                                    right: 16,
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.25,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.35,
                                              ),
                                              blurRadius: 18,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.description,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          widget.subService.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 22,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                  title: collapsed
                      ? Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.description,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.subService.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )
                      : null,
                  centerTitle: false,
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              getIconData(widget.categoryIcon),
                              color: AppColors.purple,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.serviceTypeName,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.subService.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description (if available)
                  if (widget.subService.description != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.purple,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.subService.description!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Pricing Tier Selection with shared component
                  TierSelector(
                    standardTier: _tiers.standard,
                    premiumTier: _tiers.premium,
                    initialTier: _selectedTier,
                    onChanged: (tier) {
                      setState(() {
                        _selectedTier = tier;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Service Details
                  _buildSectionTitle('Service Details'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.payment,
                            label: 'Price',
                            value: _selectedTier.priceLabel,
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            icon: Icons.schedule,
                            label: 'Processing Time',
                            value: _selectedTier.daysLabel,
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            icon: Icons.description,
                            label: 'Documents Required',
                            value:
                                '${widget.subService.documentRequirements.length} items',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Document Requirements
                  _buildSectionTitle('Required Documents'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: widget.subService.documentRequirements
                            .map(
                              (doc) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: AppColors.purple,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        doc,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.check_circle_outline,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Additional Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.purple),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'All documents must be original or attested copies. Processing times may vary based on government working days.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => _showDocumentUpload(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              ctaLabel(_selectedTier),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.purple, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDocumentUpload(BuildContext context) {
    _currentUploadStep = _detailsCompleted ? 1 : 0;
    _bottomSheetActive = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Use persistent field instead of local var so step isn't reset on setState
          if (_detailsCompleted && _currentUploadStep == 0) {
            _currentUploadStep =
                1; // ensure progression keeps after parent rebuilds
          }
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Text(
                        _currentUploadStep == 0
                            ? 'Provide Details'
                            : 'Upload Documents',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_currentUploadStep == 1)
                        TextButton.icon(
                          onPressed: () {
                            setModalState(() {
                              _currentUploadStep = 0;
                            });
                          },
                          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                          label: const Text('Back'),
                        ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                if (_currentUploadStep == 0)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: _detailsFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Please provide a few details to proceed',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _fullNameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Full name is required'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                final emailRegex = RegExp(
                                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                );
                                if (!emailRegex.hasMatch(v.trim())) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Phone is required'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _nationalityController,
                              decoration: const InputDecoration(
                                labelText: 'Nationality',
                                prefixIcon: Icon(Icons.flag_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Nationality is required'
                                  : null,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_currentUploadStep == 0)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_detailsFormKey.currentState?.validate() ?? false) {
                          setState(() {
                            _preUploadDetails = {
                              'fullName': _fullNameController.text.trim(),
                              'email': _emailController.text.trim(),
                              'phone': _phoneController.text.trim(),
                              'nationality': _nationalityController.text.trim(),
                            };
                            _detailsCompleted = true;
                          });
                          setModalState(() {
                            _currentUploadStep = 1;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Continue to Uploads',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (_currentUploadStep == 1)
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: widget.subService.documentRequirements.length,
                      itemBuilder: (context, index) {
                        final doc =
                            widget.subService.documentRequirements[index];
                        final isUploading = _uploadingStatus[doc] ?? false;
                        final isUploaded = _uploadedFiles[doc] != null;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: isUploading ? 4 : 1,
                          child: InkWell(
                            onTap: isUploading
                                ? null
                                : () => _pickAndUploadFile(doc, setModalState),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isUploaded
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : AppColors.purple.withValues(
                                            alpha: 0.1,
                                          ),
                                    child: isUploading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    AppColors.purple,
                                                  ),
                                            ),
                                          )
                                        : Icon(
                                            isUploaded
                                                ? Icons.check_circle
                                                : Icons.upload_file,
                                            color: isUploaded
                                                ? Colors.green
                                                : AppColors.purple,
                                            size: 24,
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doc,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isUploaded
                                              ? _uploadedFiles[doc]!.name
                                              : 'Tap to upload (PDF, JPG, PNG, DOC)',
                                          style: TextStyle(
                                            color: isUploaded
                                                ? Colors.green
                                                : Colors.grey,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isUploaded)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setModalState(() {
                                          _uploadedFiles.remove(doc);
                                          _uploadedUrls.remove(doc);
                                        });
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      },
                                    )
                                  else if (!isUploading)
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey.shade400,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (_currentUploadStep == 1)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: _uploadedFiles.isEmpty || _submitting
                          ? null
                          : () => _submitRequest(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              _uploadedFiles.isEmpty
                                  ? 'Upload at least one document'
                                  : 'Submit Request (${_uploadedFiles.length}/${widget.subService.documentRequirements.length} uploaded)',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          _bottomSheetActive = false;
          _submitting = false;
        });
      }
    });
  }

  Future<void> _pickAndUploadFile(
    String documentName,
    StateSetter setModalState,
  ) async {
    try {
      // Pick file with web-compatible settings
      if (!_bottomSheetActive) return;
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: false,
        withData: true, // Important for web - loads file data
        withReadStream: false, // Disable stream for web compatibility
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Check if file data is available
        if (file.bytes == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not read file. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Validate file size (max 10MB)
        if (file.size > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size must be less than 10MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (!_bottomSheetActive) return;
        setModalState(() {
          _uploadingStatus[documentName] = true;
        });
        if (mounted) {
          setState(() {});
        }

        // Upload to Firebase Storage
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        final storageRef = FirebaseStorage.instance.ref().child(
          'service_documents/${widget.subService.id}/$fileName',
        );

        // Determine content type
        String contentType = 'application/octet-stream';
        final extension = file.extension?.toLowerCase();
        if (extension == 'pdf') {
          contentType = 'application/pdf';
        } else if (extension == 'jpg' || extension == 'jpeg') {
          contentType = 'image/jpeg';
        } else if (extension == 'png') {
          contentType = 'image/png';
        } else if (extension == 'doc') {
          contentType = 'application/msword';
        } else if (extension == 'docx') {
          contentType =
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        }

        // Upload file bytes
        await storageRef.putData(
          file.bytes!,
          SettableMetadata(contentType: contentType),
        );

        // Get download URL
        final downloadUrl = await storageRef.getDownloadURL();

        if (_bottomSheetActive) {
          setModalState(() {
            _uploadedFiles[documentName] = file;
            _uploadedUrls[documentName] = downloadUrl;
            _uploadingStatus[documentName] = false;
          });
        }
        if (mounted) {
          setState(() {});
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$documentName uploaded successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (_bottomSheetActive) {
        setModalState(() {
          _uploadingStatus[documentName] = false;
        });
      }
      if (mounted) {
        setState(() {});
      }

      if (mounted) {
        // Provide more helpful error messages
        String errorMessage = 'Upload failed';
        if (e.toString().contains('permission')) {
          errorMessage =
              'Permission denied. Please check Firebase Storage rules.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (e.toString().contains('canceled')) {
          errorMessage = 'Upload canceled';
        } else {
          errorMessage = 'Upload failed: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _pickAndUploadFile(documentName, setModalState),
            ),
          ),
        );
      }
    }
  }

  Future<void> _submitRequest(BuildContext sheetContext) async {
    try {
      if (_submitting) return; // guard
      setState(() => _submitting = true);
      // Get current user ID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please sign in to submit a request'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _submitting = false);
        return;
      }

      // Save request to Firestore with tier information
      final reqRef = await FirebaseFirestore.instance
          .collection('service_requests')
          .add({
            'serviceName': widget.subService.name,
            'serviceType': widget.serviceTypeName,
            'tier': _selectedTier.id, // 'standard' or 'premium'
            'userId': user.uid,
            'userEmail': user.email ?? '',
            'documents': _uploadedUrls,
            'details': _preUploadDetails,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
            'processing_min_days': _selectedTier.minDays,
            'processing_max_days': _selectedTier.maxDays,
            'price_aed': _selectedTier.price,
          });

      // Log Recent Activity for this submission
      try {
        final activity = UserActivity(
          id: reqRef.id, // correlate activity with request id
          title: widget.subService.name,
          status: 'Submitted',
          subtitle: 'Application submitted • ${_selectedTier.name} tier',
          iconName: 'assignment',
          icon: Icons.assignment_turned_in,
          color: AppColors.purple,
          progress: 0.2,
          createdAt: DateTime.now(),
        );
        await ref.read(userActivityProvider.notifier).addActivity(activity);
      } catch (_) {
        // Non-fatal: if activity write fails, continue
      }

      if (mounted && _bottomSheetActive) {
        Navigator.of(sheetContext).pop(); // close sheet
        _bottomSheetActive = false;
      }

      // Launch payment with the selected tier and price.
      try {
        await payForApplication(
          reqRef.id, // use request id for tracking
          _selectedTier.price.toDouble(),
          tier: _selectedTier.id,
        );

        if (mounted) {
          // After successful payment, show confirmation + tracking dialog.
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogCtx) {
              return AlertDialog(
                title: const Text('Payment successful'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your request was submitted and paid.'),
                    const SizedBox(height: 8),
                    const Text('Track with ID:'),
                    const SizedBox(height: 6),
                    SelectableText(
                      reqRef.id,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: reqRef.id));
                      Navigator.of(dialogCtx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Request ID copied to clipboard'),
                        ),
                      );
                    },
                    child: const Text('Copy ID'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ApplicationsPage(initialId: reqRef.id),
                        ),
                      );
                    },
                    child: const Text('Track this request'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed or cancelled: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      if (mounted) {
        // Clear uploaded files after the flow completes.
        setState(() {
          _uploadedFiles.clear();
          _uploadedUrls.clear();
          _uploadingStatus.clear();
          _submitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _submitting = false);
      }
    }
  }
}
