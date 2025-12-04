import 'package:flutter/material.dart';
import 'package:peerpicks/common/app_colors.dart';
import 'package:peerpicks/common/mysnackbar.dart';
import 'package:peerpicks/screens/auth/sign_in_screen.dart';
import 'package:peerpicks/widgets/my_button.dart';
import '../../model/onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  void _nextPage() {
    if (_currentPage < contents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      showMySnackBar(
        context: context,
        message: 'Onboarding Complete! Welcome!',
        color: AppColors.primaryGreen,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    }
  }

  void _skipOnboarding() {
    showMySnackBar(
      context: context,
      message: 'Onboarding skipped. Proceeding to Sign In.',
      color: AppColors.primaryGreen,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderRow(),
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
            _buildFooter(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, left: 24.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/logos/logo.png',
                height: 120,
                fit: BoxFit.contain,
              ),
            ],
          ),
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
    final double maxWidth = isTablet ? 450 : double.infinity;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: Center(
                child: Image.asset(
                  content.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback container if the asset is missing
                    return AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.indicatorInactive.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            'Missing Asset:\n${content.imagePath.split('/').last}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.darkText),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
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
        SizedBox(height: isTablet ? 60 : 40),
        MyButton(text: contents[_currentPage].buttonText, onPressed: _nextPage),
      ],
    );
  }
}
