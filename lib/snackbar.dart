
import 'package:flutter/material.dart';

class CustomSnackbar {
CustomSnackbar._internal();
static CustomSnackbar? _instance;

factory CustomSnackbar(){
    _instance ??= CustomSnackbar._internal();
    return _instance!;
  }

  BuildContext? _context;

  void init(BuildContext context) {
    _context = context;
    }

  void showNoInternetSnackbar() {
    SnackBar snack = const SnackBar(
      content: Text('No Internet, Kindly check your Internet Connection'),
      backgroundColor: Colors.red,
      elevation: 2,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(),
    );
    if (_context != null) {
      ScaffoldMessenger.of(_context!).showSnackBar(snack);
    }
  }
}
