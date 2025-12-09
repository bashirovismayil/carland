import 'package:carcat/presentation/vin/add_your_car_vin_screen.dart';
import 'package:carcat/utils/helper/go.dart';
import 'package:carcat/widgets/custom_button.dart';
import 'package:carcat/widgets/profile_photo.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'core/constants/colors/app_colors.dart';
import 'core/constants/texts/app_strings.dart';
import 'core/localization/app_translation.dart';
import 'utils/di/locator.dart';
import 'data/remote/services/local/login_local_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _local = locator<LoginLocalService>();
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() {
    final name = _local.name;
    if (name != null && name.isNotEmpty) {
      setState(() {
        _userName = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ProfilePhoto(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppTranslation.translate(
                                  AppStrings.homeHelloText),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              _userName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '👋',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        Text(
                          AppTranslation.translate(
                              AppStrings.bookYourCarServices),
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Empty State
              Expanded(
                child: EmptyWidget(
                  title: AppTranslation.translate(AppStrings.noCarsAddedYet),
                  subtitle: AppTranslation.translate(
                      AppStrings.noCarsAddedDescription),
                ),
              ),

              const SizedBox(height: 10),
              CustomElevatedButton(
                onPressed: () {
                  Go.to(context, AddYourCarVinPage());
                },
                width: double.infinity,
                height: 60,
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                borderRadius: BorderRadius.circular(30),
                elevation: 0,
                icon: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 15,
                  ),
                ),
                iconPadding: const EdgeInsets.only(right: 12),
                child: Text(
                  AppTranslation.translate(AppStrings.addCarButton),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const EmptyWidget({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),

        // Lottie Animation
        SizedBox(
          width: 200,
          height: 200,
          child: Lottie.asset(
            'assets/lottie/no_result_animation.json',
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 32),

        // Title
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const Spacer(),
      ],
    );
  }
}