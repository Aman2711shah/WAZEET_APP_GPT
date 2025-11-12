import 'package:go_router/go_router.dart';
import 'freezone_picker_screen.dart';
import 'package_configurator_screen.dart';
import 'price_breakdown_screen.dart';

GoRouter buildQuoteRouter() {
  return GoRouter(
    initialLocation: '/quote',
    routes: [
      GoRoute(
        path: '/quote',
        builder: (context, state) => const FreezonePickerScreen(),
        routes: [
          GoRoute(
            path: 'config',
            builder: (context, state) => const PackageConfiguratorScreen(),
          ),
          GoRoute(
            path: 'price',
            builder: (context, state) => const PriceBreakdownScreen(),
          ),
        ],
      ),
    ],
  );
}
