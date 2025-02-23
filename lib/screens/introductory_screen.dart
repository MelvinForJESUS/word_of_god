// introductory_screen.dart

// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'preparatory_screen.dart';
import '../utils/theme.dart';
import 'dart:math';

class IntroductoryScreen extends StatefulWidget {
  const IntroductoryScreen({super.key});
  @override
  _IntroductoryScreenState createState() => _IntroductoryScreenState();
}

class _IntroductoryScreenState extends State<IntroductoryScreen>
    with TickerProviderStateMixin {
  List<List<Offset>> _strokes = [];
  List<Offset>? _currentStroke;
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

  // Fade-in animation variables
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

  bool _isCrossDrawn(List<List<Offset>> strokes, Size canvasSize) {
    if (strokes.isEmpty) return false;

    if (strokes.length == 1) {
      return _isCrossDrawnMethodB(strokes[0], canvasSize);
    } else if (strokes.length == 2) {
      return _isCrossDrawnMethodA(strokes, canvasSize);
    }
    return false;
  }

  bool _isCrossDrawnMethodA(List<List<Offset>> strokes, Size canvasSize) {
    if (strokes.length < 2) return false;

    List<Offset> stroke1 = strokes[0];
    List<Offset> stroke2 = strokes[1];

    if (stroke1.isEmpty || stroke2.isEmpty) return false;

    Offset vStart, vEnd, hStart, hEnd;

    double angle1 = _calculateStrokeAngle(stroke1);
    double angle2 = _calculateStrokeAngle(stroke2);

    if (_isMostlyVertical(angle1) && _isMostlyHorizontal(angle2)) {
      vStart = stroke1.first;
      vEnd = stroke1.last;
      hStart = stroke2.first;
      hEnd = stroke2.last;
    } else if (_isMostlyVertical(angle2) && _isMostlyHorizontal(angle1)) {
      vStart = stroke2.first;
      vEnd = stroke2.last;
      hStart = stroke1.first;
      hEnd = stroke1.last;
    } else {
      return false;
    }

    if (!_isStrokeLongEnough(vStart, vEnd, canvasSize, true) ||
        !_isStrokeLongEnough(hStart, hEnd, canvasSize, false)) {
      return false;
    }

    // Corrected Intersection Check
    return _doStrokesIntersect(vStart, vEnd, hStart, hEnd);
  }

bool _isCrossDrawnMethodB(List<Offset> stroke, Size canvasSize) {
    if (stroke.length < 3) return false;

    int turningPointIndex = _findTurningPoint(stroke);
    if (turningPointIndex == -1) return false;

    List<Offset> segment1 = stroke.sublist(0, turningPointIndex + 1);
    List<Offset> segment2 = stroke.sublist(turningPointIndex);

    if (segment1.length < 2 || segment2.length < 2) return false;

    double angle1 = _calculateStrokeAngle(segment1);
    double angle2 = _calculateStrokeAngle(segment2);


    if (!(_isMostlyVertical(angle1) && _isMostlyHorizontal(angle2)) &&
        !(_isMostlyHorizontal(angle1) && _isMostlyVertical(angle2))) {
      return false;
    }

    if (segment1.first == segment1.last || segment2.first == segment2.last) return false;


    if (!_isStrokeLongEnough(segment1.first, segment1.last, canvasSize, _isMostlyVertical(angle1)) ||
        !_isStrokeLongEnough(segment2.first, segment2.last, canvasSize, _isMostlyHorizontal(angle2))) { // Corrected: Check against horizontal for segment2
      return false;
    }

    // Corrected Intersection Check
    return _doStrokesIntersect(segment1.first, segment1.last, segment2.first, segment2.last);
}

  int _findTurningPoint(List<Offset> stroke) {
    if (stroke.length < 3) return -1;

    double maxAngleChange = 0.0;
    int turningPointIndex = -1;

    for (int i = 1; i < stroke.length - 1; i++) {
      double angle1 = (stroke[i] - stroke[i - 1]).direction;
      double angle2 = (stroke[i + 1] - stroke[i]).direction;
      double angleChange = (angle2 - angle1).abs();

      if (angleChange > pi) {
        angleChange = 2 * pi - angleChange;
      }

      if (angleChange > maxAngleChange) {
        maxAngleChange = angleChange;
        turningPointIndex = i;
      }
    }

    return (maxAngleChange > 0.52) ? turningPointIndex : -1;  // ~30 degrees
  }

  double _calculateStrokeAngle(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    final deltaX = end.dx - start.dx;
    final deltaY = end.dy - start.dy;
    return atan2(deltaY, deltaX) * 180 / pi;
  }

  bool _isMostlyVertical(double angle) {
    return (angle > 45 && angle < 135) || (angle > -135 && angle < -45);
  }

  bool _isMostlyHorizontal(double angle) {
    return (angle > -45 && angle < 45) || (angle > 135 || angle < -135);
  }

  bool _isStrokeLongEnough(Offset start, Offset end, Size canvasSize, bool isVertical) {
    final deltaX = end.dx - start.dx;
    final deltaY = end.dy - start.dy;
    final length = sqrt(deltaX * deltaX + deltaY * deltaY);
    return isVertical ? length >= canvasSize.height * 0.2 : length >= canvasSize.width * 0.2;
  }

// Corrected Intersection Check Function
bool _doStrokesIntersect(Offset aStart, Offset aEnd, Offset bStart, Offset bEnd) {
  double aDx = aEnd.dx - aStart.dx;
  double aDy = aEnd.dy - aStart.dy;
  double bDx = bEnd.dx - bStart.dx;
  double bDy = bEnd.dy - bStart.dy;

  // Handle parallel lines
  double det = aDx * bDy - bDx * aDy;
  if (det.abs() < 1e-9) {  // Tolerance for floating-point comparison
    return false; // Lines are parallel (or nearly parallel)
  }

  double t = ((bStart.dx - aStart.dx) * aDy - (bStart.dy - aStart.dy) * aDx) / det;
  double u = -((aStart.dx - bStart.dx) * bDy - (aStart.dy - bStart.dy) * bDx) / det;

  // Check if the intersection point is within both line segments
  return (t >= 0 && t <= 1 && u >= 0 && u <= 1);
}

  void _onPanEnd(DragEndDetails details, Size canvasSize) {
    // Removed unnecessary null check
    if (_isCrossDrawn(_strokes, canvasSize)) {
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
    } else {
      setState(() {
        _strokes.clear();
        _currentStroke = null;
      });
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
                          _buildGlowingText("In the Name", _line1FadeAnimation, screenWidth),
                          _buildGlowingText("of the Father,", _line2FadeAnimation, screenWidth),
                          _buildGlowingText("the Son", _line3FadeAnimation, screenWidth),
                          _buildGlowingText("and the Holy Spirit.", _line4FadeAnimation, screenWidth),
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
                            _strokes.add(_currentStroke!);
                              _onPanEnd(details, canvasSize);
                            }
                          },
                          child: CustomPaint(
                            size: canvasSize,
                            painter: CrossPainter(
                              strokes: _strokes,
                              glow: _crossDrawn,
                              animation: _animationController,
                              targetSize: targetCrossSize,
                              currentStroke: _currentStroke,
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

// Helper function to build glowing text
  Widget _buildGlowingText(String text, Animation<double> animation, double screenWidth) {
    return FadeTransition(
      opacity: animation,
      child: Text(
        text,
        style: GoogleFonts.roboto(
          textStyle: TextStyle(
            fontSize: screenWidth * 0.07,
            fontWeight: FontWeight.bold,
            color: AppTheme.jesusChristGold.withAlpha(180),
            height: 1.4,
            shadows: [
              Shadow(
                color: AppTheme.jesusChristGold.withAlpha(100),
                blurRadius: screenWidth * 0.02, // Adjust for desired glow
                offset: Offset.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _currentStrokeStart(Offset position) {
    _currentStroke = <Offset>[position];
    // Don't add to _strokes here, add it on pan end
    setState(() {});
  }

  void _addToCurrentStroke(Offset position) {
    if (_currentStroke != null) {
      _currentStroke!.add(position);
      setState(() {});
    }
  }
}

class CrossPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final bool glow;
  final Animation<double> animation;
  final Size targetSize;
  final List<Offset>? currentStroke;

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

    if (currentStroke != null && currentStroke!.isNotEmpty) {
      final previewPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
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