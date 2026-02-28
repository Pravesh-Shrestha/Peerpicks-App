import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peerpicks/features/onboarding/presentation/widgets/onboarding_page_content.dart';
import 'package:peerpicks/features/onboarding/data/models/onboarding_model.dart';

void main() {
  testWidgets('WIDGET-OnboardingPageContent displays title and description', (
    WidgetTester tester,
  ) async {
    final dummyContent = OnboardingContent(
      title: 'Find Peers',
      description: 'Connect with people around you.',
      imagePath: 'assets/images/onboarding1.png',
      buttonText: 'Next',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OnboardingPageContent(content: dummyContent, isTablet: false),
        ),
      ),
    );

    // Verify that title and description are rendered
    expect(find.text('Find Peers'), findsOneWidget);
    expect(find.text('Connect with people around you.'), findsOneWidget);
  });
}
