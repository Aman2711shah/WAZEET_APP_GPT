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
    return ReactiveForm(
      formGroup: form,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'VAT Calculator',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ReactiveTextField<double>(
            formControlName: 'taxableSales',
            decoration: const InputDecoration(labelText: 'Taxable Sales (AED)'),
            keyboardType: TextInputType.number,
          ),
          ReactiveTextField<double>(
            formControlName: 'inputVat',
            decoration: const InputDecoration(labelText: 'Input VAT (AED)'),
            keyboardType: TextInputType.number,
          ),
          ReactiveTextField<double>(
            formControlName: 'ratePct',
            decoration: const InputDecoration(labelText: 'VAT Rate (%)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: form.valid ? _calculate : null,
            child: const Text('Calculate'),
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
                    Text('Output VAT: \\${nf.format(outputVat)}'),
                    Text(
                      'Net VAT: \\${nf.format(netVat)}',
                      style: TextStyle(
                        color: (netVat ?? 0) < 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      'Effective Rate: \\${((effRate ?? 0) * 100).toStringAsFixed(2)}%',
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
              Text(aiExplanation!, style: const TextStyle(fontSize: 14)),
            ],
          ],
        ],
      ),
    );
  }
}
