import 'dart:async';

import 'package:flutter/services.dart';

/// Utility to update the application title for web and the app switcher.
abstract class WebPageTitle {
  static const String _appName = 'BTG Fondos';

  /// Sets the current page title using the BTG Fondos application label.
  static void set([String? title]) {
    final hasPageTitle = title != null && title.trim().isNotEmpty;
    final label = hasPageTitle ? '$title - $_appName' : _appName;

    unawaited(
      SystemChrome.setApplicationSwitcherDescription(
        ApplicationSwitcherDescription(
          label: label,
          primaryColor: 0xFF0051A8,
        ),
      ),
    );
  }
}
