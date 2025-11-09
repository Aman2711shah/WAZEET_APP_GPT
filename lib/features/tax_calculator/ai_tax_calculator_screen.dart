import 'package:flutter/material.dart';
import 'vat_form.dart';
import 'corp_form.dart';

class AiTaxCalculatorScreen extends StatefulWidget {
  const AiTaxCalculatorScreen({super.key});

  @override
  State<AiTaxCalculatorScreen> createState() => _AiTaxCalculatorScreenState();
}

class _AiTaxCalculatorScreenState extends State<AiTaxCalculatorScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI VAT & Corporate Tax'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
            ),
            child: TabBar(
              controller: _tabController,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
              labelColor: scheme.primary,
              unselectedLabelColor: scheme.onSurfaceVariant,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(color: scheme.primary, width: 3),
                insets: const EdgeInsets.symmetric(horizontal: 16),
              ),
              tabs: const [
                Tab(text: 'VAT'),
                Tab(text: 'Corporate Tax'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [VatForm(), CorpForm()],
      ),
    );
  }
}
