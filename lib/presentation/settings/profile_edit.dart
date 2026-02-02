import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:carcat/core/constants/enums/enums.dart';
// import 'package:carcat/core/localization/app_translation.dart';
// import 'package:carcat/core/constants/texts/app_strings.dart';
// import 'package:flutter_svg/svg.dart';
import '../../core/constants/colors/app_colors.dart';
import '../../data/remote/services/local/login_local_services.dart';
import '../../utils/di/locator.dart';
import '../../widgets/delete_account_widget.dart';
// import '../../widgets/global_phone_input.dart';
import '../../widgets/profile_picture_widget.dart';
// import '../auth/register/widgets/label_text_field.dart';
// import '../auth/register/widgets/register_buttons.dart';

class ProfileEditPage extends HookWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final nameController = useTextEditingController();
    // final surnameController = useTextEditingController();
    // final phoneController = useTextEditingController();
    // final selectedCountryCode = useState(CountryCode.azerbaijan);
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
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Center(
                      child: SizedBox(
                        width: 135,
                        height: 135,
                        child: ProfilePictureWidget(isEdit: true),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '${userName.value} ${userSurname.value}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    const DeleteAccountWidget(),

                    // ============================================
                    // COMMENTED OUT - Name/Surname/Phone Fields
                    // ============================================
                    // NameField(
                    //   label: context.currentLanguage(AppStrings.nameLabel),
                    //   hintText: context.currentLanguage(AppStrings.nameHint),
                    //   controller: nameController,
                    //   validator: (_) => null,
                    // ),
                    // const SizedBox(height: 20),
                    // NameField(
                    //   label: context.currentLanguage(AppStrings.surnameLabel),
                    //   hintText: context.currentLanguage(AppStrings.surnameHint),
                    //   controller: surnameController,
                    //   validator: (_) => null,
                    // ),
                    // const SizedBox(height: 20),
                    // GlobalPhoneInput(
                    //   controller: phoneController,
                    //   selectedCountryCode: selectedCountryCode.value,
                    //   onCountryCodeChanged: (code) {
                    //     selectedCountryCode.value = code;
                    //   },
                    //   validator: (_) => null,
                    // ),
                  ],
                ),
              ),
            ),

            // ============================================
            // COMMENTED OUT - Save Button
            // ============================================
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            //   child: PrimaryButton(
            //     text: context.currentLanguage(AppStrings.saveChanges),
            //     onPressed: () {
            //       // TODO: Implement save logic
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}