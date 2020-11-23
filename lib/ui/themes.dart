
import 'package:flutter/material.dart';

final ThemeData kLightTheme = _buildLightTheme();

ThemeData _buildLightTheme() {
  final base = ThemeData.light();

  return base.copyWith(
    primaryColor: Color(0xff80bc00),
    accentColor: Color(0xdf1a428a),
    canvasColor: Colors.transparent,
    //primaryIconTheme: IconThemeData(color: Colors.grey[800]),
    primaryIconTheme: IconThemeData(color: Color(0xff60269e)),
    iconTheme: IconThemeData(color: Color(0xff60269e)),
  );
}

class Themes {
  final ThemeData themeData;

  Themes({@required this.themeData});

  factory Themes.lightTheme() {
    return Themes(themeData: kLightTheme);
  }
}
