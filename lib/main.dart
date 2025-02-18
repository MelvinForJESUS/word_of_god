import 'package:flutter/material.dart';
import 'screens/introductory_screen.dart'; // Updated to the new screen file
import 'utils/theme.dart'; // Import the AppTheme
//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart'; // REQUIRED: Import generated Firebase options

// Original main function (modified)
void main() async { // REQUIRED: Add 'async'
  WidgetsFlutterBinding.ensureInitialized(); // REQUIRED: Ensure Flutter binding
  // await Firebase.initializeApp( // REQUIRED: Initialize Firebase
  //   options: DefaultFirebaseOptions.currentPlatform, // REQUIRED: Use generated options
  // );
  runApp(const WordOfGodApp());
}

// Original TheWordOfGodApp class (no changes needed)
class WordOfGodApp extends StatelessWidget {
  const WordOfGodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "The Word of God – My Divine Bible Guidance App",
      theme: AppTheme.lightTheme, // Use the defined lightTheme from AppTheme
      home: const IntroductoryScreen(),
    );
  }
}