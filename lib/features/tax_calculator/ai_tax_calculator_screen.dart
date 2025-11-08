import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:intl/intl.dart';
import 'tax_math.dart';
import 'tax_models.dart';
import 'firebase_ai_service.dart';

class AiTaxCalculatorScreen extends StatefulWidget {
  const AiTaxCalculatorScreen({super.key});

  @override
  State<AiTaxCalculatorScreen> createState() => _AiTaxCalculatorScreenState();
}

class _AiTaxCalculatorScreenState extends State<AiTaxCalculatorScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final _vatForm = FormGroup({
    'amount': FormControl<double>(
      validators: [Validators.required, Validators.number, Validators.min(0)],
    ),
    'rate': FormControl<double>(
      value: 5,
      validators: [
        Validators.required,
        Validators.number,
        Validators.min(0),
        Validators.max(100),
      ],
    ),
    'inclusive': FormControl<bool>(value: false),
  });

  final _corpForm = FormGroup({
    'revenue': FormControl<double>(
      validators: [Validators.required, Validators.number, Validators.min(0)],
    ),
    'expenses': FormControl<double>(
      value: 0,
      validators: [Validators.required, Validators.number, Validators.min(0)],
    ),
    'adjustments': FormControl<double>(value: 0),
    'qfzp': FormControl<bool>(value: false),
    'qualifyingIncome': FormControl<double>(
      value: 0,
      validators: [Validators.min(0)],
    ),
  });

  String? _aiText;
  bool _loadingAI = false;
  final _ai = FirebaseAIService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _vatForm.dispose();
    _corpForm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI VAT & Corporate Tax'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'VAT'),
            Tab(text: 'Corporate Tax'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildVatTab(scheme), _buildCorpTab(scheme)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loadingAI ? null : _onAskAI,
        icon: _loadingAI
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.smart_toy),
        label: Text(_loadingAI ? 'Asking AI…' : 'Ask AI to explain'),
      ),
    );
  }

  Widget _buildVatTab(ColorScheme scheme) {
    return ReactiveForm(
      formGroup: _vatForm,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ReactiveTextField<double>(
            formControlName: 'amount',
            decoration: const InputDecoration(
              labelText: 'Amount',
              hintText: 'e.g. 1000.00',
              prefixIcon: Icon(Icons.numbers),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          ReactiveTextField<double>(
            formControlName: 'rate',
            decoration: const InputDecoration(
              labelText: 'VAT Rate %',
              hintText: 'e.g. 5',
              prefixIcon: Icon(Icons.percent),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 8),
          ReactiveSwitchListTile(
            formControlName: 'inclusive',
            title: const Text('Amount includes VAT'),
          ),
          const SizedBox(height: 16),
          _VatResultCard(form: _vatForm),
          if (_aiText != null) ...[
            const SizedBox(height: 16),
            _AiResult(text: _aiText!),
          ],
        ],
      ),
    );
  }

  Widget _buildCorpTab(ColorScheme scheme) {
    return ReactiveForm(
      formGroup: _corpForm,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ReactiveTextField<double>(
            formControlName: 'revenue',
            decoration: const InputDecoration(
              labelText: 'Revenue (AED)',
              prefixIcon: Icon(Icons.trending_up),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          ReactiveTextField<double>(
            formControlName: 'expenses',
            decoration: const InputDecoration(
              labelText: 'Deductible Expenses (AED)',
              prefixIcon: Icon(Icons.local_atm),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          ReactiveTextField<double>(
            formControlName: 'adjustments',
            decoration: const InputDecoration(
              labelText: 'Other Adjustments (± AED)',
              prefixIcon: Icon(Icons.tune),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 8),
          ReactiveSwitchListTile(
            formControlName: 'qfzp',
            title: const Text('Qualifying Free Zone Person (QFZP)'),
          ),
          const SizedBox(height: 8),
          ReactiveTextField<double>(
            formControlName: 'qualifyingIncome',
            decoration: const InputDecoration(
              labelText: 'Qualifying Income at 0% (AED)',
              prefixIcon: Icon(Icons.verified),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          _CorpResultCard(form: _corpForm),
          if (_aiText != null) ...[
            const SizedBox(height: 16),
            _AiResult(text: _aiText!),
          ],
        ],
      ),
    );
  }

  Future<void> _onAskAI() async {
    setState(() {
      _loadingAI = true;
      _aiText = null;
    });

    try {
      if (_tabController.index == 0) {
        // VAT
        if (!_vatForm.valid) {
          _vatForm.markAllAsTouched();
          setState(() => _loadingAI = false);
          return;
        }
        final input = VatInput(
          amount: _vatForm.control('amount').value as double,
          vatRate: _vatForm.control('rate').value as double,
          amountIncludesVat: _vatForm.control('inclusive').value as bool,
        );
        final result = calculateVat(input);
        final text = await _ai.explainTax(
          payload: {
            'type': 'vat',
            'input': {
              'amount': input.amount,
              'vatRate': input.vatRate,
              'inclusive': input.amountIncludesVat,
            },
            'result': {
              'net': result.net,
              'vat': result.vat,
              'gross': result.gross,
            },
          },
        );
        setState(() => _aiText = text);
      } else {
        // Corporate tax
        if (!_corpForm.valid) {
          _corpForm.markAllAsTouched();
          setState(() => _loadingAI = false);
          return;
        }
        final input = CorporateTaxInput(
          revenue: _corpForm.control('revenue').value as double,
          deductibleExpenses: _corpForm.control('expenses').value as double,
          otherAdjustments: _corpForm.control('adjustments').value as double,
          qualifyingFreeZone: _corpForm.control('qfzp').value as bool,
          qualifyingIncome:
              _corpForm.control('qualifyingIncome').value as double,
        );
        final result = calculateCorporateTax(input);
        final text = await _ai.explainTax(
          payload: {
            'type': 'corporate',
            'input': {
              'revenue': input.revenue,
              'deductibleExpenses': input.deductibleExpenses,
              'otherAdjustments': input.otherAdjustments,
              'qfzp': input.qualifyingFreeZone,
              'qualifyingIncome': input.qualifyingIncome,
            },
            'result': {
              'taxableProfit': result.taxableProfit,
              'zeroBandTaxable': result.zeroBandTaxable,
              'ninePercentTaxable': result.ninePercentTaxable,
              'taxDue': result.taxDue,
            },
          },
        );
        setState(() => _aiText = text);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('AI error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loadingAI = false);
    }
  }
}

class _VatResultCard extends StatelessWidget {
  const _VatResultCard({required this.form});
  final FormGroup form;

  @override
  Widget build(BuildContext context) {
    final amount = form.control('amount').value as double?;
    final rate = form.control('rate').value as double?;
    final inclusive = form.control('inclusive').value as bool? ?? false;

    if (amount == null || rate == null) {
      return const _InfoCard(text: 'Enter inputs to see VAT result');
    }

    final r = calculateVat(
      VatInput(amount: amount, vatRate: rate, amountIncludesVat: inclusive),
    );
    return _InfoCard(
      text: 'Net: ${_fmt(r.net)}\nVAT: ${_fmt(r.vat)}\nGross: ${_fmt(r.gross)}',
    );
  }
}

class _CorpResultCard extends StatelessWidget {
  const _CorpResultCard({required this.form});
  final FormGroup form;

  @override
  Widget build(BuildContext context) {
    final revenue = form.control('revenue').value as double?;
    final expenses = form.control('expenses').value as double? ?? 0;
    final adj = form.control('adjustments').value as double? ?? 0;
    final qfzp = form.control('qfzp').value as bool? ?? false;
    final qIncome = form.control('qualifyingIncome').value as double? ?? 0;

    if (revenue == null) {
      return const _InfoCard(text: 'Enter inputs to see Corporate Tax result');
    }

    final r = calculateCorporateTax(
      CorporateTaxInput(
        revenue: revenue,
        deductibleExpenses: expenses,
        otherAdjustments: adj,
        qualifyingFreeZone: qfzp,
        qualifyingIncome: qIncome,
      ),
    );

    return _InfoCard(
      text:
          'Taxable profit: ${_fmt(r.taxableProfit)}\n0% band: ${_fmt(r.zeroBandTaxable)}\n9% band: ${_fmt(r.ninePercentTaxable)}\nTax due: ${_fmt(r.taxDue)}',
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14, height: 1.4)),
    );
  }
}

class _AiResult extends StatelessWidget {
  const _AiResult({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(.25)),
      ),
      child: Text(text),
    );
  }
}

String _fmt(num v) => NumberFormat('#,##0.00', 'en_US').format(v);
