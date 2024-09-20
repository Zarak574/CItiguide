// import 'package:flutter/material.dart';
// import 'package:rolebase/themes/dark_mode.dart';
// import 'package:rolebase/themes/light_mode.dart';

// class ThemeProvider with ChangeNotifier {
//   ThemeData _themeData = lightMode;

//   ThemeData get themeData => _themeData;

//   bool get isDarkMode => _themeData == darkMode;

//   set themeData(ThemeData themeData){
//     _themeData = themeData;
//     notifyListeners();
//   }

//   void toggleTheme(){
//     if(_themeData == lightMode){
//       themeData = darkMode;
//     } else{
//       themeData = lightMode;
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rolebase/themes/dark_mode.dart';
import 'package:rolebase/themes/light_mode.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode; // Initialize _themeData here

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDark = prefs.getBool('isDarkMode') ?? false;
    _themeData = isDark ? darkMode : lightMode;
    notifyListeners();
  }

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
    _saveTheme();
  }

  Future<void> _saveTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDark = _themeData == darkMode;
    await prefs.setBool('isDarkMode', isDark);
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
