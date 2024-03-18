import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class ColorConstants {
  static const kPrimaryColor = Color(0xFF2B2F5C);
  static const kLiteBlack = Color(0xFF333333);
  static const kBlack = Color(0xFF000000);
  static const kThirdSecondaryColor = Color(0xFF5E6BD8);
  static const kGravishBlueColor = Color(0xFF9BA1D2);
  static const lite_gold = Color(0xFFF6DFB3);
  static const litegrey = Color(0x80E1E0E0);
  static const listbg = Color(0xCCFFFFFF);
  static const Color gradientStart = Color(0xff457DF5);
  static const Color gradientEnd = Color(0xffFD4479);
  static const Color textColor = Color(0xff52616C);

  static const bgGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [gradientStart, gradientEnd],
      transform: GradientRotation(math.pi / 4),
      stops: [0.3, 1]);
}