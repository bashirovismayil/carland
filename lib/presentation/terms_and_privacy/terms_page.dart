import 'package:flutter/material.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/constants/values/app_theme.dart';
import '../../../core/localization/app_translation.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppTranslation.translate(AppStrings.termsAndConditions),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLastUpdated(),
            const SizedBox(height: 24),
            _buildIntroduction(),
            const SizedBox(height: 32),
            _buildSection(
              '1. Acceptance of Terms',
              'By creating an account, accessing, or using CarCat, you acknowledge that you have read, understood, and agree to be bound by these Terms and our Privacy Policy. If you do not agree to these Terms, you must not use the Service.',
            ),
            _buildSection(
              '2. About CarCat',
              'CarCat is a digital platform that connects vehicle owners with automotive service providers. We facilitate:\n\n'
                  '• Vehicle registration and management\n'
                  '• Service history tracking\n'
                  '• Booking appointments with automotive service centers\n'
                  '• Maintenance reminders and notifications\n\n'
                  'Important: CarCat acts solely as an intermediary platform. We do not provide automotive repair or maintenance services directly. All services are performed by independent third-party service providers.',
            ),
            _buildSection(
              '3. Eligibility',
              '3.1 Age Requirements\n'
                  'While there is no strict minimum age requirement to use CarCat, users under the age of 18 may register vehicles on behalf of family members or other authorized individuals.\n\n'
                  '3.2 Account Registration\n'
                  'To use certain features of CarCat, you must:\n\n'
                  '• Provide accurate, current, and complete information\n'
                  '• Maintain and update your account information\n'
                  '• Keep your login credentials secure\n'
                  '• Notify us of any unauthorized access',
            ),
            _buildSection(
              '4. User Responsibilities',
              '4.1 Vehicle Information\n'
                  'You are responsible for ensuring that all vehicle information you provide is accurate and up-to-date.\n\n'
                  '4.2 Prohibited Conduct\n'
                  'You agree not to:\n\n'
                  '• Provide false or fraudulent information\n'
                  '• Use the Service for unlawful purposes\n'
                  '• Interfere with or disrupt the Service\n'
                  '• Attempt unauthorized access\n'
                  '• Impersonate any person or entity\n'
                  '• Upload malicious content\n\n'
                  '4.3 Third-Party Services\n'
                  'When you book appointments, you enter into a direct relationship with the service provider. We are not responsible for service quality, disputes, or vehicle damage.',
            ),
            _buildSection(
              '5. Service Availability',
              'We strive to keep CarCat available 24/7, but we do not guarantee uninterrupted access. The Service may be temporarily unavailable due to maintenance, technical issues, or network failures.\n\n'
                  'We reserve the right to modify, suspend, or discontinue any part of the Service at any time.',
            ),
            _buildSection(
              '6. Bookings and Appointments',
              '6.1 Booking Process\n'
                  'CarCat allows you to book appointments with service providers. By making a booking, you agree to attend or cancel according to the provider\'s policy.\n\n'
                  '6.2 No Payment Processing\n'
                  'CarCat does not currently process payments. All financial transactions are made directly with service providers.\n\n'
                  '6.3 Cancellations\n'
                  'Cancellation policies are set by individual service providers.',
            ),
            _buildSection(
              '7. Intellectual Property Rights',
              'All content, features, and functionality of CarCat are the exclusive property of Digital Innovation Agency LLC and are protected by international copyright and trademark laws.\n\n'
                  'By uploading vehicle photos or content, you grant us a non-exclusive license to use such content solely for providing the Service. You retain ownership and may delete it anytime.',
            ),
            _buildSection(
              '8. Privacy and Data Protection',
              'We collect and process personal information as described in our Privacy Policy, including:\n\n'
                  '• Name and contact information\n'
                  '• Phone number\n'
                  '• Vehicle information (VIN, plate, model, mileage)\n'
                  '• Vehicle and profile photos (optional)\n'
                  '• Service history\n\n'
                  'Your data is used solely to provide and improve the Service. You may request deletion at any time.',
            ),
            _buildSection(
              '9. Machine Learning and Automation',
              'CarCat uses Google ML Kit for VIN scanning functionality. This technology helps you quickly register vehicles and reduce errors. VIN scanning data is processed on-device and not shared with third parties.',
            ),
            _buildSection(
              '10. Disclaimers and Limitation of Liability',
              'IMPORTANT: CarCat is a platform only. We do not employ or control service providers, guarantee service quality, or assume responsibility for service provider actions.\n\n'
                  'All service-related issues including incorrect repairs, vehicle damage, or pricing disputes must be resolved directly with the service provider.\n\n'
                  'TO THE MAXIMUM EXTENT PERMITTED BY LAW:\n'
                  '• CarCat is provided "AS IS" without warranties\n'
                  '• We are not liable for any damages\n'
                  '• Our total liability shall not exceed \$0',
            ),
            _buildSection(
              '11. Disputes and Resolution',
              'Disputes between users and service providers must be resolved directly. We encourage communication through:\n\n'
                  '• The in-app support section\n'
                  '• Direct contact with the provider\n'
                  '• Email to digital.innovation.agency.aze@gmail.com\n\n'
                  'These Terms are governed by the laws of the Republic of Azerbaijan.',
            ),
            _buildSection(
              '12. Account Termination',
              'You may terminate your account anytime through app settings or by contacting us.\n\n'
                  'We may suspend or terminate your account if you violate these Terms, engage in fraudulent activity, or provide false information.',
            ),
            _buildSection(
              '13. Changes to These Terms',
              'We may update these Terms from time to time. We will notify you through the app or via email. Continued use after changes constitutes acceptance.',
            ),
            _buildContactSection(),
            const SizedBox(height: 32),
            _buildAcceptanceNotice(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Text(
            'Last Updated: December 25, 2025',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroduction() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome to CarCat',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'These Terms and Conditions govern your access to and use of the CarCat mobile application and related services operated by Digital Innovation Agency LLC, registered in Baku, Azerbaijan.',
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlack.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlack.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '14. Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactItem(Icons.business, 'Digital Innovation Agency LLC'),
          _buildContactItem(Icons.business, 'Rəqəmsal İnnovasiyalar Agentliyi'),
          _buildContactItem(Icons.email_outlined, 'digital.innovation.agency.aze@gmail.com'),
          _buildContactItem(Icons.language, 'https://digital-innovation.agency/'),
          _buildContactItem(Icons.location_on_outlined, 'Baku, Azerbaijan'),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primaryBlack,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptanceNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlack,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'By using CarCat, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}