import 'package:flutter/material.dart';

abstract final class AppRadii {
  static const double controlSmall = 12;
  static const double chip = 999;
  static const double card = 22;
  static const double panel = 28;

  static BorderRadius get controlSmallRadius =>
      BorderRadius.circular(controlSmall);

  static BorderRadius get chipRadius => BorderRadius.circular(chip);

  static BorderRadius get cardRadius => BorderRadius.circular(card);

  static BorderRadius get panelRadius => BorderRadius.circular(panel);
}
