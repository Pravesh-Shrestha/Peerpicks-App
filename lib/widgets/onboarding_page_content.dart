import 'package:flutter/material.dart';
import 'package:peerpicks/model/onboarding_model.dart';

class OnboardingPageContent extends StatelessWidget {
  final OnboardingContent content;
  final bool isTablet;

  const OnboardingPageContent({
    super.key,
    required this.content,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: isTablet ? 400 : 300,
              child: Image.asset(
                content.imagePath,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  height: isTablet ? 400 : 300,
                  child: const Center(
                    child: Text(
                      'Image Placeholder',
                      style: TextStyle(
                        color: Color.fromARGB(255, 102, 102, 102),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 0),
              child: Column(
                children: [
                  Text(
                    content.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 107, 164, 38),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    content.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 130, 130, 130),
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
}
