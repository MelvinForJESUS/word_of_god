// introductory_screen.dart

// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'preparatory_screen.dart';
import '../utils/theme.dart';
import 'dart:math'; // Import for math functions (used in cross detection)

// BreathingAnimation widget (Removed) - No longer used.

class IntroductoryScreen extends StatefulWidget {
  const IntroductoryScreen({super.key});
  @override
  _IntroductoryScreenState createState() => _IntroductoryScreenState();
}

class _IntroductoryScreenState extends State<IntroductoryScreen>
    with TickerProviderStateMixin {
  final List<List<Offset>> _strokes = []; // Stores the user's drawing strokes
  List<Offset>? _currentStroke; // Represents the current stroke being drawn
  bool _crossDrawn = false; // Flag to indicate if a cross has been successfully drawn
  late AnimationController _animationController; // Controller for the glowing animation
  late AnimationController _bannerAnimationController; // Controller for the banner fade-out
  late Animation<double> _bannerFadeAnimation; // Animation for the banner fade-out
  late AnimationController _amenButtonAnimationController; // Controller for Amen button fade-in
  late Animation<double> _amenButtonFadeAnimation;   // Animation for Amen button fade-in
  late AnimationController _helperTextAnimationController; // Controller for helper text fade-out
  late Animation<double> _helperTextFadeAnimation; // Animation for helper text fade-out
  bool _showBanner = true; // Flag to control the visibility of the banner
  bool _showAmenButton = false; // Flag to control the visibility of the Amen button
  bool _allowDrawing = false; // Flag to control when drawing is permitted

  // Typing animation variables
  late AnimationController _typingAnimationController;
  final String _blessingText = "In the Name\nof the Father,\nthe Son\nand the Holy Spirit.";
  List<String> _blessingWords = [];
  // int _currentWordIndex = 0; // Not directly used in the final version, but good for understanding
  bool _typingAnimationComplete = false;

  @override
  void initState() {
    super.initState();

    // Animation controller for the glowing effect around the cross and button.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Duration of one glow cycle
    )..repeat(reverse: true); // Repeat the glow in reverse (pulse effect)

    // Animation controller for the banner's fade-out effect.
    _bannerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Duration of the fade-out
    );
    _bannerFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _bannerAnimationController, curve: Curves.easeOut));

    // Initialize Amen button animation controller and animation
    _amenButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Duration of the fade-in
    );
    _amenButtonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _amenButtonAnimationController,
        curve: Curves.easeIn, // Use a smooth easing curve
      ),
    );

    // Initialize helper text animation controller and animation
    _helperTextAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Match Amen button fade-in
    );
    _helperTextFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _helperTextAnimationController,
        curve: Curves.easeOut, // Fade out smoothly
      ),
    );

    // --- Typing Animation Setup ---
    _blessingWords = _blessingText.split(" "); // Split the text into words
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // Total duration for typing effect (adjust as needed)
    );

    _typingAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _typingAnimationComplete = true; // Set flag when animation completes
        });
      }
    });

    // Delay the banner fade-out animation.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _bannerAnimationController.forward().whenComplete(() {
          setState(() {
            _showBanner = false; // Hide the banner
            _allowDrawing = true; // Enable drawing
          });
          // Start the typing animation *here*, after the banner is gone.
          if (mounted) {
            _typingAnimationController.forward();
          }
        });
      }
    });

    // Delay the "Amen" button and helper text fade-out.
    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) {
        setState(() {
          _showAmenButton = true;
          _amenButtonAnimationController.forward(); // Fade in Amen button
          _helperTextAnimationController.forward(); // Fade out helper text
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bannerAnimationController.dispose();
    _amenButtonAnimationController.dispose();
    _helperTextAnimationController.dispose();
    _typingAnimationController.dispose(); // Dispose of the typing animation controller
    super.dispose();
  }

    // Helper function to build the animated typing text
  Widget _buildTypingText(double screenWidth) {
    return AnimatedBuilder(
      animation: _typingAnimationController,
      builder: (context, child) {
        int numWordsToShow =
            (_typingAnimationController.value * _blessingWords.length).floor();
        String textToShow = _blessingWords.sublist(0, numWordsToShow).join(" ");

        return Text(
          textToShow,
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              fontSize: screenWidth * 0.07, // Responsive font size
              fontWeight: FontWeight.bold,
              color: AppTheme.jesusChristGold.withAlpha(180), // Use gold with reduced opacity
              height: 1.4,
            ),
          ),
        );
      },
    );
  }

  // _isCrossDrawn: Determines if the user has drawn a recognizable cross.
  bool _isCrossDrawn(List<List<Offset>> strokes, Size canvasSize) {
    if (strokes.length < 2) return false; // Need at least two strokes

    // 1. Find the longest stroke (likely the vertical one).
    List<Offset> longestStroke = [];
    List<Offset> otherStroke = [];

    // Determine which stroke is longer.
    if (strokes[0].length > strokes[1].length) {
      longestStroke = strokes[0];
      otherStroke = strokes[1];
    } else {
      longestStroke = strokes[1];
      otherStroke = strokes[0];
    }

    if (longestStroke.isEmpty || otherStroke.isEmpty) return false;

    // 2. Calculate the angle of the longest stroke.
    final vStart = longestStroke.first;
    final vEnd = longestStroke.last;
    final vDeltaX = vEnd.dx - vStart.dx;
    final vDeltaY = vEnd.dy - vStart.dy;
    final vAngle = atan2(vDeltaY, vDeltaX) * 180 / pi; // Angle in degrees

    // 3. Check if the longest stroke is *mostly* vertical (within +/- 30 degrees of vertical).
    final isVertical = (vAngle > 60 && vAngle < 120) || (vAngle > -120 && vAngle < -60);

    if (!isVertical) return false;

    // 4. Check if the longest stroke is long enough.
    final vLength = sqrt(vDeltaX * vDeltaX + vDeltaY * vDeltaY);
    if (vLength < canvasSize.height * 0.3) return false; // 30% of canvas height

    // 5. Calculate the angle of the other stroke.
    final hStart = otherStroke.first;
    final hEnd = otherStroke.last;
    final hDeltaX = hEnd.dx - hStart.dx;
    final hDeltaY = hEnd.dy - hStart.dy;
    final hAngle = atan2(hDeltaY, hDeltaX) * 180 / pi; // Angle in degrees

    // 6. Check if the other stroke is *mostly* horizontal (within +/- 30 degrees of horizontal).
    final isHorizontal = (hAngle > -30 && hAngle < 30) || (hAngle > 150 || hAngle < -150);

    if (!isHorizontal) return false;

    // 7. Check if the other stroke is long enough.
    final hLength = sqrt(hDeltaX * hDeltaX + hDeltaY * hDeltaY);
    if (hLength < canvasSize.width * 0.3) return false; // 30% of canvas width

    // 8. Basic intersection check (optional, but can improve accuracy).
    //    Simplified intersection:  Checks if the bounding boxes of the strokes overlap.
    final vMinX = min(vStart.dx, vEnd.dx);
    final vMaxX = max(vStart.dx, vEnd.dx);
    final vMinY = min(vStart.dy, vEnd.dy);
    final vMaxY = max(vStart.dy, vEnd.dy);
    final hMinX = min(hStart.dx, hEnd.dx);
    final hMaxX = max(hStart.dx, hEnd.dx);
    final hMinY = min(hStart.dy, hEnd.dy);
    final hMaxY = max(hStart.dy, hEnd.dy);

    if (hMinX > vMaxX || hMaxX < vMinX || vMinY > hMaxY || vMaxY < hMinY) {
      return false; // No intersection.
    }

    return true; // All checks passed; it's likely a cross.
  }

  // _onPanEnd: Called when the user finishes a drawing gesture.
  void _onPanEnd(DragEndDetails details, Size canvasSize) {
    if (_strokes.length >= 2) {
      if (_isCrossDrawn(_strokes, canvasSize)) {
        // Cross detected!
        setState(() {
          _crossDrawn = true;
        });
        _animationController.forward(); // Start the glow animation
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          Navigator.pushReplacement( // Navigate to the PreparatoryScreen
            context,
            MaterialPageRoute(builder: (context) => const PreparatoryScreen()),
          );
        });
      } else {
        // Not a cross. Clear the strokes and reset.
        _strokes.clear();
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // --- Responsive Values ---
    // These values are calculated based on the screen size to ensure
    // the UI looks good on different devices.

    // Header Section
    final double headerFontSize = screenWidth * 0.11;
    final double headerBoxWidth = screenWidth * 0.7;
    final double headerBoxHeight = screenHeight * 0.07;
    final double headerShadowBlurRadius = screenWidth * 0.11;
    final double headerShadowSpreadRadius = screenWidth * 0.008;

    // Blessing Text Section
    final double blessingFontSize = screenWidth * 0.07;
    final double blessingLineHeight = 1.4;
    final double blessingPaddingHorizontal = screenWidth * 0.07;

    // Drawing Area Section
    // The drawing area is made taller on larger screens, but kept smaller
    // on smaller screens.  A smaller width factor is used to reduce
    // the overall size of the drawing area.
    final double drawingAreaHeightFactor = screenHeight < 600
        ? 0.28
        : (screenHeight < 800 ? 0.33 : 0.38); // Granular control
    final double drawingAreaWidthFactor =
        0.6; // Reduced width factor for a smaller drawing area
    final drawingAreaSize = Size(screenWidth * drawingAreaWidthFactor,
        screenHeight * drawingAreaHeightFactor);
    final targetCrossSize =
        Size(drawingAreaSize.width * 0.7, drawingAreaSize.height * 0.7);

    // Helper Text Section
    final double helperTextFontSize = screenWidth * 0.045;

    // Amen Button Section
    final double buttonFontSize = screenWidth * 0.045;
    final double buttonPaddingHorizontal = screenWidth * 0.15;
    final double buttonPaddingVertical = screenHeight * 0.02;

    // Banner Section
    final double bannerPadding = screenWidth * 0.13;
    final double bannerFontSize = screenWidth * 0.18;

    return Scaffold(
      body: SafeArea( // Ensures content is not obscured by system UI
        child: Stack( // Stack allows widgets to be layered on top of each other
          children: [
            Container( // Background container with gradient
              width: screenWidth,
              height: screenHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient( // Creates a gradient background
                  colors: [
                    AppTheme.godTheFather, // Defined in theme.dart
                    AppTheme.churchPurple,
                    AppTheme.maryBlue,
                  ],
                  begin: Alignment.topLeft, // Gradient starts at top-left
                  end: Alignment.bottomRight, // Gradient ends at bottom-right
                ),
              ),
              child: Column( // Main content column
                mainAxisAlignment: MainAxisAlignment.start, // Align content to the top
                children: [
                  SizedBox(height: screenHeight * 0.04), // Top spacing

                  // Header Text - "Let Us Pray" (Refined)
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: screenWidth*0.05),
                    child: Text(
                      "Let Us Pray",
                      style: GoogleFonts.lora(
                        textStyle: TextStyle(
                          fontSize: headerFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            // Subtle white glow
                            Shadow(
                              blurRadius: screenWidth * 0.05, // Adjust for desired glow
                              color: Colors.white.withAlpha(150), // Semi-transparent white
                              offset: Offset.zero, // Centered glow
                            ),
                            // Very faint black shadow for depth
                            Shadow(
                              blurRadius: screenWidth * 0.005, // Very small blur
                              color: Colors.black.withAlpha(50), // Very faint black
                              offset: const Offset(1.0, 1.0), // Slight offset
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03), // Responsive SizedBox

                  // Subheading - Blessing text (Typing Animation)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: blessingPaddingHorizontal),
                    child:_buildTypingText(screenWidth),
                  ),
                  SizedBox(height: screenHeight * 0.04), // Spacing

                  // Drawing area - Gesture detector and CustomPaint.
                  Center(
                    child: LayoutBuilder( // Used to get the size of the parent widget
                      builder: (context, constraints) {
                        final canvasSize = drawingAreaSize; // Calculate canvas size
                        return GestureDetector( // Detects user gestures
                          onPanStart: (details) {
                            if (_allowDrawing) { // Only start if drawing is allowed
                              _currentStrokeStart(details.localPosition);
                            }
                          },
                          onPanUpdate: (details) {
                            if (_allowDrawing) { // Only update if drawing is allowed
                              _addToCurrentStroke(details.localPosition);
                            }
                          },
                          onPanEnd: (details) {
                            if (_allowDrawing) { // Only process end if drawing is allowed
                              _onPanEnd(details, canvasSize);
                            }
                          },
                          child: CustomPaint( // Custom painter for drawing the cross
                            size: canvasSize,
                            painter: CrossPainter( // The custom painter class
                              strokes: _strokes, // Pass the strokes to be drawn
                              glow: _crossDrawn, // Pass the glow state
                              animation: _animationController, // Pass the animation controller
                              targetSize: targetCrossSize, // Pass the target cross size
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02), // Reduced SizedBox

                  // Use Spacer to push content to the top and button to the bottom
                  const Spacer(),

                  // Helper text - Instructions to draw cross (with fade-out).
                  FadeTransition(
                    opacity: _helperTextFadeAnimation, // Controls the fade-out
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: blessingPaddingHorizontal),
                      child: Text(
                        "Draw the sign of the cross using the guide lines above.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: helperTextFontSize, color: Colors.white70),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02), // Spacing before button
                ],
              ),
            ),

            // Amen Button - Shown after delay, with FadeTransition and improved styling.
            if (_showAmenButton)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                left: 0,
                right: 0,
                bottom: _showAmenButton ? screenHeight * 0.03 : -100,
                child: FadeTransition(
                  opacity: _amenButtonFadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const PreparatoryScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppTheme.godTheFather,
                            backgroundColor: AppTheme.maryWhite,
                            padding: EdgeInsets.symmetric(
                                horizontal: buttonPaddingHorizontal,
                                vertical: buttonPaddingVertical),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30), // Rounded corners
                            ),
                          ).copyWith(
                            elevation: MaterialStateProperty.all(8),
                            shadowColor: MaterialStateProperty.all(
                                AppTheme.accentGold.withAlpha((0.8 * 255).toInt())),
                            overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return AppTheme.accentGold.withAlpha(50); // Slightly darker when pressed
                                }
                                return null; // Defer to the widget's default.
                              },
                            ),
                          ),
                          child: Text(
                            "Amen",
                            style: TextStyle(
                                fontSize: buttonFontSize, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

            // Full Screen Banner (Fades out at the start).
            if (_showBanner)
              FadeTransition(
                opacity: _bannerFadeAnimation,
                child: Container(
                  color: AppTheme.godTheFather,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(bannerPadding),
                    child: Text(
                      "WORD\nof\nGOD",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lora(
                        textStyle: TextStyle(
                          fontSize: bannerFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // _currentStrokeStart: Called when a new drawing stroke starts.
  void _currentStrokeStart(Offset position) {
    _currentStroke = <Offset>[]; // Initialize a new list for the current stroke
    _currentStroke!.add(position); // Add the starting point to the stroke
    _strokes.add(_currentStroke!); // Add the current stroke to the list of all strokes
    setState(() {}); // Update the UI
  }

  // _addToCurrentStroke: Called when the user moves their finger while drawing.
  void _addToCurrentStroke(Offset position) {
    _currentStroke?.add(position); // Add the new point to the current stroke
    setState(() {}); // Update the UI
  }
}

// CrossPainter class - Custom painter to draw the cross and guidelines.
class CrossPainter extends CustomPainter {
  final List<List<Offset>> strokes; // The strokes to draw
  final bool glow; // Whether to draw the glow effect
  final Animation<double> animation; // The animation for the glow
  final Size targetSize; // The desired size of the cross

  CrossPainter({
    required this.strokes,
    required this.glow,
    required this.animation,
    required this.targetSize,
  }) : super(repaint: animation); // Listen to the animation for repainting

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2); // Center of the canvas
    final crossWidth = targetSize.width; // Desired width of the cross
    final crossHeight = targetSize.height; // Desired height of the cross
    final halfCrossWidth = crossWidth / 2;
    final halfCrossHeight = crossHeight / 2;

    // Paint for the guide lines.
    final guidePaint = Paint()
      ..color = Colors.white.withAlpha(77) // Semi-transparent white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke; // Only draw the outline

    // Draw the guide lines (a cross shape).
    final guidePath = Path();
    guidePath.moveTo(center.dx, center.dy - halfCrossHeight); // Top
    guidePath.lineTo(center.dx, center.dy + halfCrossHeight); // Bottom
    guidePath.moveTo(center.dx - halfCrossWidth, center.dy); // Left
    guidePath.lineTo(center.dx + halfCrossWidth, center.dy); // Right
    canvas.drawPath(guidePath, guidePaint);

    // Draw the glow effect if _crossDrawn is true.
    if (glow) {
      final glowPaint = Paint()
        ..shader = RadialGradient( // Create a radial gradient
          colors: [
            Colors.white.withAlpha((animation.value * 255).toInt()), // From white (animated opacity)
            Colors.transparent, // To transparent
          ],
          stops: const [0.0, 1.0], // Gradient stops
        ).createShader(Rect.fromCircle(center: center, radius: halfCrossWidth)) // Apply to a circle
        ..style = PaintingStyle.stroke // Only draw the outline
        ..strokeWidth = 9.0;
      // Draw the cross shape for the glow.
      final crossPath = Path();
      crossPath.moveTo(center.dx, center.dy - halfCrossHeight); // Top
      crossPath.lineTo(center.dx, center.dy + halfCrossHeight); // Bottom
      crossPath.moveTo(center.dx - halfCrossWidth, center.dy); // Left
      crossPath.lineTo(center.dx + halfCrossWidth, center.dy); // Right
      canvas.drawPath(crossPath, glowPaint);
    }

    // Paint for the user's drawn strokes.
    final strokePaint = Paint()
      ..color = Colors.white // White color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke // Only draw the outline
      ..strokeCap = StrokeCap.round; // Rounded stroke caps

    // Draw each stroke.
    for (final stroke in strokes) {
      final path = Path();
      if (stroke.isNotEmpty) {
        path.moveTo(stroke.first.dx, stroke.first.dy); // Start at the first point
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy); // Line to each subsequent point
        }
        canvas.drawPath(path, strokePaint); // Draw the path
      }
    }
  }

  @override
  bool shouldRepaint(covariant CrossPainter oldDelegate) {
    // Repaint only if the strokes, glow state, animation value, or target size changes.
    return oldDelegate.strokes != strokes ||
        oldDelegate.glow != glow ||
        oldDelegate.animation.value != animation.value ||
        oldDelegate.targetSize != targetSize;
  }
}