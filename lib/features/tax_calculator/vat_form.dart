import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:intl/intl.dart';
import 'package:cloud_functions/cloud_functions.dart';

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
    'inputVat': FormControl<double>(value: 0),
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

  Future<void> _calculate() async {
    final sales = (form.control('taxableSales').value ?? 0) as double;
    final inputVatVal = (form.control('inputVat').value ?? 0) as double;
    final rate = (form.control('ratePct').value ?? 5) as double;
    final rateDecimal = rate / 100.0;

    setState(() {
      outputVat = sales * rateDecimal;
      netVat = (outputVat ?? 0) - inputVatVal;
      effRate = sales == 0 ? 0 : ((outputVat ?? 0) / sales);
      aiExplanation = null;
    });
  }

  Future<void> _askAI() async {
    setState(() => loadingAI = true);
    try {
      final fn = FirebaseFunctions.instance.httpsCallable('aiTaxExplain');
      final resp = await fn.call({
        "mode": "vat",
        "inputs": form.value,
        "results": {
          "outputVat": outputVat,
          "netVat": netVat,
          "effectiveRate": effRate,
        },
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    InputDecoration dec(String label, {String? helper, String? suffix}) {
      return InputDecoration(
        labelText: label,
        helperText: helper,
        suffixText: suffix,
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      );
    }

    return ReactiveForm(
      formGroup: form,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          Text(
            'VAT Calculator',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),

          // Taxable sales
          ReactiveTextField<double>(
            formControlName: 'taxableSales',
            decoration: dec('Taxable Sales (AED)', suffix: 'AED'),
            keyboardType: TextInputType.number,
            validationMessages: {
              ValidationMessage.required: (_) => 'Required',
              ValidationMessage.min: (_) => 'Must be ≥ 0',
            },
          ),
          const SizedBox(height: 12),

          // Input VAT credit
          ReactiveTextField<double>(
            formControlName: 'inputVat',
            decoration: dec('Input VAT (AED)', suffix: 'AED'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          // VAT rate
          ReactiveTextField<double>(
            formControlName: 'ratePct',
            decoration: dec('VAT Rate (%)', suffix: '%'),
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
                    onPressed: () {
                      form.reset(
                        value: {
                          'taxableSales': null,
                          'inputVat': 0.0,
                          'ratePct': 5.0,
                        },
                      );
                      setState(() {
                        outputVat = null;
                        netVat = null;
                        effRate = null;
                        aiExplanation = null;
                      });
                    },
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Results',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
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
              label: Text(loadingAI ? 'Asking AI...' : 'Ask AI Explanation'),
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
