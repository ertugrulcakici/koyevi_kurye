import 'package:flutter/material.dart';

mixin ErrorSupportNotifier on ChangeNotifier {
  bool _hasError = false;
  bool get hasError => _hasError;
  set hasError(bool value) {
    _hasError = value;
    notifyListeners();
  }

  Object? errorDetail;
}
