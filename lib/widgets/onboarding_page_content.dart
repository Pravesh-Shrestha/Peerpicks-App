import 'package:flutter/material.dart';
import 'package:peerpicks/common/app_colors.dart';
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
    final orientation = MediaQuery.of(context).orientation;
    final isLandscapeTablet = isTablet && orientation == Orientation.landscape;

    Widget imageContent = Padding(
      padding: EdgeInsets.only(top: isLandscapeTablet ? 0 : 20),
      child: Image.asset(
        content.imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Text(
              'Image Placeholder',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ),
    );

    Widget textSection = Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: isLandscapeTablet ? 0 : (isTablet ? 40 : 0),
      ),
      child: Column(
        mainAxisAlignment: isLandscapeTablet
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            content.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.indicatorActive,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.lightText,
              fontSize: 18,
              height: 1.4,
            ),
          ),
        ],
      ),
    );

    Widget responsiveLayout;

    if (isLandscapeTablet) {
      responsiveLayout = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 4, child: imageContent),
          const SizedBox(width: 40),
          Expanded(flex: 6, child: textSection),
        ],
      );
    } else {
      responsiveLayout = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FractionallySizedBox(
            heightFactor: isTablet ? 0.40 : 0.35,
            child: imageContent,
          ),
          const SizedBox(height: 30),
          textSection,
        ],
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: responsiveLayout,
        ),
      ),
    );
  }
}
