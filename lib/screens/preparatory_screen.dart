// preparatory_screen.dart
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use
// God is Love

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'word_of_god_screen.dart';
import '../utils/theme.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class PreparatoryScreen extends StatefulWidget {
  const PreparatoryScreen({super.key});

  @override
  _PreparatoryScreenState createState() => _PreparatoryScreenState();
}

class _PreparatoryScreenState extends State<PreparatoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _verse1AnimationController;
  late Animation<double> _verse1FadeAnimation;
  late AnimationController _verse2AnimationController;
  late Animation<double> _verse2FadeAnimation;
  late AnimationController _verse3AnimationController;
  late Animation<double> _verse3FadeAnimation;
  late AnimationController _buttonGlowAnimationController;
  bool _allVersesVisible = false;

  List<List<Map<String, String>>>? _verseSets; // Nullable
  int _currentVerseSetIndex = 0;
  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    _verse1AnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _verse1FadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _verse1AnimationController, curve: Curves.easeIn));
    _verse2AnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _verse2FadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _verse2AnimationController, curve: Curves.easeIn));
    _verse3AnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _verse3FadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _verse3AnimationController, curve: Curves.easeIn));
    _buttonGlowAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _initData(); // Load JSON and check first launch
  }

  // Combined initialization function
  Future<void> _initData() async {
    await _loadData(); // Await data loading
    _startVerseAnimations(); // Start animations *after* data is loaded
  }

  Future<void> _loadData() async {
    // Load JSON
    final String jsonString =
        await rootBundle.loadString('assets/verse_sets.json');
    final List<dynamic> decodedList = jsonDecode(jsonString);

    // Check if decoding was successful and the result is a list
    if (decodedList is List) {
      // Cast each item in the outer list to List<Map<String, String>>
      _verseSets = decodedList
          .map((verseSet) {
            if (verseSet is List) {
              return verseSet
                  .map((verse) {
                    if (verse is Map) {
                      // Convert Map<dynamic, dynamic> to Map<String, String>
                      return verse.map((key, value) =>
                          MapEntry(key.toString(), value.toString()));
                    }
                    return <String, String>{}; // Return an empty map if not a Map
                  })
                  .toList();
            }
            return <Map<String, String>>[]; // Return an empty list if not a List
          })
          .toList();
    } else {
      // Handle the case where the decoded result is not a list
      _verseSets =
          []; // Initialize to an empty list or handle the error appropriately
    }

    // SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? hasLaunched = prefs.getBool('hasLaunched');

    if (hasLaunched == null) {
      // First launch
      _isFirstLaunch = true;
      await prefs.setBool('hasLaunched', true);
    } else {
      _isFirstLaunch = false;
      _currentVerseSetIndex = prefs.getInt('currentVerseSetIndex') ?? 0;
    }
    // No setState here!
  }

  Future<void> _startVerseAnimations() async {
    await Future.delayed(const Duration(milliseconds: 333));
    if (!mounted) return;
    _verse1AnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 1333)); // Original delays
    if (!mounted) return;
    _verse2AnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 1777));
    if (!mounted) return;
    _verse3AnimationController.forward();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _allVersesVisible = true; // Set the flag to true!
      // Update verse set index for next launch
      if (!_isFirstLaunch) {
        _currentVerseSetIndex = (_currentVerseSetIndex + 1) % _verseSets!.length;
        prefs.setInt('currentVerseSetIndex', _currentVerseSetIndex);
      }
    });
  }

  @override
  void dispose() {
    _verse1AnimationController.dispose();
    _verse2AnimationController.dispose();
    _verse3AnimationController.dispose();
    _buttonGlowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // --- Responsive Values ---
    // Title
    final double titleFontSize = screenWidth * 0.07;
    final double titleShadowBlurRadius = screenWidth * 0.01;
    final double titleShadowOffset = screenWidth * 0.005;
    final double titleTopSpacingVertical = screenHeight * 0.05;
    final double titleBottomSpacingVertical = screenHeight * 0.03;

    // Verses
    final double verseFontSize = screenWidth * 0.065;
    // Conditional padding and spacing
    final double versePaddingVertical =
        screenHeight * (screenWidth < 350 ? 0.015 : 0.01);
    final double verseSpacing =
        screenHeight * (screenWidth < 350 ? 0.01 : 0.005);
    final double versePaddingHorizontal = screenWidth * 0.03;
    final double verseBorderRadius = screenWidth * 0.025;

    // Citation Icon
    final double citationIconSize = screenWidth * 0.03;

    // Button
    final double buttonFontSize = screenWidth * 0.045;
    final double buttonPaddingHorizontal = screenWidth * 0.1;
    final double buttonPaddingVertical = screenHeight * 0.018;
    final double buttonBorderRadius = screenWidth * 0.03;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [
                AppTheme.godTheFather,
                AppTheme.churchPurple,
                AppTheme.maryBlue
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomRight),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title Section
              Padding(
                padding: EdgeInsets.only(
                    top: titleTopSpacingVertical * 0.8,
                    bottom: titleBottomSpacingVertical),
                child: Text( // Removed Column and Underline
                  "Verses to Meditate",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'RobotoSlab',
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                          blurRadius: titleShadowBlurRadius,
                          color: Colors.black26,
                          offset: Offset(titleShadowOffset, titleShadowOffset))
                    ],
                  ),
                ),
              ),

              // Verses Section (Wrapped in Expanded)
              Expanded( // Expanded for dynamic sizing
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      left: screenWidth * 0.06,
                      right: screenWidth * 0.06,
                      top: screenHeight * 0.005, // Reduce top padding a little
                      bottom: 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Verse 1
                      Flexible( // Flexible wrapper
                        child: FadeTransition(
                          opacity: _verse1FadeAnimation,
                          child: _buildVerseContainer(
                            verseText: _isFirstLaunch
                                ? "Cast all your anxieties on Him, for He cares for you."
                                : _verseSets![_currentVerseSetIndex][0]['text']!,
                            citation: _isFirstLaunch
                                ? "1 Peter 5:7"
                                : _verseSets![_currentVerseSetIndex][0][
                                    'citation']!,
                            verseFontSize: verseFontSize,
                            versePaddingVertical: versePaddingVertical,
                            versePaddingHorizontal: versePaddingHorizontal,
                            verseBorderRadius: verseBorderRadius,
                            citationIconSize: citationIconSize,
                            screenWidth: screenWidth,
                          ),
                        ),
                      ),
                      SizedBox(height: verseSpacing), // Conditional spacing

                      // Verse 2
                      Flexible( // Flexible wrapper
                        child: FadeTransition(
                          opacity: _verse2FadeAnimation,
                          child: _buildVerseContainer(
                            verseText: _isFirstLaunch
                                ? "Trust in the Lord with all your heart and lean not on your own understanding."
                                : _verseSets![_currentVerseSetIndex][1]['text']!,
                            citation: _isFirstLaunch
                                ? "Proverbs 3:5-6"
                                : _verseSets![_currentVerseSetIndex][1][
                                    'citation']!,
                            verseFontSize: verseFontSize,
                            versePaddingVertical: versePaddingVertical,
                            versePaddingHorizontal: versePaddingHorizontal,
                            verseBorderRadius: verseBorderRadius,
                            citationIconSize: citationIconSize,
                            screenWidth: screenWidth,
                          ),
                        ),
                      ),
                      SizedBox(height: verseSpacing), // Conditional spacing

                      // Verse 3
                      Flexible( // Flexible wrapper
                        child: FadeTransition(
                          opacity: _verse3FadeAnimation,
                          child: _buildVerseContainer(
                            verseText: _isFirstLaunch
                                ? "I love You, O Lord, and for Your sake, I love my neighbor as myself."
                                : _verseSets![_currentVerseSetIndex][2]['text']!,
                            citation: _isFirstLaunch
                                ? "Matthew 22:37-40"
                                : _verseSets![_currentVerseSetIndex][2][
                                    'citation']!,
                            verseFontSize: verseFontSize,
                            versePaddingVertical: versePaddingVertical,
                            versePaddingHorizontal: versePaddingHorizontal,
                            verseBorderRadius: verseBorderRadius,
                            citationIconSize: citationIconSize,
                            screenWidth: screenWidth,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Button Section
              Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.04),
                child: AnimatedBuilder(
                  animation: _buttonGlowAnimationController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        boxShadow: _allVersesVisible // Use the flag here
                            ? [
                                BoxShadow(
                                  color: AppTheme.accentGold
                                      .withAlpha((60 + //Reduced Alpha
                                          60 * //Reduced Alpha
                                              _buttonGlowAnimationController
                                                  .value)
                                      .toInt()),
                                  blurRadius:
                                      10 * // Reduced blur
                                          _buttonGlowAnimationController.value,
                                  spreadRadius:
                                      2 * // Reduced spread
                                          _buttonGlowAnimationController.value,
                                )
                              ]
                            : null,
                      ),
                      child: ElevatedButton(
                        onPressed: _allVersesVisible // Use the flag here
                            ? () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const WordOfGodScreen()));
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: _allVersesVisible
                              ? AppTheme.godTheFather
                              : Colors.grey.shade700,
                          backgroundColor: _allVersesVisible
                              ? AppTheme.maryWhite
                              : Colors.grey.shade400,
                          elevation: _allVersesVisible ? 8 : 2,
                          shadowColor: _allVersesVisible
                              ? AppTheme.accentGold.withOpacity(0.8)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(buttonBorderRadius)),
                          padding: EdgeInsets.symmetric(
                              horizontal: buttonPaddingHorizontal,
                              vertical: buttonPaddingVertical),
                        ),
                        child: Text("Receive the Word of God",
                            style: TextStyle(
                                fontSize: buttonFontSize,
                                fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build verse containers
  Widget _buildVerseContainer({
    required String verseText,
    required String citation,
    required double verseFontSize,
    required double versePaddingVertical,
    required double versePaddingHorizontal,
    required double verseBorderRadius,
    required double citationIconSize,
    required double screenWidth,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: versePaddingVertical, horizontal: versePaddingHorizontal),
      decoration: BoxDecoration(
        color: Colors.black
            .withOpacity(screenWidth < 350 ? 0.04 : 0.02), // Conditional, lighter color
        borderRadius: BorderRadius.circular(verseBorderRadius),
        border: Border(
          // Add the left border
          left: BorderSide(
            color: AppTheme.accentGold.withOpacity(0.7),
            width: screenWidth * 0.005, // Reduced thickness
          ),
        ),
        boxShadow: [
          // Original, light shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: screenWidth * 0.005,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              verseText,
              textAlign: TextAlign.center,
              style: GoogleFonts.robotoSlab(
                textStyle: TextStyle(
                  fontSize: verseFontSize,
                  color: Colors.white,
                  fontStyle: FontStyle.normal,
                  // fontWeight: FontWeight.bold, // Removed bold
                  shadows: [
                    Shadow(
                        color: const Color.fromARGB(255, 192, 136, 45),
                        blurRadius: screenWidth * 0.005,
                        offset: Offset(
                            screenWidth * 0.0025, screenWidth * 0.0025)),
                  ],
                ),
              ),
            ),
          ),
          Tooltip(
            message: citation,
            waitDuration: Duration.zero,
            showDuration: const Duration(seconds: 3),
            child: Icon(Icons.info_outline,
                color: Colors.white, size: citationIconSize),
          ),
        ],
      ),
    );
  }
}