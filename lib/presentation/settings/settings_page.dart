import 'package:carcat/presentation/terms_and_privacy/privacy_policy.dart';
import 'package:carcat/utils/helper/go.dart';
import 'package:carcat/widgets/profile_picture_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/logout_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                width: 41,
                height: 41,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    size: 15,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 41,
                  height: 41,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 62,
                      height: 62,
                      child: ProfilePictureWidget(isEdit: false,),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Martin D'Souza",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/svg/settings_edit.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            ),

            // General Section
            _buildSectionHeader('General'),
            _buildSectionContainer(
              children: [
                _buildSettingsTile(
                  svgPath: 'assets/svg/settings_language.svg',
                  title: 'Language',
                  subtitle: 'Change App Language',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingsTile(
                  svgPath: 'assets/svg/settings_pass_ico.svg',
                  title: 'Password',
                  subtitle: 'Set App Password',
                  onTap: () {},
                ),
              ],
            ),

            // Feedback Section
            _buildSectionHeader('Feedback'),
            _buildSectionContainer(
              children: [
                _buildSettingsTile(
                  svgPath: 'assets/svg/settings_feedback.svg',
                  title: 'App Feedback',
                  subtitle: 'Add feedback about app',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingsTile(
                  svgPath: 'assets/svg/settings_bug_report.svg',
                  title: 'Bug Report',
                  subtitle: 'Report any kind of bug or Error',
                  onTap: () {},
                ),
              ],
            ),

            // Legals Section
            _buildSectionHeader('Legals'),
            _buildSectionContainer(
              children: [
                _buildSettingsTile(
                  svgPath: 'assets/svg/settings_privacy.svg',
                  title: 'Privacy Policy',
                  subtitle: 'Set your Privacy',
                  onTap: () {
                    Go.to(context, PrivacyPolicyPage());
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  svgPath: 'assets/svg/settings_logout.svg',
                  title: 'Logout',
                  subtitle: null,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const LogoutDialog(),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.shade100,
      ),
    );
  }

  Widget _buildSettingsTile({
    required String svgPath,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SvgPicture.asset(
              svgPath,
              width: 43,
              height: 43,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}