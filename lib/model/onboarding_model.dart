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

/// UPDATED Content List
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
    imagePath: 'assets/images/onboarding_3.png',
    title: '“Empower Local Businesses.”',
    description:
        'Your reviews and favorites help small businesses grow and get discovered by more people.',
    buttonText: 'Next',
  ),
  OnboardingContent(
    imagePath: 'assets/images/onboarding_4.png',
    title: '“Pick. Rate.Share.”',
    description:
        'Sign up to start exploring, saving favorites, and sharing your picks with friends.',
    buttonText: 'Get Started',
    isLastPage: true,
  ),
];
