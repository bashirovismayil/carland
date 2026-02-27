import 'package:carcat/core/constants/texts/app_strings.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../cubit/navigation/user/user_nav_bar_cubit.dart';
import '../../cubit/photo/profile/profile_photo_cubit.dart';
import '../../cubit/photo/profile/profile_photo_state.dart';
import '../../utils/di/locator.dart';
import '../presentation/settings/settings_page.dart';
import '../presentation/settings/support/support_page.dart';

class CustomDrawer extends StatefulWidget {
  final String userName;
  final String userSurname;
  final VoidCallback onLogout;

  const CustomDrawer({
    super.key,
    required this.userName,
    required this.userSurname,
    required this.onLogout,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late final ProfilePhotoCubit _cubit;
  @override
  void initState() {
    super.initState();
    _cubit = locator<ProfilePhotoCubit>();
    _cubit.getProfilePhoto();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.75,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      context.read<UserNavBarCubit>().goToSettingsPage();
                    },
                    child: BlocProvider.value(
                      value: _cubit,
                      child: BlocBuilder<ProfilePhotoCubit, ProfilePhotoState>(
                        builder: (context, state) {
                          ImageProvider? imageProvider;

                          if (state is ProfilePhotoLoaded) {
                            imageProvider = MemoryImage(state.imageData);
                          } else if (_cubit.cachedImage != null) {
                            imageProvider = MemoryImage(_cubit.cachedImage!);
                          }

                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black,
                                width: 2.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: imageProvider,
                              child: imageProvider == null
                                  ? FaIcon(
                                FontAwesomeIcons.user,
                                color: Colors.grey.shade600,
                                size: 32,
                              )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.black87,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<UserNavBarCubit>().goToSettingsPage();
                },
                child: Text(
                  ' ${widget.userName} ${widget.userSurname}',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 35),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SupportPage()),
                  );
                },
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/svg/bubble_chat.svg',
                      height: 26,
                    ),
                    const SizedBox(width: 12),
                     Text(
                      AppTranslation.translate(AppStrings.supportText),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/svg/drawer_settings.svg',
                      height: 26,
                    ),
                    const SizedBox(width: 12),
                     Text(
                      AppTranslation.translate(AppStrings.settings),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onLogout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                          'assets/svg/user_nav_icon.svg',
                          height: 22,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn)),
                      const SizedBox(width: 10),
                      Text(
                        AppTranslation.translate(AppStrings.logout),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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