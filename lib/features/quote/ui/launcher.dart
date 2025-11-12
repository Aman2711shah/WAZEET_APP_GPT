import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';

class QuoteFlowApp extends StatelessWidget {
  const QuoteFlowApp({super.key});
  @override
  Widget build(BuildContext context) {
    final router = buildQuoteRouter();
    return ProviderScope(
      child: MaterialApp.router(
        title: 'Freezone Quote',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.deepPurple,
        ),
        routerConfig: router,
      ),
    );
  }
}

/// Convenience host to launch the quote flow inside an existing app via Navigator.push.
class QuoteHost extends StatelessWidget {
  const QuoteHost({super.key});
  @override
  Widget build(BuildContext context) => const QuoteFlowApp();
}
