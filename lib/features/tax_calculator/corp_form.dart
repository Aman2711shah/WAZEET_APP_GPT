import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CorpForm extends StatefulWidget {
  const CorpForm({super.key});

  @override
  State<CorpForm> createState() => _CorpFormState();
}

class _CorpFormState extends State<CorpForm> {
  final form = FormGroup({
    'profitBeforeTax': FormControl<double>(
      validators: [Validators.required, Validators.min(0)],
    ),
    'adjustments': FormControl<double>(value: 0),
    'lossesBf': FormControl<double>(value: 0, validators: [Validators.min(0)]),
    'isFreeZone': FormControl<bool>(value: false),
    'qualifyingIncomePct': FormControl<double>(
      value: 0,
      validators: [Validators.min(0), Validators.max(100)],
    ),
    'threshold': FormControl<double>(
      value: 375000,
      validators: [Validators.min(0)],
    ),
    'mainRatePct': FormControl<double>(
      value: 9,
      validators: [Validators.min(0), Validators.max(100)],
    ),
  });

  double? taxableIncome;
  double? qualifyingAmount;
  double? nonQualifyingAmount;
  double? slabAboveThreshold;
  double? taxDue;
  double? effectiveRate;
  String? aiExplanation;
  bool loadingAI = false;

  InputDecoration _fieldDecoration(
    String label, {
    String? helper,
    String? suffix,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      helperText: helper,
      suffixText: suffix,
      suffixIcon: suffixIcon,
      border: const OutlineInputBorder(),
    );
  }

  double _doubleValue(String controlName, [double fallback = 0]) {
    final value = form.control(controlName).value;
    if (value is num) return value.toDouble();
    return fallback;
  }

  bool _boolValue(String controlName) {
    final value = form.control(controlName).value;
    if (value is bool) return value;
    return false;
  }

  void _recompute() {
    final profitBeforeTax = _doubleValue('profitBeforeTax');
    final adjustments = _doubleValue('adjustments');
    final losses = _doubleValue('lossesBf');
    final isFreeZone = _boolValue('isFreeZone');
    final qualifyingPct = _doubleValue(
      'qualifyingIncomePct',
    ).clamp(0, 100).toDouble();
    final threshold = _doubleValue('threshold');
    final mainRate = _doubleValue('mainRatePct').clamp(0, 100).toDouble() / 100;

    final rawTaxable = profitBeforeTax + adjustments - losses;
    final sanitizedTaxable = rawTaxable < 0 ? 0.0 : rawTaxable;

    double qualifying = 0;
    double nonQualifying = sanitizedTaxable;

    if (isFreeZone) {
      qualifying = sanitizedTaxable * (qualifyingPct / 100);
      nonQualifying = sanitizedTaxable - qualifying;
    }

    double slab = nonQualifying - threshold;
    if (slab < 0) slab = 0;
    final tax = slab * mainRate;
    final effRate = sanitizedTaxable == 0 ? 0.0 : tax / sanitizedTaxable;

    setState(() {
      taxableIncome = sanitizedTaxable;
      qualifyingAmount = qualifying;
      nonQualifyingAmount = nonQualifying;
      slabAboveThreshold = slab;
      taxDue = tax;
      effectiveRate = effRate;
      aiExplanation = null;
    });
  }

  Future<void> _askAI() async {
    if (taxDue == null) return;
    setState(() => loadingAI = true);
    try {
      final fn = FirebaseFunctions.instance.httpsCallable('aiTaxExplain');
      final response = await fn.call({
        'mode': 'corp',
        'inputs': form.value,
        'results': {
          'taxableIncome': taxableIncome,
          'qualifyingAmount': qualifyingAmount,
          'nonQualifyingAmount': nonQualifyingAmount,
          'slabAboveThreshold': slabAboveThreshold,
          'taxDue': taxDue,
          'effectiveRate': effectiveRate,
        },
        'locale': 'en',
        'currency': 'AED',
      });
      setState(() {
        aiExplanation = (response.data['explanation'] ?? '').toString();
      });
    } catch (error) {
      setState(() {
        aiExplanation = 'Unable to fetch AI explanation: $error';
      });
    } finally {
      setState(() => loadingAI = false);
    }
  }

  void _reset() {
    form.reset(
      value: {
        'profitBeforeTax': null,
        'adjustments': 0.0,
        'lossesBf': 0.0,
        'isFreeZone': false,
        'qualifyingIncomePct': 0.0,
        'threshold': 375000.0,
        'mainRatePct': 9.0,
      },
    );
    setState(() {
      taxableIncome = null;
      qualifyingAmount = null;
      nonQualifyingAmount = null;
      slabAboveThreshold = null;
      taxDue = null;
      effectiveRate = null;
      aiExplanation = null;
    });
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final currency = NumberFormat.currency(name: 'AED', symbol: 'AED ');
    final percent = NumberFormat.decimalPattern()
      ..minimumFractionDigits = 2
      ..maximumFractionDigits = 2;
    final isFreeZone = _boolValue('isFreeZone');

    return ReactiveForm(
      formGroup: form,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Corporate Tax Calculator',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Estimate UAE corporate tax, including Free Zone qualifying income split.',
            ),
            const SizedBox(height: 16),
            ReactiveTextField<double>(
              formControlName: 'profitBeforeTax',
              decoration: _fieldDecoration(
                'Accounting Profit Before Tax (AED)',
                suffix: 'AED',
              ),
              keyboardType: TextInputType.number,
              validationMessages: {
                ValidationMessage.required: (_) => 'Required',
                ValidationMessage.min: (_) => 'Must be ≥ 0',
              },
            ),
            const SizedBox(height: 12),
            ReactiveTextField<double>(
              formControlName: 'adjustments',
              decoration: _fieldDecoration(
                'Adjustments (net, AED)',
                helper: 'Positive = add-backs, Negative = deductions',
                suffix: 'AED',
                suffixIcon: Tooltip(
                  message:
                      'Add-backs increase taxable income while deductions reduce it.',
                  child: Icon(Icons.info_outline, color: scheme.primary),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ReactiveTextField<double>(
              formControlName: 'lossesBf',
              decoration: _fieldDecoration(
                'Brought-forward Tax Losses (AED)',
                suffix: 'AED',
              ),
              keyboardType: TextInputType.number,
              validationMessages: {ValidationMessage.min: (_) => 'Must be ≥ 0'},
            ),
            const SizedBox(height: 12),
            ReactiveSwitchListTile(
              formControlName: 'isFreeZone',
              title: Row(
                children: [
                  const Text('Free Zone entity?'),
                  const SizedBox(width: 6),
                  Tooltip(
                    message:
                        'Free Zone entities can enjoy 0% qualifying income rates.',
                    child: Icon(Icons.info_outline, color: scheme.primary),
                  ),
                ],
              ),
            ),
            if (isFreeZone) ...[
              const SizedBox(height: 12),
              ReactiveTextField<double>(
                formControlName: 'qualifyingIncomePct',
                decoration: _fieldDecoration(
                  'Qualifying Income % (0–100)',
                  helper:
                      'Share of taxable income eligible for the 0% Free Zone rate.',
                  suffix: '%',
                ),
                keyboardType: TextInputType.number,
                validationMessages: {
                  ValidationMessage.min: (_) => 'Min 0',
                  ValidationMessage.max: (_) => 'Max 100',
                },
              ),
            ],
            const SizedBox(height: 12),
            ReactiveTextField<double>(
              formControlName: 'threshold',
              decoration: _fieldDecoration('Threshold (AED)', suffix: 'AED'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ReactiveTextField<double>(
              formControlName: 'mainRatePct',
              decoration: _fieldDecoration('Main Rate (%)', suffix: '%'),
              keyboardType: TextInputType.number,
              validationMessages: {
                ValidationMessage.min: (_) => 'Min 0',
                ValidationMessage.max: (_) => 'Max 100',
              },
            ),
            const SizedBox(height: 20),
            ReactiveFormConsumer(
              builder: (context, fg, __) {
                final enabled = fg.valid;
                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: enabled ? _recompute : null,
                        child: const Text('Calculate'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _reset,
                      child: const Text('Reset'),
                    ),
                  ],
                );
              },
            ),
            if (taxableIncome != null) ...[
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            (taxDue ?? 0) > 0
                                ? Icons.warning
                                : Icons.check_circle,
                            color: (taxDue ?? 0) > 0
                                ? Colors.red
                                : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Taxable Income: ${currency.format(taxableIncome)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Above Threshold Base: ${currency.format(slabAboveThreshold)}',
                          ),
                          Text(
                            'Effective Rate: ${percent.format((effectiveRate ?? 0) * 100)}%',
                          ),
                        ],
                      ),
                      if (isFreeZone) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Qualifying @ 0%: ${currency.format(qualifyingAmount)}',
                        ),
                        Text(
                          'Non-qualifying: ${currency.format(nonQualifyingAmount)}',
                        ),
                      ],
                      const Divider(),
                      Text(
                        'Tax Due: ${currency.format(taxDue)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: (taxDue ?? 0) > 0 ? Colors.red : Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text((taxDue ?? 0) > 0 ? 'Payable' : 'No Tax'),
                    backgroundColor: (taxDue ?? 0) > 0
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                  ),
                  Chip(
                    label: Text(
                      'Effective: ${percent.format((effectiveRate ?? 0) * 100)}%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: loadingAI ? null : _askAI,
                icon: const Icon(Icons.smart_toy),
                label: Text(loadingAI ? 'Asking AI…' : 'Ask AI Explanation'),
              ),
              if (aiExplanation != null) ...[
                const SizedBox(height: 12),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(aiExplanation!),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              const SafeArea(top: false, child: SizedBox.shrink()),
            ],
          ],
        ),
      ),
    );
  }
}
