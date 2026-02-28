import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: February 28, 2026',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 24),

            _heading('1. Introduction', cs),
            _body(
              'Welcome to PeerPicks ("we", "our", or "us"). We are committed to '
              'protecting your personal information and your right to privacy. This '
              'Privacy Policy explains how we collect, use, disclose, and safeguard '
              'your information when you use our mobile application and services.',
              cs,
            ),

            _heading('2. Information We Collect', cs),
            _subheading('2.1 Personal Information', cs),
            _body(
              'When you create an account, we collect:\n'
              '  • Full name and email address\n'
              '  • Profile picture (optional)\n'
              '  • Date of birth (optional)\n'
              '  • Authentication credentials',
              cs,
            ),
            _subheading('2.2 User-Generated Content', cs),
            _body(
              'We collect content you voluntarily provide, including:\n'
              '  • Picks (reviews and recommendations)\n'
              '  • Photos and videos uploaded to picks\n'
              '  • Comments and reactions\n'
              '  • Ratings and reviews',
              cs,
            ),
            _subheading('2.3 Usage Data', cs),
            _body(
              'We automatically collect certain information when you use PeerPicks:\n'
              '  • Device information (model, OS version)\n'
              '  • Log data (access times, pages viewed)\n'
              '  • Location data (when permission is granted)\n'
              '  • App interaction data and analytics',
              cs,
            ),

            _heading('3. How We Use Your Information', cs),
            _body(
              'We use the information we collect to:\n'
              '  • Provide, operate, and maintain our services\n'
              '  • Personalize your experience and content recommendations\n'
              '  • Process and manage your account\n'
              '  • Communicate with you about updates and promotions\n'
              '  • Monitor and analyze usage patterns and trends\n'
              '  • Detect, prevent, and address technical issues\n'
              '  • Comply with legal obligations',
              cs,
            ),

            _heading('4. Sharing Your Information', cs),
            _body(
              'We may share your information in the following situations:\n\n'
              'Public Profile Information: Your username, profile picture, picks, '
              'and public activity are visible to other users.\n\n'
              'Service Providers: We may share your data with third-party vendors '
              'who perform services on our behalf (hosting, analytics, etc.).\n\n'
              'Legal Requirements: We may disclose your information when required '
              'by law or in response to valid legal processes.\n\n'
              'Business Transfers: In the event of a merger, acquisition, or sale '
              'of assets, your data may be transferred.',
              cs,
            ),

            _heading('5. Data Security', cs),
            _body(
              'We implement industry-standard security measures to protect your '
              'personal information, including:\n'
              '  • Encrypted data transmission (TLS/SSL)\n'
              '  • Secure password hashing (bcrypt)\n'
              '  • JWT-based authentication tokens\n'
              '  • Regular security audits and monitoring\n\n'
              'However, no electronic transmission over the internet is 100% secure. '
              'We cannot guarantee absolute security of your data.',
              cs,
            ),

            _heading('6. Data Retention', cs),
            _body(
              'We retain your personal information for as long as your account is '
              'active or as needed to provide you services. You may request deletion '
              'of your account and associated data at any time through the app settings.\n\n'
              'Certain information may be retained for legal compliance, dispute '
              'resolution, or enforcement of our agreements.',
              cs,
            ),

            _heading('7. Your Rights', cs),
            _body(
              'Depending on your location, you may have the following rights:\n'
              '  • Access and receive a copy of your personal data\n'
              '  • Correct inaccurate or incomplete information\n'
              '  • Delete your personal data ("right to be forgotten")\n'
              '  • Object to or restrict processing of your data\n'
              '  • Data portability (receive data in a structured format)\n'
              '  • Withdraw consent at any time\n\n'
              'To exercise these rights, contact us at privacy@peerpicks.com.',
              cs,
            ),

            _heading('8. Children\'s Privacy', cs),
            _body(
              'PeerPicks is not intended for users under the age of 13. We do not '
              'knowingly collect personal information from children under 13. If we '
              'become aware that a child under 13 has provided us with personal '
              'information, we will take steps to delete such information.',
              cs,
            ),

            _heading('9. Third-Party Services', cs),
            _body(
              'Our app may contain links to third-party websites or services. We '
              'are not responsible for the privacy practices of these external '
              'services. We encourage you to read the privacy policies of any '
              'third-party services you access.\n\n'
              'Third-party services we use include:\n'
              '  • Google Sign-In (authentication)\n'
              '  • Apple Sign-In (authentication)\n'
              '  • Cloud storage providers (media hosting)',
              cs,
            ),

            _heading('10. Changes to This Policy', cs),
            _body(
              'We may update this Privacy Policy from time to time. We will notify '
              'you of any changes by posting the new Privacy Policy within the app '
              'and updating the "Last updated" date.\n\n'
              'Your continued use of PeerPicks after changes are posted constitutes '
              'your acceptance of the revised policy.',
              cs,
            ),

            _heading('11. Contact Us', cs),
            _body(
              'If you have any questions about this Privacy Policy, please contact '
              'us at:\n\n'
              'PeerPicks Support\n'
              'Email: privacy@peerpicks.com\n'
              'Website: https://peerpicks.com/privacy',
              cs,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  static Widget _heading(String text, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: cs.onSurface,
        ),
      ),
    );
  }

  static Widget _subheading(String text, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
      ),
    );
  }

  static Widget _body(String text, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: cs.onSurfaceVariant,
          height: 1.6,
        ),
      ),
    );
  }
}
