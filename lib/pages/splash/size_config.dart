import 'package:flutter/widgets.dart';

class SizeConfig {
  static double? screenW;
  static double? screenH;
  static double? blockV;

  void init(BuildContext context) {
    screenW = MediaQuery.of(context).size.width;
    screenH = MediaQuery.of(context).size.height;
    blockV = screenH! / 100;
  }
}
