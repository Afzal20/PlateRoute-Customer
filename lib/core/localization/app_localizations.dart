import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/preferences_service.dart';
import 'app_strings.dart';
import 'l10n_bn.dart';
import 'l10n_en.dart';

class AppLocalizations {
  final Locale locale;
  final AppStrings strings;

  const AppLocalizations(this.locale, this.strings);

  static const StringsEn _en = StringsEn();
  static const StringsBn _bn = StringsBn();

  static AppLocalizations of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<_AppLocalizationsScope>();
    if (provider != null) {
      return provider.localizations;
    }
    final currentLocale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    return AppLocalizations(currentLocale, getStrings(currentLocale.languageCode));
  }

  static AppStrings getStrings(String languageCode) {
    if (languageCode == 'bn') {
      return _bn;
    }
    return _en;
  }
}

class _AppLocalizationsScope extends InheritedWidget {
  final AppLocalizations localizations;

  const _AppLocalizationsScope({
    required this.localizations,
    required super.child,
  });

  @override
  bool updateShouldNotify(_AppLocalizationsScope oldWidget) {
    return localizations.locale != oldWidget.localizations.locale;
  }
}

class AppLocalizationsWidget extends StatelessWidget {
  final Locale locale;
  final Widget child;

  const AppLocalizationsWidget({
    super.key,
    required this.locale,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations(
      locale,
      AppLocalizations.getStrings(locale.languageCode),
    );

    return _AppLocalizationsScope(
      localizations: localizations,
      child: child,
    );
  }
}

extension AppLocalizationsX on BuildContext {
  AppStrings get l10n => AppLocalizations.of(this).strings;
}

// Riverpod Provider for Locale
final localeNotifierProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  PreferencesService? _prefs;

  LocaleNotifier() : super(const Locale('en')) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await PreferencesService.create();
    final savedLocale = _prefs?.getLocale() ?? 'en';
    state = Locale(savedLocale);
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    await _prefs?.setLocale(languageCode);
  }
}
