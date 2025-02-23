//Word_of_GOD_screen.dart
//GODisLOVE

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'preparatory_screen.dart'; // Import PreparatoryScreen
//import 'package:google_fonts/google_fonts.dart'; // Removed unused import. No longer needed.
import '../utils/theme.dart';
import 'package:http/http.dart' as http; // Used for fetching the verse.
import 'package:connectivity_plus/connectivity_plus.dart'; // Import for network connectivity check
import 'dart:async'; // Import for TimeoutException
import 'package:share_plus/share_plus.dart'; // Import for sharing
import 'package:double_back_to_close_app/double_back_to_close_app.dart'; // Import the package

class WordOfGodScreen extends StatefulWidget {
  const WordOfGodScreen({super.key});

  @override
  WordOfGodScreenState createState() => WordOfGodScreenState();
}

class WordOfGodScreenState extends State<WordOfGodScreen>
    with TickerProviderStateMixin {
  late final WebViewController _controller;
  bool _isLoading = true; // Track loading state of the WebView.
  bool _loadError = false; // Track if an error occurred during loading.
  String _errorMessage = ""; // Store error message to display.
  late AnimationController _buttonGlowAnimationController; // For the button glow effect.
  String _currentVerseText = ""; // To hold the verse text
  String _currentVerseReference = ""; // To hold the verse reference

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller for the glowing button.
    _buttonGlowAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);

    // Initialize the WebView controller.
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Enable JavaScript.
      ..setBackgroundColor(Colors.transparent) // Make WebView background transparent.
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            // Called when the page finishes loading.
            setState(() {
              _isLoading = false; // Set loading to false.
            });

            // EXTRACT VERSE TEXT AND REFERENCE - ADDED THIS BLOCK
            try {
              // Extract the verse text using JavaScript injection
              final String verseTextJS =
                  "document.querySelector('#dailyVersesWrapper .bibleText').innerText;";
              final String verseText =
                  await _controller.runJavaScriptReturningResult(verseTextJS) as String;

              // Extract the verse reference using JavaScript injection
              final String verseRefJS =
                  "document.querySelector('#dailyVersesWrapper .bibleVerse a').innerText;";
              final String verseRef =
                  await _controller.runJavaScriptReturningResult(verseRefJS) as String;

              setState(() {
                _currentVerseText = verseText.replaceAll('"', ''); // Store the verse text
                _currentVerseReference = verseRef.replaceAll('"', ''); // Store the verse reference
              });
            } catch (e) {
              setState(() {
                _loadError = true;
                _errorMessage = "Error extracting verse data: $e";
                _isLoading = false;
              });
            }
            // END OF ADDED BLOCK
          },
          onWebResourceError: (WebResourceError error) {
            // Called if a resource loading error occurs.
            debugPrint('''
Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
          ''');
            setState(() {
              _isLoading = false;
              _loadError = true; // Set error flag.
              _errorMessage =
                  "Error loading verse: ${error.description}"; // Set error message.
            });
          },
        ),
      );
    _loadVerse(); // Load the verse when the screen initializes.
  }

  // Fetches a random verse from the dailyverses.net API.
  Future<void> _loadVerse() async {
    setState(() {
      _isLoading = true;
      _loadError = false;
      _errorMessage = "";
    });

    // Check for network connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _loadError = true;
        _errorMessage =
            "No Internet Connection. Please check your network settings.";
        _isLoading = false;
      });
      return;
    }
    String jsCode = ""; // Initialize jsCode here
    String htmlString = "";
    try {
      // Fetch verse with timeout
      final response = await http
          .get(Uri.parse(
              'https://dailyverses.net/get/random.js?language=nrsv'))
          .timeout(const Duration(seconds: 10)); // 10-second timeout

      if (response.statusCode == 200) {
        jsCode = response.body; //Assign to the variable outside
        jsCode =
            jsCode.replaceAll('/* Inject the fetched JavaScript code */', '');

        htmlString = '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body {
              margin: 0;
              padding: 0;
              display: flex;
              justify-content: center;
              align-items: center;
              min-height: 100vh;
              text-align: center;
              font-family: 'Cinzel', serif;
              color: white;
              background-color: transparent;
            }
            #dailyVersesWrapper {
              padding: 20px;
              font-size: 1.8em;
              line-height: 1.6;
              max-width: 80%;
              background-color: transparent;
              text-shadow:
                1px 1px 3px rgba(255, 215, 0, 0.8),
                0 0 6px rgba(255, 255, 255, 0.6);
            }
            #dailyVersesWrapper a {
              color: rgba(255, 255, 255, 0.8);
              text-decoration: none;
              text-shadow: none;
            }
            #dailyVersesWrapper p {
              margin-bottom: 1em;
            }
          </style>
        </head>
        <body style="background-color: transparent;">
          <div id="dailyVersesWrapper"></div>
          <script>$jsCode</script>
        </body>
        </html>
      ''';
        await _controller.loadHtmlString(htmlString);
      } else {
        // Handle HTTP errors more specifically
        setState(() {
          _loadError = true;
          _isLoading = false; // Set loading to false here as well
          if (response.statusCode == 404) {
            _errorMessage = "Verse not found. Please try again later.";
          } else if (response.statusCode >= 500) {
            _errorMessage = "Server error. Please try again later.";
          } else {
            _errorMessage =
                "Failed to load verse (Error ${response.statusCode}).";
          }
        });
      }
    } on TimeoutException catch (_) {
      // Use catchError for TimeoutException
      setState(() {
        _loadError = true;
        _isLoading = false;
        _errorMessage = "Request timed out. Please check your connection.";
      });
    } on http.ClientException catch (_) {
      setState(() {
        _isLoading = false;
        _loadError = true;
        _errorMessage = "Network error. Please check your connection.";
      });
    } catch (e) {
      // Catch any other errors
      setState(() {
        _loadError = true;
        _isLoading = false;
        _errorMessage = "An unexpected error occurred: $e";
      });
    }
  }

  @override
  void dispose() {
    _buttonGlowAnimationController.dispose(); // Dispose of the animation controller.
    super.dispose();
  }

  // Builds the styled "Pray Again" button with the glowing animation.
  Widget _buildStyledButton(BuildContext context, double screenWidth,
      double screenHeight, Animation<double> animation) {
    final double buttonFontSize = screenWidth * 0.045;
    final double buttonPaddingHorizontal = screenWidth * 0.1;
    final double buttonPaddingVertical = screenHeight * 0.018;
    final double buttonBorderRadius = screenWidth * 0.03;
    final double extraPadding = 5.0 * animation.value; // Dynamic padding for animation.

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentGold
                    .withAlpha((80 + 80 * animation.value).toInt()), // Dynamic shadow color.
                blurRadius: 15 * animation.value, // Dynamic blur.
                spreadRadius: 4 * animation.value, // Dynamic spread.
              )
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              // Navigate back to the PreparatoryScreen.
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const PreparatoryScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: AppTheme.godTheFather, // Text color.
              backgroundColor: AppTheme.maryWhite, // Button background color.
              elevation: 8,
              shadowColor: AppTheme.accentGold.withAlpha((0.8 * 255).toInt()),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonBorderRadius),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: buttonPaddingHorizontal + extraPadding, // Apply extra padding.
                vertical: buttonPaddingVertical + extraPadding,
              ),
            ),
            child: Text(
              "Pray Again",
              style: TextStyle(
                fontSize: buttonFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(double screenWidth, double screenHeight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, color: Colors.white, size: screenWidth * 0.2),
          SizedBox(height: screenHeight * 0.02),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
          ),
          SizedBox(height: screenHeight * 0.04), // Add spacing
          ElevatedButton(
            onPressed: _loadVerse, // Retry the verse loading
            style: ElevatedButton.styleFrom(
              foregroundColor: AppTheme.godTheFather,
              backgroundColor: AppTheme.maryWhite,
            ),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // No AppBar to maximize content space.
      body: DoubleBackToCloseApp( // Wrap with DoubleBackToCloseApp
        snackBar: const SnackBar(
          content: Text('Tap back again to leave'),
        ),
        child: Container(
          decoration: const BoxDecoration(
            // Background gradient.
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.godTheFather,
                AppTheme.churchPurple,
                AppTheme.jesusChristCrimson,
                AppTheme.holySpirit,
                AppTheme.jesusChristGold,
                AppTheme.maryBlue,
                AppTheme.maryWhite,
              ],
            ),
          ),
          child: Stack(
            // Use a Stack to overlay the loading indicator.
            children: [
              Column(
                children: [
                  Expanded(
                    // WebView takes up the available space.
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: _loadError
                          ? _buildErrorWidget(screenWidth, screenHeight)
                          : WebViewWidget(controller: _controller), // Display the WebView.
                    ),
                  ),
                  // Spacing above the button row.  Adjusted for better positioning.
                  SizedBox(height: screenHeight * 0.06),
                  // The row of buttons (like, Pray Again, share).
                  _buildButtonSection(context, screenWidth, screenHeight),
                  // Spacing below the button row. Adjusted for better positioning.
                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
              if (_isLoading)
                // Show a loading indicator while the WebView is loading.
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withAlpha(128), // Semi-transparent black overlay.
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the button section (Like, Pray Again, Share).
  Widget _buildButtonSection(
      BuildContext context, double screenWidth, double screenHeight) {
    // final double iconSize = screenWidth * 0.07; // Removed unused variable.  Using direct value.
    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.04, // Left padding.
        screenWidth * 0.04, // Top padding.
        screenWidth * 0.04, // Right padding.
        screenHeight * 0.03, // Bottom padding - adjusted for better spacing.
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Space buttons evenly.
        children: [
          IconButton(
            icon: Icon(Icons.thumb_up_outlined,
                color: Colors.white, size: screenWidth * 0.07), // Like button.
            onPressed: () {}, // Placeholder for like functionality.
          ),
          // The "Pray Again" button.
          _buildStyledButton(context, screenWidth, screenHeight,
              _buttonGlowAnimationController),
          IconButton(
            icon: Icon(Icons.share,
                color: Colors.white, size: screenWidth * 0.07), // Share button.
            onPressed: () {
              // ADDED SHARING LOGIC
              if (_currentVerseText.isNotEmpty &&
                  _currentVerseReference.isNotEmpty) {
                Share.share('$_currentVerseText - $_currentVerseReference');
              }
            },
          ),
        ],
      ),
    );
  }
}