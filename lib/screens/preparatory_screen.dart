// preparatory_screen.dart !
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use
// God is Love

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'word_of_god_screen.dart';
import '../utils/theme.dart';

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

    _startVerseAnimations();
  }

  Future<void> _startVerseAnimations() async {
    await Future.delayed(const Duration(milliseconds: 333));
    _verse1AnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 1333));
    _verse2AnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 1777));
    _verse3AnimationController.forward();
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _allVersesVisible = true;
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
    final double titleFontSize = screenWidth * 0.09; // Keep title font size
    final double titleShadowBlurRadius = screenWidth * 0.01;
    final double titleShadowOffset = screenWidth * 0.005;
    // Reduce top and bottom spacing around the title
    final double titleTopSpacingVertical = screenHeight * 0.04; // Reduced top spacing
    final double titleBottomSpacingVertical = screenHeight * 0.025; // Reduced bottom spacing


    // Verses
    final double verseFontSize = screenWidth * 0.06; // Increased verse font size
    final double verseSpacingVertical =
        screenHeight * 0.03; // Slightly reduced verse spacing
    final double versePaddingVertical =
        screenHeight * 0.017; // Slightly increased padding
    final double versePaddingHorizontal = screenWidth * 0.03;
    final double verseBorderRadius = screenWidth * 0.025;

    // Citation Icon
    final double citationIconSize = screenWidth * 0.03; // Slightly larger icon

    // Button
    final double buttonSpacingVertical =
        screenHeight * 0.05; // Slightly reduced button spacing
   final double buttonFontSize = screenWidth * 0.045;
    final double buttonPaddingHorizontal = screenWidth * 0.1; // Wider button
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06,
              vertical: screenHeight * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: titleTopSpacingVertical), // Reduced top space
              Text(
                "Verses to Meditate", // Changed Title
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
              SizedBox(height: titleBottomSpacingVertical), // Reduced bottom space

              // Verse 1
              FadeTransition(
                opacity: _verse1FadeAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: versePaddingVertical,
                      horizontal: versePaddingHorizontal),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(verseBorderRadius),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          "Cast all your anxieties on Him, for He cares for you.  ",
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
                                    offset: Offset(screenWidth * 0.0025,
                                        screenWidth * 0.0025)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Tooltip(
                        message: "1 Peter 5:7",
                        waitDuration: Duration.zero,
                        showDuration: const Duration(seconds: 3),
                        child: Icon(Icons.info_outline,
                            color: Colors.white, size: citationIconSize),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: verseSpacingVertical),

              // Verse 2
              FadeTransition(
                opacity: _verse2FadeAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: versePaddingVertical,
                      horizontal: versePaddingHorizontal),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(verseBorderRadius),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          "Trust in the Lord with all your heart and lean not on your own understanding.  ",
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
                                    offset: Offset(screenWidth * 0.0025,
                                        screenWidth * 0.0025)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Tooltip(
                        message: "Proverbs 3:5-6",
                        waitDuration: Duration.zero,
                        showDuration: const Duration(seconds: 2),
                        child: Icon(Icons.info_outline,
                            color: Colors.white, size: citationIconSize),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: verseSpacingVertical),

              // Verse 3
              FadeTransition(
                opacity: _verse3FadeAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: versePaddingVertical,
                      horizontal: versePaddingHorizontal),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(verseBorderRadius),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          "I love You, O Lord, and for Your sake, I love my neighbor as myself.  ",
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
                                    offset: Offset(screenWidth * 0.0025,
                                        screenWidth * 0.0025)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Tooltip(
                        message: "Matthew 22:37-40",
                        waitDuration: Duration.zero,
                        showDuration: const Duration(seconds: 2),
                        child: Icon(Icons.info_outline,
                            color: Colors.white, size: citationIconSize),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: buttonSpacingVertical),

              // Button
              AnimatedBuilder(
                animation: _buttonGlowAnimationController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      boxShadow: _allVersesVisible
                          ? [
                              BoxShadow(
                                color: AppTheme.accentGold.withAlpha((80 +
                                        80 *
                                            _buttonGlowAnimationController
                                                .value)
                                    .toInt()),
                                blurRadius: 15 *
                                    _buttonGlowAnimationController.value,
                                spreadRadius: 4 *
                                    _buttonGlowAnimationController.value,
                              )
                            ]
                          : null,
                    ),
                    child: ElevatedButton(
                      onPressed: _allVersesVisible
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
                            borderRadius: BorderRadius.circular(buttonBorderRadius)),
                        padding: EdgeInsets.symmetric(
                            horizontal: buttonPaddingHorizontal,
                            vertical: buttonPaddingVertical),
                      ),
                      child: Text("Receive the Word of God",
                          style: TextStyle(
                              fontSize: buttonFontSize, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}