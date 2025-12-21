import 'package:flutter/material.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/constants/values/app_theme.dart';
import '../../../core/localization/app_translation.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
          AppTranslation.translate(AppStrings.privacyPolicy),
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
              '1. Information We Collect',
              '1.1 Personal Information\n'
                  '• Name\n'
                  '• Phone Number\n'
                  '• Profile Photo (Optional)\n'
                  '• Email Address\n\n'
                  '1.2 Vehicle Information\n'
                  '• Vehicle Identification Number (VIN)\n'
                  '• License Plate Number\n'
                  '• Brand, Model, and Year\n'
                  '• Engine Type and Transmission\n'
                  '• Current and Historical Mileage\n'
                  '• Vehicle Photos (Optional)\n\n'
                  '1.3 Service History Data\n'
                  '• Bookings and appointments\n'
                  '• Service dates and types\n'
                  '• Maintenance schedules\n\n'
                  '1.4 Information We Do NOT Collect\n'
                  '• Location/GPS data\n'
                  '• Payment information\n'
                  '• Browsing history\n'
                  '• Biometric information',
              Icons.info_outline,
              AppColors.primaryBlack,
            ),
            _buildSection(
              '2. How We Use Your Information',
              'We use your information solely for:\n\n'
                  '• Creating and managing your account\n'
                  '• Registering and managing vehicles\n'
                  '• Facilitating service bookings\n'
                  '• Tracking service history\n'
                  '• Sending service reminders\n'
                  '• Responding to support requests\n'
                  '• Improving app features\n'
                  '• Fixing technical issues',
              Icons.settings_outlined,
              AppColors.primaryBlack,
            ),
            _buildSection(
              '3. How We Store Your Information',
              '3.1 API-Based Storage\n'
                  'We do not store data locally on your device. All information is:\n\n'
                  '• Stored securely on our servers\n'
                  '• Encrypted during transmission (HTTPS/TLS)\n'
                  '• Protected with industry-standard security\n'
                  '• Backed up regularly\n\n'
                  '3.2 Data Retention\n'
                  '• Active accounts: Data retained as long as account is active\n'
                  '• After deletion: Data deleted within 90 days',
              Icons.cloud_outlined,
              AppColors.primaryBlack,
            ),
            _buildHighlightBox(
              'We Do NOT Share Your Data',
              'Your personal information is never sold, rented, or shared with third parties for marketing purposes.',
              Icons.shield_outlined,
            ),
            const SizedBox(height: 24),
            _buildSection(
              '4. Data Sharing and Disclosure',
              '4.1 Service Providers\n'
                  'When you book an appointment, we share only necessary information:\n'
                  '• Your name and phone number\n'
                  '• Vehicle details\n'
                  '• Service history (if relevant)\n\n'
                  '4.2 Legal Requirements\n'
                  'We may disclose information if required to comply with legal obligations or protect our rights.',
              Icons.share_outlined,
              AppColors.primaryBlack,
            ),
            _buildSection(
              '5. Firebase Cloud Messaging',
              'We use Firebase Cloud Messaging to send:\n\n'
                  '• Service reminders\n'
                  '• Booking confirmations\n'
                  '• Maintenance notifications\n'
                  '• App updates\n\n'
                  'You may disable notifications in your device settings.\n\n'
                  'Note: We currently do not actively send push notifications, but the infrastructure is in place.',
              Icons.notifications_outlined,
              AppColors.primaryBlack,
            ),
            _buildDataRightsSection(),
            const SizedBox(height: 24),
            _buildSection(
              '7. Data Security',
              'We implement:\n\n'
                  'Technical Safeguards:\n'
                  '• Encryption of data in transit\n'
                  '• Secure API authentication\n'
                  '• Regular security audits\n'
                  '• Protection against unauthorized access\n\n'
                  'Your Responsibility:\n'
                  '• Keep login credentials confidential\n'
                  '• Use strong, unique passwords\n'
                  '• Log out on shared devices\n'
                  '• Report suspicious activity',
              Icons.security_outlined,
              AppColors.primaryBlack,
            ),
            _buildSection(
              '8. Children\'s Privacy',
              'While CarCat does not have a strict minimum age requirement (to allow registration of family vehicles), we do not knowingly collect information from children under 13 without parental consent.\n\n'
                  'If you are under 18:\n'
                  '• Use CarCat with parental guidance\n'
                  '• You may register vehicles on behalf of family members\n'
                  '• Parents/guardians are responsible for monitoring usage',
              Icons.family_restroom_outlined,
              AppColors.primaryBlack,
            ),
            _buildSection(
              '9. Third-Party Services',
              '9.1 Google ML Kit\n'
                  'We use Google ML Kit for VIN scanning. Processing happens on-device and scanned VIN data is not transmitted to Google.\n\n'
                  '9.2 Firebase Cloud Messaging\n'
                  'We use Firebase for push notifications. Firebase may collect device identifiers.\n\n'
                  '9.3 No Other Third Parties\n'
                  'We do not integrate with analytics, advertising, social media, or payment processors.',
              Icons.integration_instructions_outlined,
              AppColors.primaryBlack,
            ),
            _buildSection(
              '10. Changes to This Privacy Policy',
              'We may update this Privacy Policy from time to time. When we make changes:\n\n'
                  '• We will update the "Last Updated" date\n'
                  '• We will notify you through the app or email\n'
                  '• Continued use constitutes acceptance',
              Icons.update_outlined,
              AppColors.primaryBlack,
            ),
            _buildContactSection(),
            const SizedBox(height: 32),
            _buildConsentNotice(),
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
            Icons.calendar_today,
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
          'Your Privacy Matters',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Digital Innovation Agency LLC is committed to protecting your privacy. This Privacy Policy explains how we collect, use, store, and protect your personal information when you use CarCat.',
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
      String title,
      String content,
      IconData icon,
      Color iconColor,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightBox(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.successColor.withOpacity(0.1),
            AppColors.successColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.successColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.successColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.successColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRightsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlack.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlack.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.verified_user_outlined,
                  size: 24,
                  color: AppColors.primaryBlack,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '6. Your Data Rights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDataRight(
            Icons.visibility_outlined,
            'Access',
            'You can view all your information within the app at any time.',
          ),
          _buildDataRight(
            Icons.edit_outlined,
            'Correction',
            'You can edit or update your information directly in the app.',
          ),
          _buildDataRight(
            Icons.delete_outline,
            'Deletion',
            'Delete vehicles in-app or contact us for full account deletion within 90 days.',
          ),
          _buildDataRight(
            Icons.download_outlined,
            'Data Portability',
            'Request a copy of your data in machine-readable format.',
          ),
        ],
      ),
    );
  }

  Widget _buildDataRight(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
            color: AppColors.primaryBlack,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
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
            '11. Contact Us',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'If you have questions or requests regarding this Privacy Policy:',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactItem(Icons.business, 'Digital Innovation Agency LLC'),
          _buildContactItem(Icons.business, 'Rəqəmsal İnnovasiyalar Agentliyi'),
          _buildContactItem(Icons.email_outlined, 'digital.innovation.agency.aze@gmail.com'),
          _buildContactItem(Icons.language, 'https://digital-innovation.agency/'),
          _buildContactItem(Icons.location_on_outlined, 'Baku, Azerbaijan'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlack.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'We will respond to your inquiry within 30 days',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
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

  Widget _buildConsentNotice() {
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
              'By using CarCat, you acknowledge that you have read, understood, and agree to this Privacy Policy.',
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