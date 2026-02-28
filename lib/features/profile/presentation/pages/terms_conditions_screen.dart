import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
          'Terms & Conditions',
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
              'Effective date: February 28, 2026',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 24),

            _heading('1. Acceptance of Terms', cs),
            _body(
              'By downloading, installing, or using the PeerPicks application '
              '("App"), you agree to be bound by these Terms and Conditions '
              '("Terms"). If you do not agree to these Terms, do not use the App.\n\n'
              'These Terms constitute a legally binding agreement between you and '
              'PeerPicks Inc. ("Company", "we", "our", or "us").',
              cs,
            ),

            _heading('2. Eligibility', cs),
            _body(
              'You must be at least 13 years old to use PeerPicks. By using the '
              'App, you represent and warrant that:\n'
              '  • You are at least 13 years of age\n'
              '  • You have the legal capacity to enter into these Terms\n'
              '  • You are not prohibited from using the App under applicable law\n'
              '  • Your use will comply with all applicable laws and regulations',
              cs,
            ),

            _heading('3. User Accounts', cs),
            _body(
              '3.1 Registration: You must create an account to access certain '
              'features. You agree to provide accurate, current, and complete '
              'information during registration.\n\n'
              '3.2 Account Security: You are responsible for maintaining the '
              'confidentiality of your account credentials. You agree to notify '
              'us immediately of any unauthorized use of your account.\n\n'
              '3.3 Account Termination: We reserve the right to suspend or '
              'terminate your account at any time for violations of these Terms '
              'or for any reason at our sole discretion.',
              cs,
            ),

            _heading('4. User Content', cs),
            _body(
              '4.1 Ownership: You retain ownership of all content you post, '
              'including picks, reviews, photos, videos, and comments ("User '
              'Content").\n\n'
              '4.2 License Grant: By posting User Content, you grant PeerPicks '
              'a non-exclusive, worldwide, royalty-free, transferable license to '
              'use, reproduce, modify, distribute, and display your content in '
              'connection with operating and providing the App.\n\n'
              '4.3 Content Standards: You agree not to post content that:\n'
              '  • Is illegal, harmful, threatening, or harassing\n'
              '  • Infringes on intellectual property rights\n'
              '  • Contains spam, malware, or deceptive content\n'
              '  • Impersonates any person or entity\n'
              '  • Violates any applicable laws or regulations\n'
              '  • Contains personal information of others without consent',
              cs,
            ),

            _heading('5. Picks & Reviews', cs),
            _body(
              '5.1 Accuracy: You agree that all picks and reviews you create '
              'represent your genuine experience and honest opinion.\n\n'
              '5.2 Moderation: We reserve the right to remove any pick or review '
              'that violates these Terms, our Community Guidelines, or is deemed '
              'inappropriate at our sole discretion.\n\n'
              '5.3 No Compensation: Picks and reviews are voluntary. PeerPicks '
              'does not compensate users for creating content unless explicitly '
              'stated in a separate agreement.',
              cs,
            ),

            _heading('6. Social Features', cs),
            _body(
              '6.1 Following: You may follow other users to see their content in '
              'your feed. You can unfollow at any time.\n\n'
              '6.2 Interactions: You may upvote, comment on, and save other users\' '
              'picks. All interactions must comply with our Community Guidelines.\n\n'
              '6.3 Notifications: By following users or interacting with content, '
              'you consent to receiving relevant notifications. You can manage '
              'notification preferences in Settings.',
              cs,
            ),

            _heading('7. Prohibited Conduct', cs),
            _body(
              'You agree not to:\n'
              '  • Use the App for any unlawful purpose\n'
              '  • Attempt to gain unauthorized access to our systems\n'
              '  • Interfere with or disrupt the App or servers\n'
              '  • Create fake accounts or manipulate engagement metrics\n'
              '  • Scrape, crawl, or collect data from the App without permission\n'
              '  • Use automated systems or bots to access the App\n'
              '  • Circumvent any security measures or content protections\n'
              '  • Engage in any activity that harms other users',
              cs,
            ),

            _heading('8. Intellectual Property', cs),
            _body(
              'The App and its original content (excluding User Content), features, '
              'and functionality are owned by PeerPicks Inc. and are protected by '
              'international copyright, trademark, patent, trade secret, and other '
              'intellectual property laws.\n\n'
              'The PeerPicks name, logo, and all related names, logos, product and '
              'service names, designs, and slogans are trademarks of PeerPicks Inc. '
              'You may not use such marks without our prior written permission.',
              cs,
            ),

            _heading('9. Disclaimer of Warranties', cs),
            _body(
              'THE APP IS PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS WITHOUT '
              'WARRANTIES OF ANY KIND, WHETHER EXPRESS OR IMPLIED. WE DISCLAIM ALL '
              'WARRANTIES, INCLUDING BUT NOT LIMITED TO:\n'
              '  • MERCHANTABILITY\n'
              '  • FITNESS FOR A PARTICULAR PURPOSE\n'
              '  • NON-INFRINGEMENT\n'
              '  • ACCURACY OR RELIABILITY OF CONTENT\n\n'
              'We do not warrant that the App will be uninterrupted, secure, or '
              'error-free, or that defects will be corrected.',
              cs,
            ),

            _heading('10. Limitation of Liability', cs),
            _body(
              'TO THE MAXIMUM EXTENT PERMITTED BY LAW, PEERPICKS INC. SHALL NOT '
              'BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR '
              'PUNITIVE DAMAGES, INCLUDING BUT NOT LIMITED TO LOSS OF PROFITS, DATA, '
              'USE, GOODWILL, OR OTHER INTANGIBLE LOSSES, RESULTING FROM:\n'
              '  • Your access to or use of (or inability to use) the App\n'
              '  • Any conduct or content of any third party on the App\n'
              '  • Any User Content obtained from the App\n'
              '  • Unauthorized access, use, or alteration of your data',
              cs,
            ),

            _heading('11. Indemnification', cs),
            _body(
              'You agree to defend, indemnify, and hold harmless PeerPicks Inc. '
              'and its officers, directors, employees, and agents from any claims, '
              'damages, obligations, losses, liabilities, costs, or debt arising '
              'from your use of the App or violation of these Terms.',
              cs,
            ),

            _heading('12. Changes to Terms', cs),
            _body(
              'We reserve the right to modify these Terms at any time. We will '
              'provide notice of significant changes through the App or via email. '
              'Your continued use of PeerPicks after changes are posted constitutes '
              'your acceptance of the modified Terms.\n\n'
              'We encourage you to review these Terms periodically for any changes.',
              cs,
            ),

            _heading('13. Governing Law', cs),
            _body(
              'These Terms shall be governed by and construed in accordance with '
              'the laws of the jurisdiction in which PeerPicks Inc. is incorporated, '
              'without regard to its conflict of law provisions.',
              cs,
            ),

            _heading('14. Contact Information', cs),
            _body(
              'If you have any questions about these Terms, please contact us:\n\n'
              'PeerPicks Inc.\n'
              'Email: legal@peerpicks.com\n'
              'Website: https://peerpicks.com/terms',
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

  static Widget _body(String text, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant, height: 1.6),
      ),
    );
  }
}
