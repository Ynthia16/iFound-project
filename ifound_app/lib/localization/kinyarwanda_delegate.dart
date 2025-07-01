import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class KinyarwandaMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const KinyarwandaMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'rw';
  }

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    // Use English MaterialLocalizations for Kinyarwanda
    return await GlobalMaterialLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(KinyarwandaMaterialLocalizationsDelegate old) => false;
} 