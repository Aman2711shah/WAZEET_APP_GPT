import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/quote/ui/freezone_picker_screen.dart';

/// Wrapper page that embeds the quote flow's freezone picker as entry point
class FreezoneQuotePage extends ConsumerWidget {
  const FreezoneQuotePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const FreezonePickerScreen();
  }
}
