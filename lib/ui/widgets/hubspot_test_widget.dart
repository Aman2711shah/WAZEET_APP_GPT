import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

/// HubSpot Integration Test Widget
/// Add this to your Account Settings page to test the HubSpot integration
class HubSpotTestWidget extends StatefulWidget {
  const HubSpotTestWidget({super.key});

  @override
  State<HubSpotTestWidget> createState() => _HubSpotTestWidgetState();
}

class _HubSpotTestWidgetState extends State<HubSpotTestWidget> {
  String _status = '';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing HubSpot connection...';
    });

    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'us-central1',
      ).httpsCallable('testHubSpotConnection');

      final result = await callable.call({});

      if (result.data['success'] == true) {
        setState(() {
          _status =
              '✅ HubSpot Connected!\n'
              'Test Contact ID: ${result.data['contactId']}\n'
              '${result.data['message']}';
          _isLoading = false;
        });
      } else {
        setState(() {
          _status =
              '❌ Connection Failed\n'
              'Error: ${result.data['error']}\n'
              '${result.data['message']}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.integration_instructions, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HubSpot CRM Integration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Test your HubSpot connection',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testConnection,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_sync),
              label: Text(_isLoading ? 'Testing...' : 'Test Connection'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            if (_status.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _status.startsWith('✅')
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _status.startsWith('✅') ? Colors.green : Colors.red,
                  ),
                ),
                child: Text(
                  _status,
                  style: TextStyle(
                    color: _status.startsWith('✅')
                        ? Colors.green.shade900
                        : Colors.red.shade900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'How it works:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• When a user completes a payment, their information is automatically sent to HubSpot CRM\n'
              '• A contact is created/updated with their details\n'
              '• A deal is created for the service purchased\n'
              '• Documents are logged as notes',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
