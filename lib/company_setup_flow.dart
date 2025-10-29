import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final String recommendedZone; // computed/dummy

  const SetupData({
    this.businessActivities = const [],
    this.shareholdersCount = 1,
    this.visaCount = 0,
    this.licenseTenureYears = 1,
    this.entityType = '',
    this.recommendedZone = '',
  });

  SetupData copyWith({
    List<String>? businessActivities,
    int? shareholdersCount,
    int? visaCount,
    int? licenseTenureYears,
    String? entityType,
    String? recommendedZone,
  }) {
    return SetupData(
      businessActivities: businessActivities ?? this.businessActivities,
      shareholdersCount: shareholdersCount ?? this.shareholdersCount,
      visaCount: visaCount ?? this.visaCount,
      licenseTenureYears: licenseTenureYears ?? this.licenseTenureYears,
      entityType: entityType ?? this.entityType,
      recommendedZone: recommendedZone ?? this.recommendedZone,
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
      current.add(activity);
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
  static const _totalSteps = 8; // 0..7
  final _pageController = PageController();
  String _activityQuery = '';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isCurrentStepValid(SetupData data, int step) {
    switch (step) {
      case 0:
        return true; // Welcome always valid
      case 1:
        return data.businessActivities.isNotEmpty;
      case 2:
        return data.shareholdersCount >= 1 && data.shareholdersCount <= 10;
      case 3:
        return data.visaCount >= 0 && data.visaCount <= 10;
      case 4:
        return data.licenseTenureYears >= 1 && data.licenseTenureYears <= 3;
      case 5:
        return data.entityType.isNotEmpty;
      case 6:
        return true; // Recommender screen always passable
      case 7:
        return true; // Summary: Complete is always enabled
      default:
        return false;
    }
  }

  void _goNext(int step) {
    if (step == 5) {
      // Compute recommendation before entering step 6
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
                _WelcomeStep(onStart: () => _goNext(step)),
                _ActivitiesStep(
                  query: _activityQuery,
                  onQueryChanged: (q) => setState(() => _activityQuery = q),
                ),
                _ShareholdersStep(),
                _VisaStep(),
                _TenureStep(),
                _EntityStep(),
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
                      onPressed: step == 0 ? null : _goBack,
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
      return 'Welcome';
    case 1:
      return 'Business Activities';
    case 2:
      return 'Shareholders';
    case 3:
      return 'Visa Requirements';
    case 4:
      return 'License Tenure';
    case 5:
      return 'Legal Entity Type';
    case 6:
      return 'Smart Recommender';
    case 7:
      return 'Summary';
    default:
      return 'Company Setup';
  }
}

// ---------------------- Steps ----------------------
class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'WAZEET',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Let's set up your company in a few guided steps.",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(220, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Start Setup'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivitiesStep extends ConsumerWidget {
  const _ActivitiesStep({required this.query, required this.onQueryChanged});
  final String query;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(setupProvider);
    final controller = ref.read(setupProvider.notifier);

    final filtered = kActivities
        .where((a) => a.toLowerCase().contains(query.toLowerCase()))
        .toList();

    final isValid = data.businessActivities.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            'Select Business Activities',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose at least one. You can change this later.',
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
                hintText: 'Search activities',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: onQueryChanged,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filtered
                .map(
                  (a) => FilterChip(
                    label: Text(a),
                    selected: data.businessActivities.contains(a),
                    onSelected: (_) => controller.toggleActivity(a),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          if (!isValid)
            const Text(
              'Please select at least one activity to proceed.',
              style: TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 8),
          if (data.businessActivities.isNotEmpty) ...[
            const Text(
              'Selected:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.businessActivities
                  .map((a) => Chip(label: Text(a)))
                  .toList(),
            ),
          ],
        ],
      ),
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
          const SizedBox(height: 12),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text('What does visa processing involve?'),
              childrenPadding: const EdgeInsets.only(
                bottom: 8,
                left: 8,
                right: 8,
              ),
              children: const [
                Text(
                  'Visa processing typically takes 5–10 working days after company formation, '
                  'including medical and Emirates ID. Requirements vary based on the free zone and activity.',
                ),
              ],
            ),
          ),
        ],
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
    int base = 12000; // dummy
    int yearly = 8000; // dummy
    int estimated = base + (selected - 1) * yearly + data.visaCount * 1500;

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
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: Colors.blue.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Estimated cost: AED $estimated',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
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

class _RecommenderStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(setupProvider);

    final alternatives = [
      const _ZoneOption(
        'RAKEZ Flexi Desk',
        'Cost-effective starter option',
        Icons.apartment,
      ),
      const _ZoneOption(
        'Sharjah Media City',
        'Great for creative businesses',
        Icons.movie_filter,
      ),
      const _ZoneOption(
        'Dubai CommerCity',
        'E-commerce logistics friendly',
        Icons.local_shipping,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            'Smart Free Zone Recommender',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Based on your selections, we recommend:',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.rocket_launch, color: Colors.blue, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.recommendedZone.isNotEmpty
                              ? data.recommendedZone
                              : 'RAKEZ Business Hub',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tailored to: ${data.businessActivities.join(', ')}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'You might also consider:',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...alternatives.map(
            (z) => Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(z.icon, color: Colors.blue),
                title: Text(z.title),
                subtitle: Text(z.subtitle),
              ),
            ),
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
            title: 'License Tenure',
            value: '${data.licenseTenureYears} year(s)',
          ),
          _SummaryTile(
            title: 'Entity Type',
            value: data.entityType.isEmpty ? '-' : data.entityType,
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

class _ZoneOption {
  final String title;
  final String subtitle;
  final IconData icon;
  const _ZoneOption(this.title, this.subtitle, this.icon);
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
