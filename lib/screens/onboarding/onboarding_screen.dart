import 'package:flutter/material.dart';
import 'package:peerpicks/common/app_colors.dart';
import 'package:peerpicks/screens/auth/sign_in_screen.dart';
import 'package:peerpicks/widgets/my_button.dart';
// Removed: import 'package:onboarding_app/common/mysnackbar.dart';

// --- 1. DATA MODEL FOR ONBOARDING PAGES ---
class OnboardingContent {
  final String imagePath;
  final String title;
  final String description;
  final String buttonText;
  final bool isLastPage;

  OnboardingContent({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.buttonText,
    this.isLastPage = false,
  });
}

final List<OnboardingContent> contents = [
  OnboardingContent(
    imagePath: 'assets/images/onboarding_1.png',
    title: '“Discover Local. Support Local.”',
    description:
        'Stay connected to the best local businesses, discover hidden gems, and get recommendations from real people in your community.',
    buttonText: 'Explore',
  ),
  OnboardingContent(
    imagePath: 'assets/images/onboarding_2.png',
    title: '“Explore Hidden Local Treasures.”',
    description:
        'Find the best nearby shops, cafes, and services recommended by real people in your community.',
    buttonText: 'Next',
  ),
  OnboardingContent(
    imagePath: 'assets/onboarding_3.png',
    title: '“Empower Local Businesses.”',
    description:
        'Your reviews and favorites help small businesses grow and get discovered by more people.',
    buttonText: 'Next',
  ),
  OnboardingContent(
    imagePath: 'assets/onboarding_4.png',
    title: '“Pick. Rate.Share.”',
    description:
        'Sign up to start exploring, saving favorites, and sharing your picks with friends.',
    buttonText: 'Get Started',
    isLastPage: true,
  ),
];

// --- 2. MAIN ONBOARDING SCREEN WIDGET ---
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  // Handles moving to the next page or completing onboarding
  void _nextPage() {
    if (_currentPage < contents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // Logic to navigate to Sign Up/Home screen
      // Updated call to use the new local showMySnackBar function
      showMySnackBar(
        context: context,
        message: 'Onboarding Complete! Welcome!',
        color: AppColors.primaryGreen, // Explicitly use app's theme color
      );

      // Navigate to SignInScreen and replace the current route
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    }
  }

  // Handles skipping the onboarding process (Navigates directly to SignInScreen)
  void _skipOnboarding() {
    // Updated call to use the new local showMySnackBar function
    showMySnackBar(
      context: context,
      message: 'Onboarding skipped. Proceeding to Sign In.',
      color: AppColors.primaryGreen, // Explicitly use app's theme color
    );

    // Navigate to SignInScreen and replace the current route
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen size for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    // Set a maximum width for content on tablets to improve readability
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button and Logo Row
            _buildHeaderRow(),

            // Main Content Area (Responsive PageView)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: contents.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(contents[index], isTablet);
                },
              ),
            ),

            // Page Indicator and Button Area
            _buildFooter(isTablet),
          ],
        ),
      ),
    );
  }

  // --- 3. HELPER WIDGETS ---

  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, left: 24.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo (Placeholder for "PEER PICKS" logo)
          Row(
            children: [
              // You would replace this with your actual logo widget/image
              Container(width: 30, height: 30, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              const Text(
                'PEER\nPICKS',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  height: 1.0,
                ),
              ),
            ],
          ),

          // Skip Button
          if (!contents[_currentPage].isLastPage)
            TextButton(
              onPressed: _skipOnboarding,
              child: const Text(
                'Skip >',
                style: TextStyle(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingContent content, bool isTablet) {
    // Max width for content on large screens (tablets)
    final double maxWidth = isTablet ? 450 : double.infinity;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image/Illustration Area
            Expanded(
              flex: 4,
              child: Center(
                // Placeholder for the custom illustration image
                // Replace this Container with: Image.asset(content.imagePath, fit: BoxFit.contain)
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.indicatorInactive.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        'Image: ${content.imagePath.split('/').last}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.darkText),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Text Content Area
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title/Tagline
                  Text(
                    content.title,
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    content.description,
                    style: const TextStyle(
                      color: AppColors.lightText,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isTablet) {
    return Column(
      children: [
        // Page Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            contents.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              height: 10.0,
              width: 10.0,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.indicatorActive
                    : AppColors.indicatorInactive,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),

        // Vertical spacing before the button
        SizedBox(height: isTablet ? 60 : 40),

        // Action Button
        MyButton(text: contents[_currentPage].buttonText, onPressed: _nextPage),
      ],
    );
  }
}

// Standalone SnackBar function (as provided by the user)
showMySnackBar({
  required BuildContext context,
  required String message,
  Color? color,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      // Ensure text is white for contrast against green/dark backgrounds
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: color ?? Colors.green,
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
