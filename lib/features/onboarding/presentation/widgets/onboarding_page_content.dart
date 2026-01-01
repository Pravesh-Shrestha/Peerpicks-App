import 'package:flutter/material.dart';
import 'package:peerpicks/common/app_colors.dart';
import 'package:peerpicks/features/onboarding/data/models/onboarding_model.dart';

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
    final mediaQuery = MediaQuery.of(context);
    final orientation = mediaQuery.orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isLandscapeTablet = isTablet && isLandscape;

    // Dynamic text sizes
    final titleSize = isTablet ? 40.0 : 32.0;
    final descriptionSize = isTablet ? 20.0 : 18.0;

    // Calculate a height factor for the image in vertical mode
    // to ensure content fits above the footer.
    // 0.4 for phone, 0.5 for large phone/small tablet, 0.4 for large tablet
    double imageHeightFactor = mediaQuery.size.height > 800 ? 0.45 : 0.4;
    if (isTablet) {
      imageHeightFactor = isLandscape ? 0.9 : 0.4;
    }

    Widget imageContent = Padding(
      padding: EdgeInsets.only(
        top: isLandscapeTablet ? 0 : (isTablet ? 40 : 20),
      ),
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
            style: TextStyle(
              color: AppColors.indicatorActive,
              fontSize: titleSize, // Responsive title size
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            content.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.lightText,
              fontSize: descriptionSize, // Responsive description size
              height: 1.4,
            ),
          ),
        ],
      ),
    );

    Widget responsiveLayout;

    if (isLandscapeTablet || isLandscape) {
      // Horizontal layout for landscape or landscape tablet
      responsiveLayout = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 4, child: imageContent),
          SizedBox(width: isTablet ? 60 : 40),
          Expanded(flex: 6, child: textSection),
        ],
      );
    } else {
      // Vertical layout for portrait phone/tablet
      responsiveLayout = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            // Use dynamic height based on screen size for image area
            height: mediaQuery.size.height * imageHeightFactor,
            child: imageContent,
          ),
          SizedBox(height: isTablet ? 50 : 30),
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
