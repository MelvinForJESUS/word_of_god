//theme.dart
//GODisLOVE

import 'package:flutter/material.dart';

class AppTheme {
  // Define your color palette here with descriptive names
  static const Color godTheFather = Color(0xFF0A1F3A);        // Deep Cosmic Blue
  static const Color churchPurple = Color(0xFF663399);        // Apostolic Purple
  static const Color jesusChristCrimson = Color(0xFF8B0000);    // Sacrificial Crimson
  static const Color holySpirit = Color(0xFFFF6B35);        // Fiery Pentecost Orange
  static const Color jesusChristGold = Color(0xFFD4AF37);      // Resurrection Gold
  static const Color maryBlue = Color(0xFF4169E1);          // Celestial Blue
  static const Color maryWhite = Color(0xFFF8F9FA);          // Purity White
  static const Color churchGold = Color(0xFFD4AF37);        // Unified Gold (Duplicated - consider if needed)
  static const Color accentGold = Color(0xFFB8860B);       // Muted, Antique Gold (DarkGoldenrod)
  static const Color resurrectionGold = Color(0xFFDAA520); // Goldenrod - A more vibrant gold
  static const Color shimmeringGold = Color(0xFFF0E68C); // Khaki - A brighter, more metallic gold


  // Define your light theme
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue, // Default primarySwatch - can be refined further, currently blue for general UI elements if needed
    primaryColor: godTheFather, // Sets the primary color of the app to godTheFather
    scaffoldBackgroundColor: godTheFather, // Sets the default background color of Scaffolds to godTheFather - you can change this if needed

    appBarTheme: const AppBarTheme(
      backgroundColor: godTheFather, // Sets the AppBar background color to godTheFather
      foregroundColor: Colors.white, // Sets the AppBar text and icon color to white
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: godTheFather, // Sets the default text color of ElevatedButtons to godTheFather
        backgroundColor: Colors.white, // Sets the default background color of ElevatedButtons to white
      ),
    ),
    // You can define more theme properties here like textTheme, etc., as needed for consistent text styles across the app
  );
}