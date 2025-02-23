//main.dart
//GODisLOVE

import 'package:flutter/material.dart';
import 'screens/introductory_screen.dart';
import 'utils/theme.dart';

// Future Firebase Integration (Placeholder)
// 1. Add Firebase dependencies to pubspec.yaml:
//    firebase_core: ^latest_version
//    (Add other Firebase packages as needed, e.g., firebase_auth, cloud_firestore)
// 2. Run 'flutter pub get'
// 3. Initialize Firebase in main() (see below)
// 4. Use Firebase services in your app.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Placeholder for Firebase Initialization ---
  // Uncomment and configure when ready to integrate Firebase:
  // try {
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  // } catch (e) {
  //   print("Error initializing Firebase: $e");
  //   // Handle initialization errors (e.g., show an error message to the user)
  // }

  runApp(const WordOfGodApp());
}

class WordOfGodApp extends StatelessWidget {
  const WordOfGodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "The Word of God – My Divine Bible Guidance App",
      theme: AppTheme.lightTheme,
      home: const IntroductoryScreen(),
    );
  }
}