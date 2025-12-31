import 'package:carcat/presentation/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:carcat/core/constants/enums/enums.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:carcat/core/constants/texts/app_strings.dart';
import 'package:flutter_svg/svg.dart';
import '../../core/constants/colors/app_colors.dart';
import '../../data/remote/services/local/login_local_services.dart';
import '../../utils/di/locator.dart';
import '../../widgets/delete_account_widget.dart';
import '../../widgets/global_phone_input.dart';
import '../../widgets/profile_picture_widget.dart';
import '../auth/register/widgets/label_text_field.dart';
import '../auth/register/widgets/register_buttons.dart';

class ProfileEditPage extends HookWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final surnameController = useTextEditingController();
    final phoneController = useTextEditingController();
    final selectedCountryCode = useState(CountryCode.azerbaijan);
    final userName = useState('');
    final userSurname = useState('');
    useEffect(() {
      final local = locator<LoginLocalService>();
      userName.value = local.name ?? '';
      userSurname.value = local.surname ?? '';
      return null;
    }, const []);

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 22.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 64,
                              height: 64,
                              child: ProfilePictureWidget(isEdit: true),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                '${userName.value} ${userSurname.value}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: SvgPicture.asset(
                                'assets/svg/settings_navigation_ico.svg',
                                width: 21,
                                height: 21,
                                colorFilter: const ColorFilter.mode(
                                  Colors.black,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        NameField(
                          label: context.currentLanguage(AppStrings.nameLabel),
                          hintText: context.currentLanguage(AppStrings.nameHint),
                          controller: nameController,
                          validator: (_) => null,
                        ),
                        const SizedBox(height: 20),
                        NameField(
                          label: context.currentLanguage(AppStrings.surnameLabel),
                          hintText: context.currentLanguage(AppStrings.surnameHint),
                          controller: surnameController,
                          validator: (_) => null,
                        ),
                        const SizedBox(height: 20),
                        GlobalPhoneInput(
                          controller: phoneController,
                          selectedCountryCode: selectedCountryCode.value,
                          onCountryCodeChanged: (code) {
                            selectedCountryCode.value = code;
                          },
                          validator: (_) => null,
                        ),
                        const DeleteAccountWidget(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: PrimaryButton(
                  text: context.currentLanguage(AppStrings.saveChanges),
                  onPressed: () {
                    // TODO: Implement save logic
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}