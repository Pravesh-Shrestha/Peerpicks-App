import 'package:flutter/material.dart';
import 'package:peerpicks/common/mysnackbar.dart';
import 'package:peerpicks/model/onboarding_model.dart';
import 'package:peerpicks/screens/auth/sign_in_screen.dart';
import 'package:peerpicks/widgets/onboarding_footer.dart';
import 'package:peerpicks/widgets/onboarding_page_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  void _nextPage() {
    // Check the isLastPage flag from the content model
    if (!contents[_currentPage].isLastPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // Final page reached: navigate to Sign In
      showMySnackBar(
        context: context,
        message: 'Onboarding Complete! Proceeding to Sign In.',
        color: const Color.fromARGB(255, 113, 163, 52),
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
      color: Colors.black, // Use a different color for skipped action
    );
    // Navigate directly to Sign In screen
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
    // Get the current content model
    final currentContent = contents[_currentPage];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Logo and Skip Button (Conditional)
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 120,
                    child: Image.asset(
                      'assets/images/logos/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  currentContent.isLastPage
                      ? const SizedBox(width: 50)
                      : TextButton(
                          onPressed: _skipOnboarding,
                          child: const Text(
                            "Skip",
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
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

            // 3. Footer
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
