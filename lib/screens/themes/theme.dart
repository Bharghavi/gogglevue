import 'package:flutter/material.dart';

final Color appColor = Colors.indigo;

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: appColor,
  primarySwatch: Colors.indigo,
  hintColor: Colors.amber,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: appColor,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: appColor,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 60.0, fontWeight: FontWeight.bold, color: appColor),
    bodyMedium: TextStyle(fontSize: 14.0, color: appColor, fontWeight: FontWeight.bold),
    bodySmall: TextStyle(fontSize: 12.0, color: appColor),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.grey[900],
  scaffoldBackgroundColor: Colors.grey[850],
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[900],
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
);