import 'package:flutter/material.dart';
import 'package:peerpicks/common/app_colors.dart';
import 'package:peerpicks/features/onboarding/data/models/onboarding_model.dart';

import 'package:peerpicks/widgets/my_button.dart';

class OnboardingFooter extends StatelessWidget {
  final int currentPage;
  final bool isTablet;
  final VoidCallback nextPage;

  const OnboardingFooter({
    super.key,
    required this.currentPage,
    required this.isTablet,
    required this.nextPage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(contents.length, (index) {
            final isActive = currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              height: 10.0,
              width: isActive ? 25.0 : 10.0,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryGreen
                    : AppColors.indicatorInactive,
                borderRadius: BorderRadius.circular(5),
              ),
            );
          }),
        ),
        SizedBox(height: isTablet ? 60 : 40),
        MyButton(text: contents[currentPage].buttonText, onPressed: nextPage),
      ],
    );
  }
}
