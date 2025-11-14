import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:intl/intl.dart';
import 'package:cloud_functions/cloud_functions.dart';

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
    'adjustments': FormControl<double>(
          Row(
            children: [
              Expanded(child: Text('Calculation logic: Taxable Income = Profit Before Tax + Adjustments - Losses; Tax Due = (Taxable Income - Threshold) × Main Rate')), 
              Tooltip(
                message: 'Adjustments: positive for add-backs, negative for deductions. Free Zone: special rules apply for qualifying income.',
                child: Icon(Icons.info_outline, color: scheme.primary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),
      value: 0,
      validators: [Validators.min(-1000000000000)],
    ),
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
            decoration: dec(
              'Adjustments (net, AED)',
              helper: 'Use positive for add-backs; negative for deductions',
              suffix: 'AED',
            ).copyWith(
              suffixIcon: Tooltip(
                message: 'Adjustments: add-backs (positive) increase taxable income, deductions (negative) reduce it.',
                child: Icon(Icons.info_outline, color: scheme.primary, size: 20),
              ),
            ),
  double? slabAboveThreshold;
  double? taxDue;
  double? effectiveRate;
  String? aiExplanation;
  bool loadingAI = false;

  void _recompute() {
    final pbt = (form.control('profitBeforeTax').value ?? 0.0) as double;
    final adj = (form.control('adjustments').value ?? 0.0) as double;
    final losses = (form.control('lossesBf').value ?? 0.0) as double;
    final isFZ = (form.control('isFreeZone').value ?? false) as bool;
    final qPct = (form.control('qualifyingIncomePct').value ?? 0.0) as double;
    final threshold = (form.control('threshold').value ?? 375000.0) as double;
    final mainRatePct = (form.control('mainRatePct').value ?? 9.0) as double;
            title: Row(
              children: [
                const Text('Free Zone entity?'),
                const SizedBox(width: 6),
                Tooltip(
                  message: 'Free Zone entities may have special tax rates and qualifying income rules.',
                  child: Icon(Icons.info_outline, color: scheme.primary, size: 20),
                ),
              ],
            ),
    final taxable = (pbt + adj - losses);
    final sanitizedTaxable = taxable < 0 ? 0.0 : taxable;
    final rate = (mainRatePct.clamp(0, 100)) / 100.0;

    double qualifying = 0, nonQual = sanitizedTaxable, slabAbove = 0, tax = 0;

    if (isFZ) {
      qualifying = sanitizedTaxable * (qPct.clamp(0, 100)) / 100.0;
      nonQual = sanitizedTaxable - qualifying;
      slabAbove = (nonQual - threshold);
      if (slabAbove < 0) slabAbove = 0;
      tax = slabAbove * rate;
    } else {
      slabAbove = (sanitizedTaxable - threshold);
      if (slabAbove < 0) slabAbove = 0;
      tax = slabAbove * rate;
    }

    final eff = sanitizedTaxable == 0 ? 0.0 : tax / sanitizedTaxable;

    setState(() {
      taxableIncome = sanitizedTaxable;
      qualifyingAmount = qualifying;
      nonQualifyingAmount = nonQual;
      slabAboveThreshold = slabAbove;
      taxDue = tax;
      effectiveRate = eff;
      aiExplanation = null; // reset
    });
  }

  Future<void> _askAI() async {
    if (taxDue == null) return;
    setState(() => loadingAI = true);
    try {
      final fn = FirebaseFunctions.instance.httpsCallable('aiTaxExplain');
      final resp = await fn.call({
        "mode": "corp",
        "inputs": {
          "profitBeforeTax": form.control('profitBeforeTax').value,
          "adjustments": form.control('adjustments').value,
          "lossesBf": form.control('lossesBf').value,
          "isFreeZone": form.control('isFreeZone').value,
          "qualifyingIncomePct": form.control('qualifyingIncomePct').value,
          "threshold": form.control('threshold').value,
          "mainRatePct": form.control('mainRatePct').value,
        },
        "results": {
          "taxableIncome": taxableIncome,
          "qualifyingAmount": qualifyingAmount,
          "nonQualifyingAmount": nonQualifyingAmount,
          "slabAboveThreshold": slabAboveThreshold,
          "taxDue": taxDue,
          "effectiveRate": effectiveRate,
        },
        "locale": "en",
        "currency": "AED",
      });
      setState(
        () => aiExplanation = (resp.data['explanation'] ?? '').toString(),
      );
    } catch (e) {
      setState(() => aiExplanation = 'Error getting AI explanation: $e');
    } finally {
      setState(() => loadingAI = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat.currency(name: 'AED', symbol: 'AED ');
    final percent = NumberFormat.decimalPattern()
      ..minimumFractionDigits = 2
      ..maximumFractionDigits = 2;

    final isFreeZone = form.control('isFreeZone').value == true;

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: (taxDue ?? 0) > 0 ? Colors.red.shade50 : Colors.green.shade50,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          (taxDue ?? 0) > 0 ? Icons.warning : Icons.check_circle,
                          color: (taxDue ?? 0) > 0 ? Colors.red : Colors.green,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Taxable Income: ${nf.format(taxableIncome)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Above Threshold Base: ${nf.format(slabAboveThreshold)}',
                        ),
                        Text(
                          'Rate: ${((effectiveRate ?? 0) * 100).isNaN ? "0.00" : percent.format((effectiveRate ?? 0) * 100)}% eff',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (form.control('isFreeZone').value == true) ...[
                      Text('Qualifying @ 0%: ${nf.format(qualifyingAmount)}'),
                      Text('Non-qualifying: ${nf.format(nonQualifyingAmount)}'),
                    ],
                    const Divider(),
                    Text(
                      'Tax Due: ${nf.format(taxDue)}',
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
              'Accounting Profit Before Tax (AED)',
              suffix: 'AED',
            ),
            keyboardType: TextInputType.number,
            validationMessages: {
              ValidationMessage.required: (_) => 'Required',
              ValidationMessage.min: (_) => 'Must be ≥ 0',
            },
          ),

          // Adjustments
          const SizedBox(height: 8),
          ReactiveTextField<double>(
            formControlName: 'adjustments',
            decoration: dec(
              'Adjustments (net, AED)',
              helper: 'Use positive for add-backs; negative for deductions',
              suffix: 'AED',
            ),
            keyboardType: TextInputType.number,
          ),

          // Losses brought forward
          const SizedBox(height: 8),
          ReactiveTextField<double>(
            formControlName: 'lossesBf',
            decoration: dec('Brought-forward Tax Losses (AED)', suffix: 'AED'),
            keyboardType: TextInputType.number,
            validationMessages: {ValidationMessage.min: (_) => 'Must be ≥ 0'},
          ),

          // Free Zone toggle
          const SizedBox(height: 8),
          ReactiveSwitchListTile(
            formControlName: 'isFreeZone',
            title: const Text('Free Zone entity?'),
          ),

          // Qualifying income pct (only if FZ)
          if (isFreeZone) ...[
            const SizedBox(height: 8),
            ReactiveTextField<double>(
              formControlName: 'qualifyingIncomePct',
              decoration: const InputDecoration(
                labelText: 'Qualifying Income % (0–100)',
              ),
              keyboardType: TextInputType.number,
              validationMessages: {
                ValidationMessage.min: (_) => 'Min 0',
                ValidationMessage.max: (_) => 'Max 100',
              },
            ),
          ],

          // Threshold & rate
          const SizedBox(height: 8),
          ReactiveTextField<double>(
            formControlName: 'threshold',
            decoration: dec('Threshold (AED)', suffix: 'AED'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          ReactiveTextField<double>(
            formControlName: 'mainRatePct',
            decoration: dec('Main Rate (%)', suffix: '%'),
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
                    onPressed: () {
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
                    },
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Taxable Income: ${nf.format(taxableIncome)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Above Threshold Base: ${nf.format(slabAboveThreshold)}',
                        ),
                        Text(
                          'Rate: ${((effectiveRate ?? 0) * 100).isNaN ? "0.00" : percent.format((effectiveRate ?? 0) * 100)}% eff',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (form.control('isFreeZone').value == true) ...[
                      Text('Qualifying @ 0%: ${nf.format(qualifyingAmount)}'),
                      Text('Non-qualifying: ${nf.format(nonQualifyingAmount)}'),
                    ],
                    const Divider(),
                    Text(
                      'Tax Due: ${nf.format(taxDue)}',
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
                  child: Text(
                    aiExplanation!,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            const SafeArea(top: false, child: SizedBox.shrink()),
          ],
        ],
      ),
    );
  }
}
