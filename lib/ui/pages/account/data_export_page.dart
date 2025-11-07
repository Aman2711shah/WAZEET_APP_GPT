import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';

class DataExportPage extends StatefulWidget {
  const DataExportPage({super.key});

  @override
  State<DataExportPage> createState() => _DataExportPageState();
}

class _DataExportPageState extends State<DataExportPage> {
  bool _isGenerating = false;
  String? _downloadUrl;
  String? _errorMessage;

  Future<void> _generateExport() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _downloadUrl = null;
    });

    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('exportUserData');
      final result = await callable.call();

      final data = result.data as Map<String, dynamic>;
      final downloadUrl = data['url'] as String?;

      if (downloadUrl != null) {
        setState(() {
          _downloadUrl = downloadUrl;
          _isGenerating = false;
        });
      } else {
        throw 'No download URL received';
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isGenerating = false;
      });
    }
  }

  Future<void> _downloadData() async {
    if (_downloadUrl == null) return;

    try {
      final uri = Uri.parse(_downloadUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not open download link';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open download: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Download Your Data')),
      body: SingleChildScrollView(
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
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.download,
                    color: Colors.blue[700],
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export Your Data',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Download a copy of your information',
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
                        'What\'s included',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DataItem('Profile information'),
                  _DataItem('Account settings and preferences'),
                  _DataItem('Activity history'),
                  _DataItem('Uploaded content'),
                  const SizedBox(height: 12),
                  Text(
                    'Your data will be packaged as a ZIP file containing JSON files and any media you\'ve uploaded.',
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

            // Status Section
            if (_isGenerating) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Generating your data export...',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This may take a few moments',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_downloadUrl != null) ...[
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[700],
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your data is ready!',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click the button below to download your data archive.',
                        style: TextStyle(color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _downloadData,
                        icon: const Icon(Icons.download),
                        label: const Text('Download Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This link will expire in 1 hour',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_errorMessage != null) ...[
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[700],
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Export Failed',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[900]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: _generateExport,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Generate Button
              ElevatedButton.icon(
                onPressed: _generateExport,
                icon: const Icon(Icons.file_download),
                label: const Text('Generate Data Export'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Privacy Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: Colors.grey[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Privacy & Security',
                        style: TextStyle(
                          color: Colors.grey[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Your data export will be stored securely and encrypted\n'
                    '• Download links expire after 1 hour for security\n'
                    '• Only you can access your data export\n'
                    '• Exports are automatically deleted after download',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataItem extends StatelessWidget {
  final String text;

  const _DataItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.check, size: 18, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.blue[900], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
