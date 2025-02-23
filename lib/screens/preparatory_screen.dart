// preparatory_screen.dart
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use
// God is Love

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
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

  List<List<Map<String, String>>>? _verseSets;
  int _currentVerseSetIndex = 0;

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

    // _initData() is NOT called here. It's handled by the FutureBuilder.
  }

  // Combined initialization function - now returns Future<void>
  Future<void> _initData() async {
    await _loadData(); // Await data loading
    // _startVerseAnimations(); // Moved to didChangeDependencies
  }

  Future<void> _loadData() async {
    // Load JSON
    final String jsonString =
        await rootBundle.loadString('assets/verse_sets.json');
    final dynamic decodedList = jsonDecode(jsonString); // No need to specify List<dynamic> here

    // Check if decoding was successful and the result is a list
    if (decodedList is List) { // Simpler check
      // Cast each item in the outer list to List<Map<String, String>>
      _verseSets = (decodedList) // No need for another is List check here, already checked above
          .map((verseSet) {
            if (verseSet is List) {
              return (verseSet) // No need for another is List check here
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

      // print("Parsed _verseSets: $_verseSets"); // DEBUG PRINT - Consider using a logger instead of print in production
    } else {
      // Handle the case where the decoded result is not a list
      _verseSets =
          []; // Initialize to an empty list or handle the error appropriately
      // print("Error: Decoded JSON is not a list."); // DEBUG PRINT - Consider using a logger instead of print in production
    }

    // SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Always load the index, even on the "first" launch.  If it doesn't exist, it defaults to 0.
    _currentVerseSetIndex = prefs.getInt('currentVerseSetIndex') ?? 0;
    // print("Loaded _currentVerseSetIndex: $_currentVerseSetIndex"); //DEBUG PRINT - Consider using a logger instead of print in production
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start animations *here*, in didChangeDependencies, *after* the first build.
    // This ensures that the widget is fully built and mounted.
    _startVerseAnimations();
  }

  Future<void> _startVerseAnimations() async {
    // No need to check mounted here; didChangeDependencies only runs if mounted.
    await Future.delayed(const Duration(milliseconds: 333));
    _verse1AnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 1333)); // Original delays
    _verse2AnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 1777));
    _verse3AnimationController.forward();
    await Future.delayed(const Duration(seconds: 2));

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // No need for setState here!

    // Always increment and save the index.
    if (_verseSets != null && _verseSets!.isNotEmpty) { // Use isNotEmpty
      _currentVerseSetIndex = (_currentVerseSetIndex + 1) % _verseSets!.length;
    } else {
      _currentVerseSetIndex = 0; // Reset if _verseSets is null or empty.
    }

    // print("Saving _currentVerseSetIndex: $_currentVerseSetIndex"); //DEBUG PRINT - Consider using a logger instead of print in production
    await prefs.setInt('currentVerseSetIndex', _currentVerseSetIndex); //Save it using await
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
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(
          content: Text('Tap back again to leave'),
        ),
        child: FutureBuilder<void>(
          future: _initData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
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
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: titleTopSpacingVertical * 0.8,
                            bottom: titleBottomSpacingVertical),
                        child: Text(
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
                                  offset:
                                      Offset(titleShadowOffset, titleShadowOffset))
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(
                              left: screenWidth * 0.06,
                              right: screenWidth * 0.06,
                              top: screenHeight * 0.005,
                              bottom: 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FadeTransition(
                                opacity: _verse1FadeAnimation,
                                child: _buildVerseContainer(
                                  verseText: (_verseSets != null &&
                                          _verseSets!.isNotEmpty && // Use isNotEmpty
                                          _currentVerseSetIndex <
                                              _verseSets!.length &&
                                          _verseSets![_currentVerseSetIndex]
                                                  .length >
                                              0)
                                      ? _verseSets![_currentVerseSetIndex][0]
                                          ['text']!
                                      : "Verse not found", // Default Value
                                  citation: (_verseSets != null &&
                                          _verseSets!.isNotEmpty && // Use isNotEmpty
                                          _currentVerseSetIndex <
                                              _verseSets!.length &&
                                          _verseSets![_currentVerseSetIndex]
                                                  .length >
                                              0)
                                      ? _verseSets![_currentVerseSetIndex][0]
                                          ['citation']!
                                      : "Unknown", // Default Value,
                                  verseFontSize: verseFontSize,
                                  versePaddingVertical: versePaddingVertical,
                                  versePaddingHorizontal: versePaddingHorizontal,
                                  verseBorderRadius: verseBorderRadius,
                                  citationIconSize: citationIconSize,
                                  screenWidth: screenWidth,
                                  verseIndex: 0,
                                ),
                              ),
                              SizedBox(height: verseSpacing),
                              FadeTransition(
                                opacity: _verse2FadeAnimation,
                                child: _buildVerseContainer(
                                    verseText: (_verseSets != null &&
                                            _verseSets!.isNotEmpty && // Use isNotEmpty
                                            _currentVerseSetIndex <
                                                _verseSets!.length &&
                                            _verseSets![_currentVerseSetIndex]
                                                    .length >
                                                1)
                                        ? _verseSets![_currentVerseSetIndex][1]
                                            ['text']!
                                        : "Verse not found",
                                    citation: (_verseSets != null &&
                                            _verseSets!.isNotEmpty && // Use isNotEmpty
                                            _currentVerseSetIndex <
                                                _verseSets!.length &&
                                            _verseSets![_currentVerseSetIndex]
                                                    .length >
                                                1)
                                        ? _verseSets![_currentVerseSetIndex][1]
                                            ['citation']!
                                        : "Unknown",
                                    verseFontSize: verseFontSize,
                                    versePaddingVertical: versePaddingVertical,
                                    versePaddingHorizontal:
                                        versePaddingHorizontal,
                                    verseBorderRadius: verseBorderRadius,
                                    citationIconSize: citationIconSize,
                                    screenWidth: screenWidth,
                                    verseIndex: 1),
                              ),
                              SizedBox(height: verseSpacing),
                              FadeTransition(
                                opacity: _verse3FadeAnimation,
                                child: _buildVerseContainer(
                                    verseText: (_verseSets != null &&
                                            _verseSets!.isNotEmpty && // Use isNotEmpty
                                            _currentVerseSetIndex <
                                                _verseSets!.length &&
                                            _verseSets![_currentVerseSetIndex]
                                                    .length >
                                                2)
                                        ? _verseSets![_currentVerseSetIndex][2]
                                            ['text']!
                                        : "Verse not found",
                                    citation: (_verseSets != null &&
                                            _verseSets!.isNotEmpty && // Use isNotEmpty
                                            _currentVerseSetIndex <
                                                _verseSets!.length &&
                                            _verseSets![_currentVerseSetIndex]
                                                    .length >
                                                2)
                                        ? _verseSets![_currentVerseSetIndex][2]
                                            ['citation']!
                                        : "Unknown",
                                    verseFontSize: verseFontSize,
                                    versePaddingVertical: versePaddingVertical,
                                    versePaddingHorizontal:
                                        versePaddingHorizontal,
                                    verseBorderRadius: verseBorderRadius,
                                    citationIconSize: citationIconSize,
                                    screenWidth: screenWidth,
                                    verseIndex: 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.04),
                        child: AnimatedBuilder(
                          animation: _buttonGlowAnimationController,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentGold.withAlpha((60 +
                                            60 *
                                                _buttonGlowAnimationController
                                                    .value)
                                        .toInt()),
                                    blurRadius: 10 *
                                        _buttonGlowAnimationController.value,
                                    spreadRadius: 2 *
                                        _buttonGlowAnimationController.value,
                                  )
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _verse3AnimationController.isCompleted
                                    ? () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const WordOfGodScreen()));
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor:
                                      _verse3AnimationController.isCompleted
                                          ? AppTheme.godTheFather
                                          : Colors.grey.shade700,
                                  backgroundColor:
                                      _verse3AnimationController.isCompleted
                                          ? AppTheme.maryWhite
                                          : Colors.grey.shade400,
                                  elevation:
                                      _verse3AnimationController.isCompleted
                                          ? 8
                                          : 2,
                                  shadowColor:
                                      _verse3AnimationController.isCompleted
                                          ? AppTheme.accentGold.withOpacity(0.8)
                                          : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          buttonBorderRadius)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: buttonPaddingHorizontal,
                                      vertical: buttonPaddingVertical),
                                ),
                                child: Text("Receive the WORD of GOD",
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
              );
            } else if (snapshot.hasError) {
              return Center(
                  child: Text("Error loading data: ${snapshot.error}"));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _buildVerseContainer({
    required String verseText,
    required String citation,
    required double verseFontSize,
    required double versePaddingVertical,
    required double versePaddingHorizontal,
    required double verseBorderRadius,
    required double citationIconSize,
    required double screenWidth,
    required int verseIndex,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: versePaddingVertical, horizontal: versePaddingHorizontal),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(screenWidth < 350 ? 0.04 : 0.02),
        borderRadius: BorderRadius.circular(verseBorderRadius),
        border: Border(
          left: BorderSide(
            color: AppTheme.accentGold.withOpacity(0.7),
            width: screenWidth * 0.005,
          ),
        ),
        boxShadow: [
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
              verseText, // Use the parameter directly
              textAlign: TextAlign.center,
              style: GoogleFonts.robotoSlab(
                textStyle: TextStyle(
                  fontSize: verseFontSize,
                  color: Colors.white,
                  fontStyle: FontStyle.normal,
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
            message: citation, // Use the parameter directly
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