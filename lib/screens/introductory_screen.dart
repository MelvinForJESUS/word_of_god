// introductory_screen.dart.txt

// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'preparatory_screen.dart';
import '../utils/theme.dart';

// BreathingAnimation widget (No changes)
class BreathingAnimation extends StatefulWidget {
  final Widget child;
  const BreathingAnimation({super.key, required this.child});
  @override
  _BreathingAnimationState createState() => _BreathingAnimationState();
}

class _BreathingAnimationState extends State<BreathingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.03).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

class IntroductoryScreen extends StatefulWidget {
  const IntroductoryScreen({super.key});
  @override
  _IntroductoryScreenState createState() => _IntroductoryScreenState();
}

class _IntroductoryScreenState extends State<IntroductoryScreen>
    with TickerProviderStateMixin {
  final List<List<Offset>> _strokes = [];
  List<Offset>? _currentStroke;
  bool _crossDrawn = false;
  late AnimationController _animationController;
  late AnimationController _bannerAnimationController;
  late Animation<double> _bannerFadeAnimation;
  bool _showBanner = true;
  bool _showAmenButton = false;

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

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _bannerAnimationController.forward().whenComplete(() {
          setState(() {
            _showBanner = false;
          });
        });
      }
    });

    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) {
        setState(() {
          _showAmenButton = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bannerAnimationController.dispose();
    super.dispose();
  }

  bool _isCrossDrawn(List<List<Offset>> strokes, Size canvasSize) {
    if (strokes.length < 2) return false;
    final verticalStroke = strokes[0];
    final horizontalStroke = strokes[1];
    if (verticalStroke.isEmpty || horizontalStroke.isEmpty) return false;

    final vStart = verticalStroke.first;
    final vEnd = verticalStroke.last;
    final vDeltaX = (vEnd.dx - vStart.dx).abs();
    final vDeltaY = (vEnd.dy - vStart.dy).abs();

    if (vDeltaY < vDeltaX) return false;
    if (vDeltaY < canvasSize.height * 0.3) return false; // Keep this check
    final centerX = canvasSize.width / 2;
    if ((vStart.dx - centerX).abs() > canvasSize.width * 0.2) return false;

    final hStart = horizontalStroke.first;
    final hEnd = horizontalStroke.last;
    final hDeltaX = (hEnd.dx - hStart.dx).abs();
    final hDeltaY = (hEnd.dy - hStart.dy).abs();

    if (hDeltaX < hDeltaY) return false;
    if (hDeltaX < canvasSize.width * 0.3) return false; // Keep this check
    final centerY = canvasSize.height / 2;
    if ((hStart.dy - centerY).abs() > canvasSize.height * 0.2) return false;

    return true;
  }

  void _onPanEnd(DragEndDetails details, Size canvasSize) {
    if (_strokes.length >= 2) {
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

    // Drawing Area Section - KEY CHANGES
    // 1.  Make the drawing area *taller* on larger screens,
    //     but keep it smaller on smaller screens.
    // 2.  Use a *smaller* width factor to reduce overall size.
    final double drawingAreaHeightFactor = screenHeight < 600
        ? 0.28
        : (screenHeight < 800 ? 0.33 : 0.38); // More granular control
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
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              decoration: BoxDecoration(
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
                mainAxisAlignment:
                    MainAxisAlignment.start, // Align content to the top
                children: [
                  SizedBox(height: screenHeight * 0.04), // Top spacing
                  // Header Text - "Let Us Pray"
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOut,
                        width: headerBoxWidth,
                        height: headerBoxHeight,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentGold.withAlpha(
                                  (_animationController.value * 150).toInt()),
                              blurRadius:
                                  headerShadowBlurRadius * _animationController.value,
                              spreadRadius: headerShadowSpreadRadius *
                                  _animationController.value,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "Let Us Pray",
                        style: GoogleFonts.lora(
                          textStyle: TextStyle(
                            fontSize: headerFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: screenWidth * 0.013,
                                color: Colors.black26,
                                offset: const Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03), // Responsive SizedBox
                  // Subheading - Blessing text
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: blessingPaddingHorizontal),
                    child: BreathingAnimation(
                      child: Text(
                        "In the Name\nof the Father,\nthe Son\nand the Holy Spirit.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: blessingFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                            height: blessingLineHeight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04), // Spacing

                  // Drawing area - Gesture detector and CustomPaint
                  Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final canvasSize = drawingAreaSize;
                        return GestureDetector(
                          onPanStart: (details) {
                            _currentStrokeStart(details.localPosition);
                          },
                          onPanUpdate: (details) {
                            _addToCurrentStroke(details.localPosition);
                          },
                          onPanEnd: (details) => _onPanEnd(details, canvasSize),
                          child: CustomPaint(
                            size: canvasSize,
                            painter: CrossPainter(
                              strokes: _strokes,
                              glow: _crossDrawn,
                              animation: _animationController,
                              targetSize: targetCrossSize,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02), // Reduced SizedBox

                  // Helper text - Instructions to draw cross
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: blessingPaddingHorizontal),
                    child: Text(
                      "Draw the sign of the cross using the guide lines above.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: helperTextFontSize, color: Colors.white70),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02), // Spacing before button
                ],
              ),
            ),

            // Amen Button - Shown after delay
            if (_showAmenButton)
              Positioned(
                left: 0,
                right: 0,
                bottom: screenHeight * 0.03, // Proportional bottom padding
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  alignment: Alignment.bottomCenter,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentGold.withAlpha(
                                  (80 + 80 * _animationController.value).toInt()),
                              blurRadius: screenWidth * 0.04 *
                                  _animationController.value,
                              spreadRadius: screenWidth * 0.01 *
                                  _animationController.value,
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const PreparatoryScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              foregroundColor: AppTheme.godTheFather,
                              backgroundColor: AppTheme.maryWhite,
                              elevation: 8,
                              shadowColor:
                                  AppTheme.accentGold.withAlpha((0.8 * 255).toInt()),
                              padding: EdgeInsets.symmetric(
                                  horizontal: buttonPaddingHorizontal,
                                  vertical: buttonPaddingVertical)),
                          child: Text("Amen",
                              style: TextStyle(
                                  fontSize: buttonFontSize,
                                  fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Full Screen Banner (No changes)
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

  void _currentStrokeStart(Offset position) {
    _currentStroke = <Offset>[];
    _currentStroke!.add(position);
    _strokes.add(_currentStroke!);
    setState(() {});
  }

  void _addToCurrentStroke(Offset position) {
    _currentStroke?.add(position);
    setState(() {});
  }
}

// CrossPainter class (No changes needed)
class CrossPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final bool glow;
  final Animation<double> animation;
  final Size targetSize;

  CrossPainter({
    required this.strokes,
    required this.glow,
    required this.animation,
    required this.targetSize,
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
  }

  @override
  bool shouldRepaint(covariant CrossPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.glow != glow ||
        oldDelegate.animation.value != animation.value ||
        oldDelegate.targetSize != targetSize;
  }
}