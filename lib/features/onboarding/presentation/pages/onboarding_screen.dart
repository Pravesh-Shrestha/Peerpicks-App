import 'package:flutter/material.dart';
import 'package:peerpicks/common/app_colors.dart';
import 'package:peerpicks/common/mysnackbar.dart';
import 'package:peerpicks/features/onboarding/data/models/onboarding_model.dart';
import 'package:peerpicks/features/onboarding/presentation/widgets/onboarding_footer.dart';
import 'package:peerpicks/features/onboarding/presentation/widgets/onboarding_page_content.dart';
import 'package:peerpicks/screens/auth/sign_in_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  void _nextPage() {
    if (!contents[_currentPage].isLastPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      showMySnackBar(
        context: context,
        message: 'Onboarding Complete! Proceeding to Sign In.',
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
      color: Colors.black,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final currentContent = contents[_currentPage];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 60,
                    child: Image.asset(
                      'assets/images/logos/logo.png',
                      errorBuilder: (context, error, stackTrace) => const Text(
                        'PeerPicks',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                  currentContent.isLastPage
                      ? const SizedBox(width: 50)
                      : TextButton(
                          onPressed: _skipOnboarding,
                          child: const Text(
                            "Skip",
                            style: TextStyle(
                              color: AppColors.lightText,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: contents.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (_, i) {
                  return OnboardingPageContent(
                    content: contents[i],
                    isTablet: isTablet,
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, isTablet ? 40 : 20),
              child: OnboardingFooter(
                currentPage: _currentPage,
                isTablet: isTablet,
                nextPage: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
