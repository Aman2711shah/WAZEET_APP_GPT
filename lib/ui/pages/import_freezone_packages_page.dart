import 'package:flutter/material.dart';
import 'dart:io';
import '../../utils/freezone_packages_importer.dart';

/// Admin page to import freezone packages from CSV file
class ImportFreezonePackagesPage extends StatefulWidget {
  const ImportFreezonePackagesPage({super.key});

  @override
  State<ImportFreezonePackagesPage> createState() =>
      _ImportFreezonePackagesPageState();
}

class _ImportFreezonePackagesPageState
    extends State<ImportFreezonePackagesPage> {
  bool _isImporting = false;
  String _statusMessage = '';
  Map<String, int>? _packageCounts;

  /// Import from the CSV file you provided
  Future<void> _importFromFile() async {
    setState(() {
      _isImporting = true;
      _statusMessage = 'Reading CSV file...';
    });

    try {
      // Read the CSV file content
      final file = File(
        '/Users/amanshah/Downloads/UAE_Freezones_Pricing_All_17_Freezones.csv',
      );
      final csvContent = await file.readAsString();

      setState(() {
        _statusMessage = 'Importing to Firestore...';
      });

      // Import to Firestore
      await FreezonePackagesImporter.importFromCSV(csvContent);

      // Get package counts
      final counts = await FreezonePackagesImporter.getPackageCountByFreezone();

      setState(() {
        _isImporting = false;
        _statusMessage = '✅ Import successful!';
        _packageCounts = counts;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Freezone packages imported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
        _statusMessage = '❌ Error: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Clear all packages from Firestore
  Future<void> _clearAllPackages() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Packages?'),
        content: const Text(
          'This will delete ALL freezone packages from Firestore. This action cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isImporting = true;
      _statusMessage = 'Clearing all packages...';
    });

    try {
      await FreezonePackagesImporter.clearAllPackages();

      setState(() {
        _isImporting = false;
        _statusMessage = '✅ All packages cleared!';
        _packageCounts = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All packages cleared successfully!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
        _statusMessage = '❌ Error: $e';
      });
    }
  }

  /// Get current package counts
  Future<void> _refreshCounts() async {
    try {
      final counts = await FreezonePackagesImporter.getPackageCountByFreezone();
      setState(() {
        _packageCounts = counts;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading counts: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Freezone Packages'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isImporting ? null : _refreshCounts,
            tooltip: 'Refresh counts',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Freezone Packages Importer',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This tool imports freezone package data from the CSV file into Firebase Firestore.',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'CSV File: UAE_Freezones_Pricing_All_17_Freezones.csv',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Import Button
            ElevatedButton.icon(
              onPressed: _isImporting ? null : _importFromFile,
              icon: _isImporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.upload_file),
              label: Text(_isImporting ? 'Importing...' : 'Import from CSV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Clear Button
            OutlinedButton.icon(
              onPressed: _isImporting ? null : _clearAllPackages,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Clear All Packages'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // Status Message
            if (_statusMessage.isNotEmpty)
              Card(
                color: _statusMessage.contains('✅')
                    ? Colors.green.shade50
                    : _statusMessage.contains('❌')
                    ? Colors.red.shade50
                    : Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _statusMessage.contains('✅')
                          ? Colors.green.shade900
                          : _statusMessage.contains('❌')
                          ? Colors.red.shade900
                          : Colors.blue.shade900,
                    ),
                  ),
                ),
              ),

            // Package Counts
            if (_packageCounts != null) ...[
              const SizedBox(height: 24),
              Text(
                'Packages by Freezone',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Card(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _packageCounts!.length,
                    itemBuilder: (context, index) {
                      final entry = _packageCounts!.entries.elementAt(index);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          child: Text(
                            '${entry.value}',
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(entry.key),
                        subtitle: Text('${entry.value} packages'),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
