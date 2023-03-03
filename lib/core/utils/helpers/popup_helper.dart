import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koyevi_kurye/core/services/navigation/navigation_service.dart';

class PopupHelper {
  static BuildContext get _context => NavigationService.context;

  static Future<T> showSuccessDialog<T>(String message,
      {Map<String, Function> actions = const {},
      bool cancelIcon = false}) async {
    return await showDialog(
        context: _context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.green,
              icon: cancelIcon
                  ? IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        NavigationService.back(data: false);
                      })
                  : null,
              title: Text(
                message,
                maxLines: 10,
                style: GoogleFonts.inder(color: Colors.white),
              ),
              actions: actions.keys
                  .map((e) => TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      onPressed: actions[e] as Function(),
                      child: Text(e)))
                  .toList(),
            ));
  }

  static Future<void> showSuccessToast(String message) async {
    Fluttertoast.showToast(
        msg: message,
        textColor: Colors.white,
        backgroundColor: Colors.green,
        toastLength: Toast.LENGTH_LONG);
  }

  static Future<void> showErrorToast(String message) async {
    Fluttertoast.showToast(
        msg: message,
        textColor: Colors.white,
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG);
  }
}
