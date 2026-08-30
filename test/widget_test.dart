import 'package:customer/core/localization/app_localizations.dart';
import 'package:customer/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App Theme and Localization providers mount cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            final currentLocale = ref.watch(localeNotifierProvider);
            final themeMode = ref.watch(themeModeProvider);

            return MaterialApp(
              locale: currentLocale,
              themeMode: themeMode,
              home: const Scaffold(
                body: Center(child: Text('PlateRoute Customer App')),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('PlateRoute Customer App'), findsOneWidget);
  });
}
