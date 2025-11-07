import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/service_item.dart';
import '../../models/service_tier.dart';
import '../../services/tier_rules.dart';
import '../theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/tier_selector.dart';
import 'applications_page.dart';

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
      body: Column(
        children: [
          GradientHeader(title: widget.subService.name, showBackButton: true),
          Expanded(
            child: SingleChildScrollView(
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
                            child: Center(
                              child: Text(
                                widget.categoryIcon,
                                style: const TextStyle(fontSize: 28),
                              ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
                    const Text(
                      'Upload Documents',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: widget.subService.documentRequirements.length,
                  itemBuilder: (context, index) {
                    final doc = widget.subService.documentRequirements[index];
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
                                    : AppColors.purple.withValues(alpha: 0.1),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    setState(() {});
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
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _uploadedFiles.isEmpty
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
                  child: Text(
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
        ),
      ),
    );
  }

  Future<void> _pickAndUploadFile(
    String documentName,
    StateSetter setModalState,
  ) async {
    try {
      // Pick file with web-compatible settings
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

        setModalState(() {
          _uploadingStatus[documentName] = true;
        });
        setState(() {});

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

        setModalState(() {
          _uploadedFiles[documentName] = file;
          _uploadedUrls[documentName] = downloadUrl;
          _uploadingStatus[documentName] = false;
        });
        setState(() {});

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
      setModalState(() {
        _uploadingStatus[documentName] = false;
      });
      setState(() {});

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

  Future<void> _submitRequest(BuildContext context) async {
    try {
      // Save request to Firestore with tier information
      final ref = await FirebaseFirestore.instance
          .collection('service_requests')
          .add({
            'serviceName': widget.subService.name,
            'serviceType': widget.serviceTypeName,
            'tier': _selectedTier.id, // 'standard' or 'premium'
            'userId': 'demo_user', // Replace with actual user ID
            'documents': _uploadedUrls,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
            'processing_min_days': _selectedTier.minDays,
            'processing_max_days': _selectedTier.maxDays,
            'price_aed': _selectedTier.price,
          });

      if (mounted) {
        // Close the bottom sheet first using the page context to avoid using a
        // potentially stale BuildContext from the sheet after an async gap.
        Navigator.of(this.context).pop();

        // Then show a confirmation dialog using the page context
        // Use this.context to reference the page-level BuildContext
        // so we avoid using a disposed bottom-sheet context.
        await showDialog(
          context: this.context,
          barrierDismissible: false,
          builder: (dialogCtx) {
            return AlertDialog(
              title: const Text('Request submitted'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your request has been submitted successfully.'),
                  const SizedBox(height: 8),
                  const Text('Track with ID:'),
                  const SizedBox(height: 6),
                  SelectableText(
                    ref.id,
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
                    Clipboard.setData(ClipboardData(text: ref.id));
                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(this.context).showSnackBar(
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
                    Navigator.of(this.context).push(
                      MaterialPageRoute(
                        builder: (_) => ApplicationsPage(initialId: ref.id),
                      ),
                    );
                  },
                  child: const Text('Track this request'),
                ),
              ],
            );
          },
        );

        // Clear uploaded files
        setState(() {
          _uploadedFiles.clear();
          _uploadedUrls.clear();
          _uploadingStatus.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
