import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
  }

  static double scaleWidth(double width, {double baseWidth = 402}) {
    return screenWidth * (width / baseWidth);
  }

  static double scaleHeight(double height, {double baseHeight = 874}) {
    return screenHeight * (height / baseHeight);
  }
}
