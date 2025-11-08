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
        children: const [VatForm(), CorpForm()],
      ),
    );
  }
}
