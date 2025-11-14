import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';

class VatForm extends StatefulWidget {
  const VatForm({super.key});

  @override
  State<VatForm> createState() => _VatFormState();
}

class _VatFormState extends State<VatForm> {
  final form = FormGroup({
    'taxableSales': FormControl<double>(
      validators: [Validators.required, Validators.min(0)],
    ),
    'inputVat': FormControl<double>(value: 0, validators: [Validators.min(0)]),
    'ratePct': FormControl<double>(
      value: 5,
      validators: [Validators.min(0), Validators.max(100)],
    ),
  });

  double? outputVat;
  double? netVat;
  double? effRate;
  String? aiExplanation;
  bool loadingAI = false;

  InputDecoration _decoration(
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

  double _doubleValue(String controlName) {
    final value = form.control(controlName).value;
    if (value is num) {
      return value.toDouble();
    }
    return 0;
  }

  void _calculate() {
    final sales = _doubleValue('taxableSales');
    final inputVatVal = _doubleValue('inputVat');
    final ratePct = _doubleValue('ratePct').clamp(0, 100).toDouble();
    final rate = ratePct / 100;

    final output = sales * rate;
    final net = output - inputVatVal;
    final effective = sales == 0 ? 0.0 : output / sales;

    setState(() {
      outputVat = output;
      netVat = net;
      effRate = effective;
      aiExplanation = null;
    });
  }

  Future<void> _askAI() async {
    if (outputVat == null) return;
    setState(() => loadingAI = true);
    try {
      final fn = FirebaseFunctions.instance.httpsCallable('aiTaxExplain');
      final resp = await fn.call({
        'mode': 'vat',
        'inputs': form.value,
        'results': {
          'outputVat': outputVat,
          'netVat': netVat,
          'effectiveRate': effRate,
        },
      });
      setState(() {
        aiExplanation = (resp.data['explanation'] ?? '').toString();
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
    form.reset(value: {'taxableSales': null, 'inputVat': 0.0, 'ratePct': 5.0});
    setState(() {
      outputVat = null;
      netVat = null;
      effRate = null;
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final nf = NumberFormat.currency(name: 'AED', symbol: 'AED ');

    return ReactiveForm(
      formGroup: form,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('VAT Calculator', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Estimate output and net VAT for a tax period.'),
            const SizedBox(height: 16),
            ReactiveTextField<double>(
              formControlName: 'taxableSales',
              decoration: _decoration('Taxable Sales (AED)', suffix: 'AED'),
              keyboardType: TextInputType.number,
              validationMessages: {
                ValidationMessage.required: (_) => 'Required',
                ValidationMessage.min: (_) => 'Must be ≥ 0',
              },
            ),
            const SizedBox(height: 12),
            ReactiveTextField<double>(
              formControlName: 'inputVat',
              decoration: _decoration(
                'Input VAT (AED)',
                suffix: 'AED',
                suffixIcon: Tooltip(
                  message:
                      'Input VAT is the VAT paid on purchases and deductible against output VAT.',
                  child: Icon(Icons.info_outline, color: scheme.primary),
                ),
              ),
              keyboardType: TextInputType.number,
              validationMessages: {ValidationMessage.min: (_) => 'Must be ≥ 0'},
            ),
            const SizedBox(height: 12),
            ReactiveTextField<double>(
              formControlName: 'ratePct',
              decoration: _decoration('VAT Rate (%)', suffix: '%'),
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
                        onPressed: enabled ? _calculate : null,
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
            if (outputVat != null) ...[
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                color: (netVat ?? 0) < 0
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            (netVat ?? 0) < 0
                                ? Icons.check_circle
                                : Icons.warning,
                            color: (netVat ?? 0) < 0
                                ? Colors.green
                                : Colors.red,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Results',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Output VAT'),
                                const SizedBox(height: 4),
                                Text(
                                  nf.format(outputVat),
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Net VAT'),
                                const SizedBox(height: 4),
                                Text(
                                  nf.format(netVat),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: (netVat ?? 0) < 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Effective Rate: ${((effRate ?? 0) * 100).toStringAsFixed(2)}%',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
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
