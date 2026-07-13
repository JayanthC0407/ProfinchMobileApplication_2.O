import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/l10n/app_localizations.dart';

/// Holds the currently selected [Locale] for the whole app.
///
/// • Registered at the root in main.dart as a ChangeNotifierProvider.
/// • MyApp listens to it and passes [locale] to MaterialApp.
/// • _ProfileScreenState reads [selectedLanguageName] to show the
///   current selection in the Language tile subtitle.
/// • _showLanguagePicker calls [setLanguage] when the user taps a row.
class LanguageProvider extends ChangeNotifier {
  // Start with English (India).
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  /// Human-readable display name for the active locale,
  /// e.g. "Kannada", used as the subtitle of the Language tile.
  String get selectedLanguageName =>
      AppLocalizations.localeToName[_locale] ?? 'English (India)';

  /// Call this from the language picker bottom-sheet.
  /// [languageName] must be one of the keys in
  /// AppLocalizations.nameToLocale, e.g. "Hindi".
  void setLanguage(String languageName) {
    final newLocale = AppLocalizations.nameToLocale[languageName];
    if (newLocale == null || newLocale == _locale) return;
    _locale = newLocale;
    notifyListeners(); // triggers MyApp → MaterialApp.locale rebuild
  }
}