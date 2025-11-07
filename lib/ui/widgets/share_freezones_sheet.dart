import 'package:flutter/material.dart';
import '../../data/freezones_data.dart';
import '../../data/mentions_data.dart';

/// Bottom sheet for sharing selected freezones with @mentions
class ShareFreezonesSheet extends StatefulWidget {
  const ShareFreezonesSheet({super.key});

  @override
  State<ShareFreezonesSheet> createState() => _ShareFreezonesSheetState();
}

class _ShareFreezonesSheetState extends State<ShareFreezonesSheet> {
  final Set<String> _selectedFreezones = {};
  final Set<String> _selectedMentions = {};
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _noteController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredFreezones {
    if (_searchQuery.isEmpty) return FreezonesData.availableFreezones;
    return FreezonesData.availableFreezones
        .where((fz) => fz.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _sharePayload() {
    final payload = {
      'freezones': _selectedFreezones.toList(),
      'mentions': _selectedMentions.toList(),
      'note': _noteController.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    debugPrint('Share Payload: $payload');

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Shared ${_selectedFreezones.length} freezones with ${_selectedMentions.length} mentions',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canShare = _selectedFreezones.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Share Freezones',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: canShare ? _sharePayload : null,
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Search field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search freezones...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Freezones selection
                  Text(
                    'Select Freezones (${_selectedFreezones.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _filteredFreezones.map((freezone) {
                      final isSelected = _selectedFreezones.contains(freezone);
                      return FilterChip(
                        label: Text(freezone),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedFreezones.add(freezone);
                            } else {
                              _selectedFreezones.remove(freezone);
                            }
                          });
                        },
                        checkmarkColor: Colors.white,
                        selectedColor: theme.colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Mentions selection
                  Text(
                    'Add Mentions (${_selectedMentions.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MentionsData.availableMentions.map((mention) {
                      final isSelected = _selectedMentions.contains(mention);
                      return FilterChip(
                        avatar: Icon(
                          Icons.alternate_email,
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.primary,
                        ),
                        label: Text(mention.substring(1)), // Remove @
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedMentions.add(mention);
                            } else {
                              _selectedMentions.remove(mention);
                            }
                          });
                        },
                        checkmarkColor: Colors.white,
                        selectedColor: theme.colorScheme.secondary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Optional note
                  Text(
                    'Add Note (Optional)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'Add any additional notes...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Preview section
                  if (canShare) ...[
                    Text(
                      'Preview',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_selectedFreezones.isNotEmpty) ...[
                            const Text(
                              '📍 Freezones:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            ...(_selectedFreezones.map(
                              (fz) => Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  top: 2,
                                ),
                                child: Text('• $fz'),
                              ),
                            )),
                            const SizedBox(height: 12),
                          ],
                          if (_selectedMentions.isNotEmpty) ...[
                            const Text(
                              '👥 Mentions:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedMentions.join(', '),
                              style: TextStyle(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (_noteController.text.trim().isNotEmpty) ...[
                            const Text(
                              '📝 Note:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(_noteController.text.trim()),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
