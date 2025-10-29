import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/service_item.dart';
import '../theme.dart';
import '../widgets/gradient_header.dart';
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
  bool isPremiumSelected = false;
  final Map<String, PlatformFile?> _uploadedFiles = {};
  final Map<String, bool> _uploadingStatus = {};
  final Map<String, String> _uploadedUrls = {};

  @override
  Widget build(BuildContext context) {
    final selectedTier = isPremiumSelected
        ? widget.subService.premium
        : widget.subService.standard;
    final tierName = isPremiumSelected ? 'Premium' : 'Standard';

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
                              color: AppColors.purple.withOpacity(0.1),
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

                  // Pricing Tier Selection
                  const Text(
                    'Select Service Tier',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTierCard(
                          title: 'Standard',
                          cost: widget.subService.standardCostDisplay,
                          timeline: widget.subService.standard.timeline,
                          isSelected: !isPremiumSelected,
                          onTap: () =>
                              setState(() => isPremiumSelected = false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTierCard(
                          title: 'Premium',
                          cost: widget.subService.premiumCostDisplay,
                          timeline: widget.subService.premium.timeline,
                          isSelected: isPremiumSelected,
                          isPremium: true,
                          onTap: () => setState(() => isPremiumSelected = true),
                        ),
                      ),
                    ],
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
                            value: isPremiumSelected
                                ? widget.subService.premiumCostDisplay
                                : widget.subService.standardCostDisplay,
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            icon: Icons.schedule,
                            label: 'Processing Time',
                            value: selectedTier.timeline,
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
                      color: AppColors.purple.withOpacity(0.1),
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
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => _showDocumentUpload(context, tierName),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Proceed with $tierName Tier',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTierCard({
    required String title,
    required String cost,
    required String timeline,
    required bool isSelected,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.purple : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isSelected ? AppColors.purple : Colors.black,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_circle, color: AppColors.purple, size: 20),
                if (isPremium && !isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'FAST',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              cost,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.purple : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: isSelected ? AppColors.purple : Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    timeline,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? AppColors.purple
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ],
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

  void _showDocumentUpload(BuildContext context, String tierName) {
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
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isUploaded
                              ? Colors.green.withOpacity(0.1)
                              : AppColors.purple.withOpacity(0.1),
                          child: isUploading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.purple,
                                    ),
                                  ),
                                )
                              : Icon(
                                  isUploaded ? Icons.check : Icons.description,
                                  color: isUploaded
                                      ? Colors.green
                                      : AppColors.purple,
                                  size: 20,
                                ),
                        ),
                        title: Text(doc),
                        subtitle: Text(
                          isUploaded
                              ? _uploadedFiles[doc]!.name
                              : 'Tap to upload',
                          style: TextStyle(
                            color: isUploaded ? Colors.green : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        trailing: isUploaded
                            ? IconButton(
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
                            : const Icon(Icons.upload_file),
                        onTap: isUploading
                            ? null
                            : () => _pickAndUploadFile(doc, setModalState),
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
                      : () => _submitRequest(context, tierName),
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
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

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

        // Upload file bytes
        if (file.bytes != null) {
          await storageRef.putData(
            file.bytes!,
            SettableMetadata(
              contentType: file.extension == 'pdf'
                  ? 'application/pdf'
                  : 'image/${file.extension}',
            ),
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
              ),
            );
          }
        }
      }
    } catch (e) {
      setModalState(() {
        _uploadingStatus[documentName] = false;
      });
      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitRequest(BuildContext context, String tierName) async {
    try {
      // Save request to Firestore
      final ref = await FirebaseFirestore.instance
          .collection('service_requests')
          .add({
            'serviceName': widget.subService.name,
            'serviceType': widget.serviceTypeName,
            'tier': tierName,
            'userId': 'demo_user', // Replace with actual user ID
            'documents': _uploadedUrls,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
            'premium': isPremiumSelected,
            'cost': isPremiumSelected
                ? widget.subService.premium.cost.toString()
                : widget.subService.standard.cost.toString(),
            'timeline': isPremiumSelected
                ? widget.subService.premium.timeline
                : widget.subService.standard.timeline,
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
