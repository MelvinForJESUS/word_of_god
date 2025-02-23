// introductory_screen.dart
// ignore_for_file: library_private_types_in_public_api
//GODisLOVE

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'preparatory_screen.dart';
import '../utils/theme.dart';
import 'dart:math';
import 'package:flutter_glow/flutter_glow.dart'; // Import the glow package


class IntroductoryScreen extends StatefulWidget {
  const IntroductoryScreen({super.key});
  @override
  _IntroductoryScreenState createState() => _IntroductoryScreenState();
}

class _IntroductoryScreenState extends State<IntroductoryScreen>
    with TickerProviderStateMixin {
  final List<List<Offset>> _strokes = []; // Stores COMPLETED strokes
  List<Offset>? _drawingStroke; // Stores the CURRENT stroke being drawn
  bool _crossDrawn = false;
  late AnimationController _animationController;
  late AnimationController _bannerAnimationController;
  late Animation<double> _bannerFadeAnimation;
  late AnimationController _amenButtonAnimationController;
  late Animation<double> _amenButtonFadeAnimation;
  late AnimationController _helperTextAnimationController;
  late Animation<double> _helperTextFadeAnimation;
  bool _showBanner = true;
  bool _showAmenButton = false;
  bool _allowDrawing = false;

  // Fade-in animation variables (No longer needed, but kept for now)
  late AnimationController _line1Controller;
  late Animation<double> _line1FadeAnimation;
  late AnimationController _line2Controller;
  late Animation<double> _line2FadeAnimation;
  late AnimationController _line3Controller;
  late Animation<double> _line3FadeAnimation;
  late AnimationController _line4Controller;
  late Animation<double> _line4FadeAnimation;

  static const _animationDuration = Duration(milliseconds: 500);
  static const _animationDelay = Duration(milliseconds: 500);

  // Constants for cross detection (tunable)
  static const double _minStrokeLengthRatio = 0.2; // Min length relative to canvas size
  static const double _angleTolerance = 35.0; // Degrees.  Increased for more leniency.
  // static const double _cornerAngleThreshold = 45.0; // Degrees (for single-stroke) - REMOVED
  static const double _intersectionDistanceThreshold = 30.0; //  Increased for more leniency.


  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _bannerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _bannerFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _bannerAnimationController, curve: Curves.easeOut));

    _amenButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _amenButtonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _amenButtonAnimationController,
        curve: Curves.easeIn,
      ),
    );

    _helperTextAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _helperTextFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _helperTextAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _line1Controller = AnimationController(vsync: this, duration: _animationDuration);
    _line1FadeAnimation = _createFadeAnimation(_line1Controller);
    _line2Controller = AnimationController(vsync: this, duration: _animationDuration);
    _line2FadeAnimation = _createFadeAnimation(_line2Controller);
    _line3Controller = AnimationController(vsync: this, duration: _animationDuration);
    _line3FadeAnimation = _createFadeAnimation(_line3Controller);
    _line4Controller = AnimationController(vsync: this, duration: _animationDuration);
    _line4FadeAnimation = _createFadeAnimation(_line4Controller);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _bannerAnimationController.forward().whenComplete(() {
          setState(() {
            _showBanner = false;
            _allowDrawing = true;
          });
          if (mounted) {
            _startBlessingAnimations();
          }
        });
      }
    });

    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) {
        setState(() {
          _showAmenButton = true;
          _amenButtonAnimationController.forward();
          _helperTextAnimationController.forward();
        });
      }
    });
  }

  Animation<double> _createFadeAnimation(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeIn),
    );
  }

  Future<void> _startBlessingAnimations() async {
    if (!mounted) return;
    _line1Controller.forward();
    await Future.delayed(_animationDelay);
    if (!mounted) return;
    _line2Controller.forward();
    await Future.delayed(_animationDelay);
    if (!mounted) return;
    _line3Controller.forward();
    await Future.delayed(_animationDelay);
    if (!mounted) return;
    _line4Controller.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bannerAnimationController.dispose();
    _amenButtonAnimationController.dispose();
    _helperTextAnimationController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _line3Controller.dispose();
    _line4Controller.dispose();
    super.dispose();
  }

// Unified Cross Detection (ONLY TWO-STROKE NOW)
bool _isCrossDrawn(Size canvasSize) {
  if (_drawingStroke == null || _drawingStroke!.isEmpty) return false;

  if (_strokes.length == 1) {
    // Only check for two-stroke cross
    return _isTwoStrokeCross(_strokes[0], _drawingStroke!, canvasSize);
  }

  return false;
}

bool _isTwoStrokeCross(List<Offset> stroke1, List<Offset> stroke2, Size canvasSize) {
  // 1. Length Check - Early Exit
  if (!_isStrokeLongEnough(stroke1, canvasSize) || !_isStrokeLongEnough(stroke2, canvasSize)) {
    return false;
  }

  // 2. Angle Check - Early Exit
  double angle1 = _calculateStrokeAngle(stroke1);
  double angle2 = _calculateStrokeAngle(stroke2);

  bool stroke1IsVertical = _isMostlyVertical(angle1);
  bool stroke2IsHorizontal = _isMostlyHorizontal(angle2);
  bool stroke1IsHorizontal = _isMostlyHorizontal(angle1);
  bool stroke2IsVertical = _isMostlyVertical(angle2);

  if (!((stroke1IsVertical && stroke2IsHorizontal) || (stroke1IsHorizontal && stroke2IsVertical))) {
    print("Angles: Stroke 1: $angle1, Stroke 2: $angle2"); // Debug print
    return false;
  }

  // 3. Intersection Check
  bool intersects = _doStrokesIntersect(stroke1, stroke2);
  print("Intersection Check: $intersects"); // Debug print
  return intersects;
}

// REMOVED _isSingleStrokeCross

// Helper Functions (Cross Detection)

bool _isStrokeLongEnough(List<Offset> stroke, Size canvasSize) {
  if (stroke.isEmpty) return false;
  double length = 0;
  for (int i = 1; i < stroke.length; i++) {
    length += (stroke[i] - stroke[i - 1]).distance;
  }
  double minLength = canvasSize.shortestSide * _minStrokeLengthRatio;
  return length >= minLength;
}

double _calculateStrokeAngle(List<Offset> stroke) {
  if (stroke.length < 2) return 0.0; // Or throw an error, if appropriate
  Offset start = stroke.first;
  Offset end = stroke.last;
  return atan2(end.dy - start.dy, end.dx - start.dx) * 180 / pi;
}

bool _isMostlyVertical(double angle) {
  // Relaxed angle tolerance
  return (angle > 90 - _angleTolerance && angle < 90 + _angleTolerance) ||
         (angle > -90 - _angleTolerance && angle < -90 + _angleTolerance);
}

bool _isMostlyHorizontal(double angle) {
  // Relaxed angle tolerance
  return (angle > -_angleTolerance && angle < _angleTolerance) ||
         (angle > 180 - _angleTolerance && angle < 180 + _angleTolerance) ||
         (angle > -180 - _angleTolerance && angle < -180 + _angleTolerance); // Handle wrap-around
}

// Simplified intersection check using proximity
bool _doStrokesIntersect(List<Offset> stroke1, List<Offset> stroke2) {
  for (Offset point1 in stroke1) {
    for (Offset point2 in stroke2) {
      if ((point1 - point2).distance < _intersectionDistanceThreshold) {
        return true;
      }
    }
  }
  return false;
}

// REMOVED _findCornerIndex


// Gesture Handling

void _currentStrokeStart(Offset position) {
    // Clear previous strokes only if we've already detected a cross.
    // This allows for multiple attempts.
    if (_crossDrawn) {
        _strokes.clear();
        _crossDrawn = false; // Reset the flag
    }
    _drawingStroke = <Offset>[position]; // Initialize the current stroke
    setState(() {});
}

void _addToCurrentStroke(Offset position) {
  if (_drawingStroke != null) {
    _drawingStroke!.add(position);
    setState(() {});
  }
}

void _onPanEnd(DragEndDetails details, Size canvasSize) {
    if (_drawingStroke != null && _drawingStroke!.isNotEmpty) {
        if (_strokes.isEmpty) {
            // First stroke completed.  Store it.
            _strokes.add(_drawingStroke!);
            _drawingStroke = null; // Clear for the next stroke
            setState(() {});
        } else if (_strokes.length == 1) {
          //second stroke
          bool crossDetected = _isCrossDrawn(canvasSize);
          if (crossDetected) {
            _strokes.add(_drawingStroke!);
            setState(() {
              _crossDrawn = true;
            });
            _animationController.forward();
            Future.delayed(const Duration(seconds: 1), () {
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PreparatoryScreen()),
              );
            });
          }
          else{
            setState(() {
              _strokes.clear();
            });
          }
          _drawingStroke = null;
        }
    }
}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final headerFontSize = screenWidth * 0.11;
    final blessingPaddingHorizontal = screenWidth * 0.07;
    final drawingAreaHeightFactor = screenHeight < 600
        ? 0.28
        : (screenHeight < 800 ? 0.33 : 0.38);
    final drawingAreaWidthFactor = 0.6;
    final drawingAreaSize = Size(screenWidth * drawingAreaWidthFactor,
        screenHeight * drawingAreaHeightFactor);
    final targetCrossSize =
        Size(drawingAreaSize.width * 0.7, drawingAreaSize.height * 0.7);
    final helperTextFontSize = screenWidth * 0.045;
    final buttonFontSize = screenWidth * 0.045;
    final buttonPaddingHorizontal = screenWidth * 0.15;
    final buttonPaddingVertical = screenHeight * 0.02;
    final bannerPadding = screenWidth * 0.13;
    final bannerFontSize = screenWidth * 0.18;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.godTheFather,
                    AppTheme.churchPurple,
                    AppTheme.maryBlue,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.04),

                  // Header Text - "Let Us Pray" (with Glow)
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Text(
                      "Let Us Pray",
                      style: GoogleFonts.lora(
                        textStyle: TextStyle(
                          fontSize: headerFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: screenWidth * 0.05,
                              color: Colors.white.withAlpha(150),
                              offset: Offset.zero,
                            ),
                            Shadow(
                              blurRadius: screenWidth * 0.005,
                              color: Colors.black.withAlpha(50),
                              offset: const Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Blessing text (Fade-In and Glow)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: blessingPaddingHorizontal),
                    child: SizedBox(
                      height: screenHeight * 0.25,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // _buildGlowingText("In the Name", _line1FadeAnimation, screenWidth), // OLD
                          // _buildGlowingText("of the Father,", _line2FadeAnimation, screenWidth),
                          // _buildGlowingText("the Son", _line3FadeAnimation, screenWidth),
                          // _buildGlowingText("and the Holy Spirit.", _line4FadeAnimation, screenWidth),
                          // _buildGlowText("In the Name", _line1FadeAnimation, screenWidth), // NEW
                          // _buildGlowText("of the Father,", _line2FadeAnimation, screenWidth),
                          // _buildGlowText("the Son", _line3FadeAnimation, screenWidth),
                          // _buildGlowText("and the Holy Spirit.", _line4FadeAnimation, screenWidth),
                          _buildGlowText("In the Name", _line1FadeAnimation, screenWidth),
                          _buildGlowText("of the Father,", _line2FadeAnimation, screenWidth),
                          _buildGlowText("the Son", _line3FadeAnimation, screenWidth),
                          _buildGlowText("and the Holy Spirit.", _line4FadeAnimation, screenWidth),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),

                  Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final canvasSize = drawingAreaSize;
                        return GestureDetector(
                          onPanStart: (details) {
                            if (_allowDrawing) {
                              _currentStrokeStart(details.localPosition);
                            }
                          },
                          onPanUpdate: (details) {
                            if (_allowDrawing) {
                              _addToCurrentStroke(details.localPosition);
                            }
                          },
                          onPanEnd: (details) {
                            if (_allowDrawing) {
                              _onPanEnd(details, canvasSize);
                            }
                          },
                          child: CustomPaint(
                            size: canvasSize,
                            painter: CrossPainter(
                              strokes: _strokes, // Completed strokes
                              glow: _crossDrawn,
                              animation: _animationController,
                              targetSize: targetCrossSize,
                              currentStroke: _drawingStroke, // Current stroke
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),
                  const Spacer(),

                  FadeTransition(
                    opacity: _helperTextFadeAnimation,
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

                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),

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
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ).copyWith(
                            elevation: WidgetStateProperty.all(8),
                            shadowColor: WidgetStateProperty.all(
                                AppTheme.accentGold.withAlpha((0.8 * 255).toInt())),
                            overlayColor: WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return AppTheme.accentGold.withAlpha(50);
                                }
                                return null;
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

// Helper function to build glowing text using FlutterGlow - MODIFIED
Widget _buildGlowText(String text, Animation<double> animation, double screenWidth) {
  return FadeTransition(
    opacity: animation,
    child: GlowText(
      text,
      style: GoogleFonts.roboto(
        textStyle: TextStyle(
          fontSize: screenWidth * 0.07,
          fontWeight: FontWeight.bold,
          color: AppTheme.shimmeringGold, // Use the new shimmering gold
          height: 1.4,
          shadows: [ // Add a subtle text shadow
            Shadow(
              color: Colors.black.withAlpha((0.2 * 255).toInt()), // Dark shadow
              offset: Offset(1, 1),
              blurRadius: screenWidth * 0.01,
            ),
          ],
        ),
      ),
      glowColor: AppTheme.shimmeringGold.withAlpha((0.9 * 255).toInt()), // Strong glow, slightly more opaque
      blurRadius: screenWidth * 0.08, // Increased blur radius
    ),
  );
}
}

class CrossPainter extends CustomPainter {
  final List<List<Offset>> strokes; // Completed strokes
  final bool glow;
  final Animation<double> animation;
  final Size targetSize;
  final List<Offset>? currentStroke; // Current stroke

  CrossPainter({
    required this.strokes,
    required this.glow,
    required this.animation,
    required this.targetSize,
    this.currentStroke,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final crossWidth = targetSize.width;
    final crossHeight = targetSize.height;
    final halfCrossWidth = crossWidth / 2;
    final halfCrossHeight = crossHeight / 2;

    final guidePaint = Paint()
      ..color = Colors.white.withAlpha(77)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final guidePath = Path();
    guidePath.moveTo(center.dx, center.dy - halfCrossHeight);
    guidePath.lineTo(center.dx, center.dy + halfCrossHeight);
    guidePath.moveTo(center.dx - halfCrossWidth, center.dy);
    guidePath.lineTo(center.dx + halfCrossWidth, center.dy);
    canvas.drawPath(guidePath, guidePaint);

    if (glow) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withAlpha((animation.value * 255).toInt()),
            Colors.transparent,
          ],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: halfCrossWidth))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9.0;

      final crossPath = Path();
      crossPath.moveTo(center.dx, center.dy - halfCrossHeight);
      crossPath.lineTo(center.dx, center.dy + halfCrossHeight);
      crossPath.moveTo(center.dx - halfCrossWidth, center.dy);
      crossPath.lineTo(center.dx + halfCrossWidth, center.dy);
      canvas.drawPath(crossPath, glowPaint);
    }

    final strokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw completed strokes
    for (final stroke in strokes) {
      final path = Path();
      if (stroke.isNotEmpty) {
        path.moveTo(stroke.first.dx, stroke.first.dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, strokePaint);
      }
    }

    // Draw the current stroke (preview)
    if (currentStroke != null && currentStroke!.isNotEmpty) {
      final previewPaint = Paint()
        ..color = Colors.white.withAlpha((0.5 * 255).toInt())
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final previewPath = Path();
      previewPath.moveTo(currentStroke!.first.dx, currentStroke!.first.dy);
      for (int i = 1; i < currentStroke!.length; i++) {
        previewPath.lineTo(currentStroke![i].dx, currentStroke![i].dy);
      }
      canvas.drawPath(previewPath, previewPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CrossPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.glow != glow ||
        oldDelegate.animation.value != animation.value ||
        oldDelegate.targetSize != targetSize ||
        oldDelegate.currentStroke != currentStroke;
  }
}