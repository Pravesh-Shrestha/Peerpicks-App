import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peerpicks/features/onboarding/data/models/onboarding_model.dart';
import 'package:peerpicks/features/onboarding/presentation/widgets/onboarding_footer.dart';
import 'package:peerpicks/features/onboarding/presentation/widgets/onboarding_page_content.dart';

Widget wrap(Widget child, {Size? size}) {
  final data = MediaQueryData(size: size ?? const Size(390, 844));

  return MaterialApp(
    home: MediaQuery(
      data: data,
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('Extra Widget Tests (9)', () {
    testWidgets('1) OnboardingPageContent renders first page title', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(OnboardingPageContent(content: contents.first, isTablet: false)),
      );

      expect(find.text(contents.first.title), findsOneWidget);
    });

    testWidgets('2) OnboardingPageContent renders description', (tester) async {
      await tester.pumpWidget(
        wrap(OnboardingPageContent(content: contents.first, isTablet: false)),
      );

      expect(find.text(contents.first.description), findsOneWidget);
    });

    testWidgets(
      '3) OnboardingPageContent shows placeholder for missing asset',
      (tester) async {
        final custom = OnboardingContent(
          imagePath: 'assets/images/does_not_exist.png',
          title: 'T',
          description: 'D',
          buttonText: 'Next',
        );

        await tester.pumpWidget(
          wrap(OnboardingPageContent(content: custom, isTablet: false)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Image Placeholder'), findsOneWidget);
      },
    );

    testWidgets('4) OnboardingPageContent uses scroll view container', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(OnboardingPageContent(content: contents.first, isTablet: false)),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('5) OnboardingPageContent builds landscape layout row', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          OnboardingPageContent(content: contents.first, isTablet: false),
          size: const Size(900, 500),
        ),
      );

      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('6) OnboardingFooter shows indicator count equal to pages', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          OnboardingFooter(currentPage: 0, isTablet: false, nextPage: () {}),
        ),
      );

      final indicators = find.byType(AnimatedContainer);
      expect(indicators, findsNWidgets(contents.length));
    });

    testWidgets('7) OnboardingFooter shows correct button label', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          OnboardingFooter(currentPage: 3, isTablet: false, nextPage: () {}),
        ),
      );

      expect(find.text(contents[3].buttonText), findsOneWidget);
    });

    testWidgets('8) OnboardingFooter invokes callback on button tap', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(
          OnboardingFooter(
            currentPage: 1,
            isTablet: false,
            nextPage: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text(contents[1].buttonText));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('9) OnboardingFooter has exactly one active wide indicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          OnboardingFooter(currentPage: 2, isTablet: false, nextPage: () {}),
        ),
      );

      final containers = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();
      final wideCount = containers
          .where((c) => c.constraints?.maxWidth == 25.0)
          .length;
      expect(wideCount, 1);
    });
  });
}
