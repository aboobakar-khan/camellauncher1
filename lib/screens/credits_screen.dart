import 'package:flutter/material.dart';

/// Credits & Licenses Screen - Attribution for Qur'an and other resources
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildCreditsContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Credits & Licenses',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          title: '📖 Qur\'an Text & Translation',
          content:
              'This application includes Qur\'an text and translations for reading and reflection.',
        ),
        const SizedBox(height: 20),
        _buildLicenseCard(
          title: 'Arabic Qur\'an Text',
          description:
              'The Arabic Qur\'an text is sourced from public domain datasets based on the Uthmanic script.',
          license: 'Public Domain',
        ),
        const SizedBox(height: 16),
        _buildLicenseCard(
          title: 'English Translation',
          description:
              'English translation of the Qur\'an meanings provided by public domain sources.\n\n'
              'The translation is used for educational and spiritual purposes.\n\n'
              'Note: This is a translation of the meanings and is not a substitute for the original Arabic text.',
          license: 'Public Domain / Open License',
        ),
        const SizedBox(height: 16),
        _buildLicenseCard(
          title: 'Qur\'an Data Source',
          description:
              'Qur\'an data structure and organization inspired by open-source Islamic resources.\n\n'
              'We acknowledge the contributions of the global Muslim open-source community in making Qur\'an data accessible.',
          license: 'Various Open Licenses',
          hasLink: false,
        ),
        const SizedBox(height: 32),
        const Divider(color: Colors.white24, thickness: 1),
        const SizedBox(height: 32),
        _buildSection(
          title: '🎨 Design & Icons',
          content: 'This application uses carefully selected resources:',
        ),
        const SizedBox(height: 20),
        _buildLicenseCard(
          title: 'Material Design Icons',
          description: 'Icons provided by Google\'s Material Design',
          license: 'Apache License 2.0',
          hasLink: false,
        ),
        const SizedBox(height: 16),
        _buildLicenseCard(
          title: 'Lottie Animations',
          description: 'Animated backgrounds using Lottie by Airbnb',
          license: 'Apache License 2.0',
          hasLink: false,
        ),
        const SizedBox(height: 32),
        const Divider(color: Colors.white24, thickness: 1),
        const SizedBox(height: 32),
        _buildSection(
          title: '💙 Acknowledgments',
          content:
              'We are deeply grateful to:\n\n'
              '• The global Muslim community for preserving and sharing the Qur\'an\n\n'
              '• Open-source contributors who make Islamic resources accessible\n\n'
              '• The Flutter community for building amazing tools\n\n'
              '• All users who support this project',
        ),
        const SizedBox(height: 32),
        _buildDisclaimerCard(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            height: 1.6,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildLicenseCard({
    required String title,
    required String description,
    required String license,
    bool hasLink = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
              height: 1.5,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'License: $license',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade300, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Important Note',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'While we strive for accuracy, the English translation is a translation of meanings and should not replace reading the original Arabic Qur\'an.\n\n'
            'For religious study, please consult qualified scholars and authentic sources.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              height: 1.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
