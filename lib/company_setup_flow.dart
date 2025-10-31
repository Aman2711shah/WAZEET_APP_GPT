import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wazeet/utils/industry_loader.dart';
import 'package:wazeet/services/openai_service.dart';

// =============================================================
// Company Setup Flow (Single-file implementation)
// - Model: SetupData
// - State: Riverpod StateNotifier for data; separate step index
// - UI: PageView-based wizard with gradient header + bottom controls
// =============================================================

// ---------------------- Model ----------------------
class SetupData {
  final List<String> businessActivities;
  final int shareholdersCount; // 1..10
  final int visaCount; // 0..10
  final int licenseTenureYears; // 1/2/3
  final String entityType; // 'LLC' | 'FZ-LLC' | 'Sole Proprietor'
  final String emirate; // Selected emirate
  final String recommendedZone; // computed/dummy
  final String visaType; // 'Employment' | 'Investor' | '' (unset)

  const SetupData({
    this.businessActivities = const [],
    this.shareholdersCount = 1,
    this.visaCount = 0,
    this.licenseTenureYears = 1,
    this.entityType = '',
    this.emirate = '',
    this.recommendedZone = '',
    this.visaType = '',
  });

  SetupData copyWith({
    List<String>? businessActivities,
    int? shareholdersCount,
    int? visaCount,
    int? licenseTenureYears,
    String? entityType,
    String? emirate,
    String? recommendedZone,
    String? visaType,
  }) {
    return SetupData(
      businessActivities: businessActivities ?? this.businessActivities,
      shareholdersCount: shareholdersCount ?? this.shareholdersCount,
      visaCount: visaCount ?? this.visaCount,
      licenseTenureYears: licenseTenureYears ?? this.licenseTenureYears,
      entityType: entityType ?? this.entityType,
      emirate: emirate ?? this.emirate,
      recommendedZone: recommendedZone ?? this.recommendedZone,
      visaType: visaType ?? this.visaType,
    );
  }
}

// ---------------------- Dummy Data ----------------------
const kActivities = <String>[
  'E-commerce',
  'Consulting',
  'Marketing',
  'Logistics',
  'Technology',
  'Education',
  'Healthcare',
  'Real Estate',
  'Hospitality',
  'Manufacturing',
  'Import/Export',
];

class EntityOption {
  final String key;
  final String label;
  final String description;
  const EntityOption(this.key, this.label, this.description);
}

const kEntityOptions = <EntityOption>[
  EntityOption('LLC', 'LLC', 'Limited liability, versatile for most SMEs.'),
  EntityOption(
    'FZ-LLC',
    'FZ-LLC',
    'Free zone LLC, simplified setup and 100% ownership.',
  ),
  EntityOption(
    'Sole Proprietor',
    'Sole Proprietor',
    'Single owner, simplest structure.',
  ),
];

// ---------------------- State Notifiers ----------------------
class SetupController extends StateNotifier<SetupData> {
  SetupController() : super(const SetupData());

  void toggleActivity(String activity) {
    final current = [...state.businessActivities];
    if (current.contains(activity)) {
      current.remove(activity);
    } else {
      // Limit to maximum 5 activities
      if (current.length < 5) {
        current.add(activity);
      }
    }
    state = state.copyWith(businessActivities: current);
  }

  void setShareholdersCount(int v) {
    final clamped = v.clamp(1, 10);
    state = state.copyWith(shareholdersCount: clamped);
  }

  void setVisaCount(int v) {
    final clamped = v.clamp(0, 10);
    state = state.copyWith(visaCount: clamped);
  }

  void setLicenseTenureYears(int v) {
    final clamped = v.clamp(1, 3);
    state = state.copyWith(licenseTenureYears: clamped);
  }

  void setEntityType(String entity) {
    state = state.copyWith(entityType: entity);
  }

  void setEmirate(String emirate) {
    state = state.copyWith(emirate: emirate);
  }

  void setVisaType(String type) {
    state = state.copyWith(visaType: type);
  }

  // Dummy recommender logic
  void computeRecommendation() {
    final acts = state.businessActivities.map((e) => e.toLowerCase()).toList();
    String zone;
    if (acts.contains('e-commerce') || acts.contains('ecommerce')) {
      zone = 'IFZA Accelerator E-commerce';
    } else if (acts.contains('consulting')) {
      zone = 'ADGM Professional Services';
    } else if (acts.contains('technology')) {
      zone = 'DTEC Tech Hub';
    } else {
      zone = 'RAKEZ Business Hub';
    }
    state = state.copyWith(recommendedZone: zone);
  }
}

final setupProvider = StateNotifierProvider<SetupController, SetupData>((ref) {
  return SetupController();
});

class StepIndexController extends StateNotifier<int> {
  StepIndexController() : super(0);
  void next(int maxIndex) {
    if (state < maxIndex) state = state + 1;
  }

  void prev() {
    if (state > 0) state = state - 1;
  }

  void jumpTo(int index) => state = index;
}

final stepIndexProvider = StateNotifierProvider<StepIndexController, int>((
  ref,
) {
  return StepIndexController();
});

// ---------------------- UI Root ----------------------
class CompanySetupFlow extends ConsumerStatefulWidget {
  const CompanySetupFlow({super.key});

  @override
  ConsumerState<CompanySetupFlow> createState() => _CompanySetupFlowState();
}

class _CompanySetupFlowState extends ConsumerState<CompanySetupFlow> {
  static const _totalSteps =
      8; // 0..7 (Activities, Shareholders, Visa, Tenure, Entity, Emirate, Recommender, Summary)
  final _pageController = PageController();
  String _activityQuery = '';
  Timer? _debounceTimer;
  String _pendingQuery = '';

  void _onSearchChanged(String value) {
    _pendingQuery = value;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _activityQuery = _pendingQuery;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  bool _isCurrentStepValid(SetupData data, int step) {
    switch (step) {
      case 0:
        return data.businessActivities.isNotEmpty;
      case 1:
        return data.shareholdersCount >= 1 && data.shareholdersCount <= 10;
      case 2:
        final baseValid = data.visaCount >= 0 && data.visaCount <= 10;
        // If user requests visa slots, require explicit visa type selection
        if (baseValid && data.visaCount > 0) {
          return data.visaType.isNotEmpty;
        }
        return baseValid;
      case 3:
        return data.licenseTenureYears >= 1 && data.licenseTenureYears <= 3;
      case 4:
        return data.entityType.isNotEmpty;
      case 5:
        return data.emirate.isNotEmpty;
      case 6:
        return true; // Recommender screen always passable
      case 7:
        return true; // Summary: Complete is always enabled
      default:
        return false;
    }
  }

  void _goNext(int step) {
    if (step == 4) {
      // Compute recommendation before entering step 5
      ref.read(setupProvider.notifier).computeRecommendation();
    }
    final maxIndex = _totalSteps - 1;
    ref.read(stepIndexProvider.notifier).next(maxIndex);
    _pageController.animateToPage(
      ref.read(stepIndexProvider),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    ref.read(stepIndexProvider.notifier).prev();
    _pageController.animateToPage(
      ref.read(stepIndexProvider),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(stepIndexProvider);
    final data = ref.watch(setupProvider);
    final theme = Theme.of(context);

    final progress = (step + 1) / _totalSteps;
    final isValid = _isCurrentStepValid(data, step);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Company Setup',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _Header(
            title: _stepTitle(step),
            progress: progress,
            accent: theme.colorScheme.primary,
          ),
          // Steps content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ActivitiesStep(
                  query: _activityQuery,
                  onQueryChanged: _onSearchChanged,
                ),
                _ShareholdersStep(),
                _VisaStep(),
                _TenureStep(),
                _EntityStep(),
                _EmirateStep(),
                _RecommenderStep(),
                _SummaryStep(
                  onComplete: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Setup complete')),
                    );
                  },
                ),
              ],
            ),
          ),
          // Bottom controls
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: step > 0
                          ? _goBack
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isValid
                          ? () {
                              if (step < _totalSteps - 1) {
                                _goNext(step);
                              } else {
                                // Complete on last step
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Setup complete'),
                                  ),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        step == _totalSteps - 1 ? 'Complete Setup' : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _stepTitle(int step) {
  switch (step) {
    case 0:
      return 'Business Activities';
    case 1:
      return 'Shareholders';
    case 2:
      return 'Visa Requirements';
    case 3:
      return 'License Tenure';
    case 4:
      return 'Legal Entity Type';
    case 5:
      return 'Select Emirate';
    case 6:
      return 'Smart Recommender';
    case 7:
      return 'Summary';
    default:
      return 'Company Setup';
  }
}

// ---------------------- Steps ----------------------

/// Filter activities by multiple keywords (supports 3-4 keywords)
/// Each keyword is searched in both name and description
List<ActivityData> _filterByKeywords(
  List<ActivityData> activities,
  String query,
) {
  if (query.trim().isEmpty) {
    return activities;
  }

  final queryLower = query.toLowerCase().trim();

  // Split query into keywords (by spaces)
  final keywords = queryLower
      .split(RegExp(r'\s+'))
      .where((k) => k.length > 1) // Skip single characters for performance
      .take(4) // Limit to 4 keywords for performance
      .toList();

  if (keywords.isEmpty) {
    return activities;
  }

  // Optimized filter with early exit
  final results = <ActivityData>[];
  for (final activity in activities) {
    final activityName = activity.name.toLowerCase();
    final activityDesc = activity.description.toLowerCase();

    // Fast path: check if first keyword exists before checking all
    if (!activityName.contains(keywords[0]) &&
        !activityDesc.contains(keywords[0])) {
      continue;
    }

    // Check remaining keywords
    var matchesAll = true;
    for (var i = 0; i < keywords.length; i++) {
      final keyword = keywords[i];
      if (!activityName.contains(keyword) && !activityDesc.contains(keyword)) {
        matchesAll = false;
        break;
      }
    }

    if (matchesAll) {
      results.add(activity);
    }
  }

  return results;
}

class _ActivitiesStep extends ConsumerStatefulWidget {
  const _ActivitiesStep({required this.query, required this.onQueryChanged});
  final String query;
  final ValueChanged<String> onQueryChanged;

  @override
  ConsumerState<_ActivitiesStep> createState() => _ActivitiesStepState();
}

class _ActivitiesStepState extends ConsumerState<_ActivitiesStep> {
  late final Future<List<ActivityData>> _activitiesFuture;
  List<ActivityData>? _cachedActivities;
  List<ActivityData>? _cachedFilteredResults;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _activitiesFuture = loadAllActivitiesWithDescriptions(
      'assets/images/excel-to-json.industry-grouped.json',
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(setupProvider);
    final controller = ref.read(setupProvider.notifier);

    return FutureBuilder<List<ActivityData>>(
      future: _activitiesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading activities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  style: TextStyle(color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allActivities = snapshot.data ?? [];

        // Cache activities on first load
        _cachedActivities ??= allActivities;

        // Use cached results if query hasn't changed
        List<ActivityData> filtered;
        if (widget.query == _lastQuery && _cachedFilteredResults != null) {
          filtered = _cachedFilteredResults!;
        } else {
          // Support multi-keyword search (3-4 keywords)
          filtered = _filterByKeywords(allActivities, widget.query);
          _cachedFilteredResults = filtered;
          _lastQuery = widget.query;
        }

        final isValid = data.businessActivities.isNotEmpty;

        return Column(
          children: [
            // Header section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Business Activities',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose 1-5 activities. You can change this later.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 16),
                  Material(
                    elevation: 1,
                    borderRadius: BorderRadius.circular(12),
                    child: TextField(
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        prefixIcon: const Icon(Icons.search),
                        hintText:
                            'Search with keywords (e.g., "retail sale food")',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: widget.onQueryChanged,
                    ),
                  ),
                  if (widget.query.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tip: Use multiple keywords for better results (e.g., "document preparation office")',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (!isValid)
                    const Text(
                      'Please select at least one activity to proceed.',
                      style: TextStyle(color: Colors.red),
                    ),
                  if (data.businessActivities.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: data.businessActivities.length >= 5
                            ? Colors.orange.shade50
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            data.businessActivities.length >= 5
                                ? Icons.info
                                : Icons.check_circle,
                            color: data.businessActivities.length >= 5
                                ? Colors.orange.shade700
                                : Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              data.businessActivities.length >= 5
                                  ? '5 activities selected (maximum reached)'
                                  : '${data.businessActivities.length} ${data.businessActivities.length == 1 ? "activity" : "activities"} selected',
                              style: TextStyle(
                                color: data.businessActivities.length >= 5
                                    ? Colors.orange.shade700
                                    : Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Activities list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final activity = filtered[index];
                  final isSelected = data.businessActivities.contains(
                    activity.name,
                  );
                  final isLimitReached = data.businessActivities.length >= 5;
                  final isDisabled = isLimitReached && !isSelected;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: isSelected ? 2 : 0,
                    color: isDisabled ? Colors.grey.shade100 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.blue.shade700
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Select row (only this row toggles selection)
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: isDisabled
                                ? null
                                : () =>
                                      controller.toggleActivity(activity.name),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  child: Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: isDisabled
                                        ? Colors.grey.shade300
                                        : (isSelected
                                              ? Colors.blue.shade700
                                              : Colors.grey.shade400),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activity.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDisabled
                                              ? Colors.grey.shade400
                                              : (isSelected
                                                    ? Colors.blue.shade900
                                                    : Colors.black87),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        activity.description,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDisabled
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade700,
                                          height: 1.4,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ESR Applicability (expandable)
                          _TintedSection(
                            child: _ExpandableInfoTile(
                              title: Row(
                                children: const [
                                  Text(
                                    'ESR Applicability',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Tooltip(
                                    message:
                                        'Economic Substance Regulations: certain activities must file annual ESR notifications and reports.',
                                    child: Icon(Icons.info_outline, size: 16),
                                  ),
                                ],
                              ),
                              subtitle: _esrSummary(activity.name),
                              expandedChild: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  _esrDetails(activity.name),
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Additional Documents (expandable)
                          _TintedSection(
                            child: _ExpandableInfoTile(
                              title: Row(
                                children: const [
                                  Text(
                                    'Additional Documents Required',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Tooltip(
                                    message:
                                        'Extra supporting documents commonly required by the licensing authority.',
                                    child: Icon(Icons.info_outline, size: 16),
                                  ),
                                ],
                              ),
                              subtitle: 'Tap to view details',
                              expandedChild: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _documentsFor(activity.name).map((
                                    doc,
                                  ) {
                                    return ActionChip(
                                      avatar: const Icon(
                                        Icons.description,
                                        size: 16,
                                      ),
                                      label: Text(doc['name']!),
                                      onPressed: () =>
                                          _showDocInfo(context, doc),
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---- Helper tinted container ----
class _TintedSection extends StatelessWidget {
  final Widget child;
  const _TintedSection({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.15)),
      ),
      child: child,
    );
  }
}

// ---- Expandable tile used for ESR/Docs ----
class _ExpandableInfoTile extends StatefulWidget {
  final Widget title;
  final String? subtitle;
  final Widget expandedChild;
  const _ExpandableInfoTile({
    required this.title,
    this.subtitle,
    required this.expandedChild,
  });

  @override
  State<_ExpandableInfoTile> createState() => _ExpandableInfoTileState();
}

class _ExpandableInfoTileState extends State<_ExpandableInfoTile> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextStyle.merge(
                      style: const TextStyle(fontSize: 14),
                      child: widget.title,
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle!,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    _expanded ? 'Hide' : 'View Details',
                    style: TextStyle(
                      color: Colors.deepPurple.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.deepPurple.shade700,
                  ),
                ],
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: widget.expandedChild,
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

// ---- Activity details helpers (ESR + Documents) ----
extension on _ActivitiesStepState {
  bool _esrRequired(String name) {
    final n = name.toLowerCase();
    return n.contains('holding') ||
        n.contains('headquarter') ||
        n.contains('distribution') ||
        n.contains('service') || // relevant service centers
        n.contains('finance') ||
        n.contains('leasing') ||
        n.contains('insurance') ||
        n.contains('shipping') ||
        n.contains('intellectual property') ||
        n.contains('ip') ||
        n.contains('bank');
  }

  String _esrSummary(String name) {
    final required = _esrRequired(name);
    return required
        ? '✅ ESR Required – Submit annual economic substance declaration.'
        : '⚪ Not applicable under ESR regulations.';
  }

  String _esrDetails(String name) {
    if (_esrRequired(name)) {
      return 'This activity is generally considered a Relevant Activity for ESR. Licensees must file an annual ESR Notification and, if conditions are met, an ESR Report with the authority.';
    }
    return 'Based on typical classifications, this activity does not fall under ESR Relevant Activities. Always confirm with your free zone authority.';
  }

  List<Map<String, String>> _documentsFor(String name) {
    final n = name.toLowerCase();
    final base = <Map<String, String>>[
      {
        'name': 'Owner Passport',
        'desc': 'Clear color copy of all owners/UBOs.',
      },
      {
        'name': 'Business Plan',
        'desc': '1–2 page summary of proposed activity and operations.',
      },
      {
        'name': 'NOC (if employed)',
        'desc': 'No Objection Certificate from current employer if applicable.',
      },
      {
        'name': 'Shareholder Resolution',
        'desc': 'Resolution to incorporate and appoint managers.',
      },
      {
        'name': 'MOA/AOA',
        'desc': 'Memorandum/Articles for LLC or corporate shareholder.',
      },
    ];
    if (n.contains('transport') || n.contains('towing')) {
      base.addAll([
        {
          'name': 'Vehicle List',
          'desc': 'List of operational vehicles/fleet details.',
        },
        {'name': 'Driver Licenses', 'desc': 'Valid UAE licenses for drivers.'},
      ]);
    } else if (n.contains('document')) {
      base.add({
        'name': 'Sample Templates',
        'desc': 'Examples of documents offered for clients.',
      });
    } else if (n.contains('retail') ||
        n.contains('(g.p.s)') ||
        n.contains('gps')) {
      base.add({
        'name': 'Supplier Invoices',
        'desc': 'Proof of supply channels for devices/hardware.',
      });
    }
    return base;
  }

  void _showDocInfo(BuildContext context, Map<String, String> doc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Text(
                      doc['name']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  doc['desc']!,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload (placeholder)'),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Coming soon',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShareholdersStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(setupProvider);
    final controller = ref.read(setupProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            'Number of Shareholders',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Impacts compliance and documentation.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _NumberButton(
                icon: Icons.remove,
                onTap: () =>
                    controller.setShareholdersCount(data.shareholdersCount - 1),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${data.shareholdersCount}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _NumberButton(
                icon: Icons.add,
                onTap: () =>
                    controller.setShareholdersCount(data.shareholdersCount + 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Min 1, Max 10'),
          if (data.shareholdersCount < 1 || data.shareholdersCount > 10)
            const Text(
              'Enter a value between 1 and 10',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}

class _VisaStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(setupProvider);
    final controller = ref.read(setupProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            'Visa Requirements',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'How many resident visa slots do you need? (0–10)',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _NumberButton(
                icon: Icons.remove,
                onTap: () => controller.setVisaCount(data.visaCount - 1),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${data.visaCount}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _NumberButton(
                icon: Icons.add,
                onTap: () => controller.setVisaCount(data.visaCount + 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (data.visaCount < 0 || data.visaCount > 10)
            const Text(
              'Enter a value between 0 and 10',
              style: TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 16),
          const Text(
            'Select Visa Type',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              _VisaTypeCard(
                title: 'Employment Visa',
                subtitle: 'For employees and managers hired by the company.',
                selected: data.visaType == 'Employment',
                onTap: () => controller.setVisaType('Employment'),
              ),
              const SizedBox(height: 8),
              _VisaTypeCard(
                title: 'Investor Visa',
                subtitle:
                    'For shareholders/owners with qualifying share capital.',
                selected: data.visaType == 'Investor',
                onTap: () => controller.setVisaType('Investor'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (data.visaCount > 0 && data.visaType.isEmpty)
            const Text(
              'Please select a visa type to proceed.',
              style: TextStyle(color: Colors.red),
            ),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text('What does visa processing involve?'),
              childrenPadding: const EdgeInsets.only(
                bottom: 8,
                left: 8,
                right: 8,
              ),
              children: [
                if (data.visaType.isEmpty)
                  const Text(
                    'Select a visa type above to see tailored steps. In general, the process includes an entry permit, medical exam, Emirates ID biometrics, and visa stamping. Details vary by free zone.',
                  )
                else if (data.visaType == 'Investor')
                  const Text(
                    'Investor Visa overview:\n\n• Entry Permit issuance (e-visa)\n• Establishment Card & shareholding verification\n• Medical examination\n• Emirates ID biometrics\n• Visa stamping (or e-visa activation)\n\nNotes: Investor visas may have different minimum share capital requirements and may not require a labor contract. Timelines vary by authority.',
                  )
                else
                  const Text(
                    'Employment Visa overview:\n\n• Entry Permit issuance (e-visa)\n• Optional status change (if inside UAE)\n• Medical examination\n• Emirates ID biometrics\n• Labor contract (mainland) or equivalent free zone process\n• Visa stamping (or e-visa activation)\n\nTypical duration is 5–10 working days post company setup. Exact steps vary by free zone.',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Visa type card ----
class _VisaTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _VisaTypeCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? Colors.deepPurple.shade700
        : Colors.grey.shade300;
    final iconColor = selected
        ? Colors.deepPurple.shade700
        : Colors.grey.shade400;

    return Card(
      elevation: selected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: selected ? 2 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: iconColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TenureStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(setupProvider);
    final controller = ref.read(setupProvider.notifier);

    int selected = data.licenseTenureYears;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            'License Tenure',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose for how many years you want the license (1–3).',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          ...[1, 2, 3].map(
            (y) => RadioListTile<int>(
              value: y,
              groupValue: selected,
              onChanged: (v) => controller.setLicenseTenureYears(v ?? 1),
              title: Text('$y year${y > 1 ? 's' : ''}'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntityStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(setupProvider);
    final controller = ref.read(setupProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            'Legal Entity Type',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a structure. You can change this later.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          ...kEntityOptions.map((opt) {
            final selected = data.entityType == opt.key;
            return Card(
              elevation: selected ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => controller.setEntityType(opt.key),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: selected ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opt.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(opt.description),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (data.entityType.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Please choose an entity type to proceed.',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmirateStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(setupProvider);
    final controller = ref.read(setupProvider.notifier);

    final emirates = [
      'Abu Dhabi',
      'Dubai',
      'Sharjah',
      'Ajman',
      'Umm Al Quwain',
      'Ras Al Khaimah',
      'Fujairah',
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            'Select Emirate',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the emirate where you want to establish your business.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          ...emirates.map((emirate) {
            final selected = data.emirate == emirate;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: selected ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: selected ? Colors.blue.shade700 : Colors.grey.shade300,
                  width: selected ? 2 : 1,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => controller.setEmirate(emirate),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: selected
                            ? Colors.blue.shade700
                            : Colors.grey.shade400,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          emirate,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.blue.shade900
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (data.emirate.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Please select an emirate to proceed.',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecommenderStep extends ConsumerStatefulWidget {
  const _RecommenderStep();

  @override
  ConsumerState<_RecommenderStep> createState() => _RecommenderStepState();
}

class _RecommenderStepState extends ConsumerState<_RecommenderStep> {
  String? _aiRecommendation;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Fetch AI recommendations when the step loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAIRecommendations();
    });
  }

  Future<void> _fetchAIRecommendations() async {
    if (_aiRecommendation != null) return; // Already fetched

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = ref.read(setupProvider);

      final recommendation = await OpenAIService.getFreezoneRecommendations(
        businessActivities: data.businessActivities,
        shareholdersCount: data.shareholdersCount,
        visaCount: data.visaCount,
        licenseTenureYears: data.licenseTenureYears,
        entityType: data.entityType,
        emirate: data.emirate,
      );

      if (mounted) {
        setState(() {
          _aiRecommendation = recommendation;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Unable to fetch recommendations. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(setupProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'AI-Powered Free Zone Recommendations',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Based on your business requirements, our AI analyzes optimal free zone options with pricing:',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),

          // Your Business Summary Card
          Card(
            elevation: 1,
            color: Colors.blue.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.business_center,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Business Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.blue.shade900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Activities',
                    data.businessActivities.join(', '),
                  ),
                  _buildInfoRow('Shareholders', '${data.shareholdersCount}'),
                  _buildInfoRow('Visas', '${data.visaCount}'),
                  _buildInfoRow('Visa Type', data.visaType),
                  _buildInfoRow(
                    'License Period',
                    '${data.licenseTenureYears} year(s)',
                  ),
                  _buildInfoRow('Entity Type', data.entityType),
                  _buildInfoRow('Emirate', data.emirate),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // AI Recommendations Section
          if (_isLoading)
            Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Analyzing options and pricing...',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          else if (_error != null)
            Card(
              elevation: 0,
              color: Colors.red.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _fetchAIRecommendations,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_aiRecommendation != null)
            ..._buildEnhancedRecommendations(_aiRecommendation!),

          const SizedBox(height: 16),

          // Action Buttons
          if (!_isLoading && _aiRecommendation != null)
            Card(
              elevation: 0,
              color: Colors.green.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade700,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ready to proceed with your setup?',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade900,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Review your summary in the next step or go back to make changes.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildEnhancedRecommendations(String recommendation) {
    final sections = _parseRecommendation(recommendation);
    final widgets = <Widget>[];

    // Header Card
    widgets.add(
      Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade700, Colors.purple.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI-Powered Analysis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Personalized recommendations with pricing',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    widgets.add(const SizedBox(height: 16));

    // Parse and display each section
    for (var section in sections) {
      if (section['type'] == 'zone') {
        widgets.add(_buildZoneCard(section));
        widgets.add(const SizedBox(height: 12));
      } else if (section['type'] == 'comparison') {
        widgets.add(_buildComparisonCard(section));
        widgets.add(const SizedBox(height: 12));
      } else if (section['type'] == 'recommendation') {
        widgets.add(_buildBestValueCard(section));
        widgets.add(const SizedBox(height: 12));
      } else if (section['type'] == 'note') {
        widgets.add(_buildNoteCard(section));
        widgets.add(const SizedBox(height: 12));
      } else {
        widgets.add(_buildGenericSection(section));
        widgets.add(const SizedBox(height: 12));
      }
    }

    return widgets;
  }

  List<Map<String, dynamic>> _parseRecommendation(String text) {
    final sections = <Map<String, dynamic>>[];
    final lines = text.split('\n');

    Map<String, dynamic>? currentSection;
    List<String> currentContent = [];

    for (var line in lines) {
      final trimmed = line.trim();

      // Detect zone recommendations (starts with **number or number followed by zone name)
      // Matches: **1. Dubai Silicon Oasis** or similar patterns
      if (RegExp(r'^\*\*\d+\.').hasMatch(trimmed)) {
        // Save previous section
        if (currentSection != null) {
          currentSection['content'] = currentContent.join('\n');
          sections.add(currentSection);
        }
        // Start new zone section
        currentSection = {
          'type': 'zone',
          'title': trimmed.replaceAll(RegExp(r'^\*\*|\*\*$'), ''),
        };
        currentContent = [];
      }
      // Detect comparison section
      else if (trimmed.toLowerCase().contains('cost comparison') ||
          (trimmed.toLowerCase().contains('comparison') &&
              !trimmed.startsWith('•'))) {
        if (currentSection != null) {
          currentSection['content'] = currentContent.join('\n');
          sections.add(currentSection);
        }
        currentSection = {'type': 'comparison', 'title': trimmed};
        currentContent = [];
      }
      // Detect best value recommendation
      else if ((trimmed.toLowerCase().contains('best value') ||
              trimmed.toLowerCase().contains('recommended')) &&
          !trimmed.startsWith('•')) {
        if (currentSection != null) {
          currentSection['content'] = currentContent.join('\n');
          sections.add(currentSection);
        }
        currentSection = {'type': 'recommendation', 'title': trimmed};
        currentContent = [];
      }
      // Skip **Note sections - they're generic disclaimers
      else if (trimmed.startsWith('**Note') || trimmed == '**Note:**') {
        if (currentSection != null) {
          currentSection['content'] = currentContent.join('\n');
          sections.add(currentSection);
        }
        currentSection = {'type': 'note', 'title': 'Important Note'};
        currentContent = [];
      }
      // Regular content
      else if (trimmed.isNotEmpty) {
        currentContent.add(trimmed);
      }
    }

    // Add final section
    if (currentSection != null) {
      currentSection['content'] = currentContent.join('\n');
      sections.add(currentSection);
    }

    // If no structured sections found, try to split by numbered items
    if (sections.isEmpty || sections.length == 1) {
      sections.clear();
      final zonePattern = RegExp(r'\*\*(\d+)\.\s*([^*]+)\*\*');
      final matches = zonePattern.allMatches(text);

      if (matches.isNotEmpty) {
        for (var i = 0; i < matches.length; i++) {
          final match = matches.elementAt(i);
          final number = match.group(1);
          final zoneName = match.group(2)?.trim() ?? '';

          // Get content until next zone or end
          final startIndex = match.end;
          final endIndex = i < matches.length - 1
              ? matches.elementAt(i + 1).start
              : text.length;

          final content = text.substring(startIndex, endIndex).trim();

          sections.add({
            'type': 'zone',
            'title': '$number. $zoneName',
            'content': content,
          });
        }
      }
    }

    // If still no sections, return as generic
    if (sections.isEmpty) {
      sections.add({
        'type': 'generic',
        'title': 'Recommendations',
        'content': text,
      });
    }

    return sections;
  }

  Widget _buildZoneCard(Map<String, dynamic> section) {
    final title = section['title'] as String;
    final content = section['content'] as String;

    // Extract zone name and pricing
    final zoneMatch = RegExp(
      r'([A-Z][A-Za-z\s&()]+(?:Free Zone|Centre|Authority|FZ|DMCC|IFZA|RAKEZ))',
    ).firstMatch(title);
    final zoneName = zoneMatch?.group(1) ?? title;

    final priceMatch = RegExp(
      r'AED\s+([\d,]+)\s*-\s*([\d,]+)',
    ).firstMatch(content);
    final priceRange = priceMatch != null
        ? 'AED ${priceMatch.group(1)} - ${priceMatch.group(2)}'
        : null;

    // Parse content into structured sections
    final lines = content.split('\n');
    final Map<String, String> sections = {};
    String? currentKey;
    final StringBuffer currentValue = StringBuffer();

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Check if line is a key (contains colon)
      if (trimmed.contains(':') && !trimmed.startsWith('•')) {
        if (currentKey != null) {
          sections[currentKey] = currentValue.toString().trim();
          currentValue.clear();
        }
        final parts = trimmed.split(':');
        currentKey = parts[0].trim();
        if (parts.length > 1) {
          currentValue.write(parts.sublist(1).join(':').trim());
        }
      } else {
        if (currentValue.isNotEmpty) {
          currentValue.write('\n');
        }
        currentValue.write(trimmed);
      }
    }
    if (currentKey != null) {
      sections[currentKey] = currentValue.toString().trim();
    }

    return Card(
      elevation: 4,
      shadowColor: Colors.blue.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.blue.shade300, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zoneName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (priceRange != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.payments_outlined,
                                  size: 16,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  priceRange,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green.shade700,
                                  ),
                                ),
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

            // Content body
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display parsed sections with icons
                  if (sections.isNotEmpty) ...[
                    ...sections.entries.map((entry) {
                      IconData icon = Icons.info_outline;
                      Color iconColor = Colors.blue.shade600;

                      // Assign icons based on key
                      if (entry.key.toLowerCase().contains('suited') ||
                          entry.key.toLowerCase().contains('benefits')) {
                        icon = Icons.check_circle_outline;
                        iconColor = Colors.green.shade600;
                      } else if (entry.key.toLowerCase().contains('cost') ||
                          entry.key.toLowerCase().contains('estimated')) {
                        icon = Icons.monetization_on_outlined;
                        iconColor = Colors.amber.shade700;
                      } else if (entry.key.toLowerCase().contains('includes')) {
                        icon = Icons.inventory_2_outlined;
                        iconColor = Colors.indigo.shade600;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: iconColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(icon, color: iconColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SelectableText(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ] else ...[
                    // Fallback if no structured content
                    SelectableText(
                      content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.6,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Footer with action hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Contact our consultants for detailed quotes',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontStyle: FontStyle.italic,
                      ),
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

  Widget _buildComparisonCard(Map<String, dynamic> section) {
    return Card(
      elevation: 1,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.compare_arrows,
                  color: Colors.amber.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  section['title'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              section['content'] as String,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> section) {
    return Card(
      elevation: 1,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section['title'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    section['content'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
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

  Widget _buildBestValueCard(Map<String, dynamic> section) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section['title'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              section['content'] as String,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenericSection(Map<String, dynamic> section) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (section['title'] != null) ...[
              Text(
                section['title'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
            ],
            SelectableText(
              section['content'] as String,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade800)),
          ),
        ],
      ),
    );
  }
}

class _SummaryStep extends ConsumerWidget {
  const _SummaryStep({required this.onComplete});
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(setupProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            'Your Business Summary',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _SummaryTile(
            title: 'Activities',
            value: data.businessActivities.join(', '),
          ),
          _SummaryTile(
            title: 'Shareholders',
            value: '${data.shareholdersCount}',
          ),
          _SummaryTile(title: 'Visa Slots', value: '${data.visaCount}'),
          _SummaryTile(
            title: 'Visa Type',
            value: data.visaType.isEmpty ? '-' : data.visaType,
          ),
          _SummaryTile(
            title: 'License Tenure',
            value: '${data.licenseTenureYears} year(s)',
          ),
          _SummaryTile(
            title: 'Entity Type',
            value: data.entityType.isEmpty ? '-' : data.entityType,
          ),
          _SummaryTile(
            title: 'Emirate',
            value: data.emirate.isEmpty ? '-' : data.emirate,
          ),
          _SummaryTile(
            title: 'Recommended Zone',
            value: data.recommendedZone.isEmpty ? '-' : data.recommendedZone,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onComplete,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Complete Setup'),
          ),
          const SizedBox(height: 8),
          Text(
            'You can go back to adjust anything before completing.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

// ---------------------- Small UI Helpers ----------------------
class _NumberButton extends StatelessWidget {
  const _NumberButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Icon(icon, color: Colors.blue),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final String value;
  const _SummaryTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value.isEmpty ? '-' : value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------- Gradient Header ----------------------
class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.progress,
    required this.accent,
  });
  final String title;
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6D5DF6), Color(0xFF9B7BF7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 12),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white24,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
