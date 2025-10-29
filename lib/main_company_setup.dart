import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'company_setup_flow.dart';

void main() {
  runApp(const ProviderScope(child: CompanySetupApp()));
}

class CompanySetupApp extends StatelessWidget {
  const CompanySetupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WAZEET - Company Setup',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D5DF6)),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const CompanySetupFlow(),
    );
  }
}
