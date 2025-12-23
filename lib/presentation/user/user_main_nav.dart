import 'package:carcat/core/constants/colors/app_colors.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:carcat/presentation/history/history_page.dart';
import 'package:carcat/presentation/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/texts/app_strings.dart';
import '../../cubit/navigation/user/user_nav_bar_cubit.dart';
import '../../cubit/navigation/user/user_nav_bar_state.dart';
import '../../home_page.dart';
import '../reservation/reservation_list_page.dart';

class UserMainNavigationPage extends StatelessWidget {
  const UserMainNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserNavBarCubit(),
      child: const UserMainNavigationView(),
    );
  }
}

class UserMainNavigationView extends StatelessWidget {
  const UserMainNavigationView({super.key});

  static const List<Widget> _pages = [
    HomePage(),
    HistoryPage(),
    ReservationListPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserNavBarCubit, UserNavBarState>(
      builder: (context, state) {
        final cubit = context.read<UserNavBarCubit>();

        return Scaffold(
          backgroundColor: AppColors.primaryWhite,
          body: IndexedStack(
            index: cubit.currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: Padding(
            // vertical: 30 yerine 'only' kullanarak üst boşluğu (top) kıstık
            padding: const EdgeInsets.only(left: 2, right: 2, top: 10, bottom: 30),
            child: Container(
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context: context,
                    index: 0,
                    currentIndex: cubit.currentIndex,
                    icon: 'assets/svg/home_nav_icon.svg',
                    activeIcon: 'assets/svg/home_nav_icon_active.svg',
                    label: context.currentLanguage(AppStrings.homePage),
                    onTap: () => cubit.changeTab(0),
                  ),
                  _buildNavItem(
                    context: context,
                    index: 1,
                    currentIndex: cubit.currentIndex,
                    icon: 'assets/svg/settings_nav_icon.svg',
                    activeIcon: 'assets/svg/settings_nav_active.svg',
                    label: context.currentLanguage(AppStrings.settingsPage),
                    onTap: () => cubit.changeTab(1),
                  ),
                  _buildNavItem(
                    context: context,
                    index: 2,
                    currentIndex: cubit.currentIndex,
                    icon: 'assets/svg/calendar_nav_icon.svg',
                    activeIcon: 'assets/svg/calendar_nav_icon_active.svg',
                    label: context.currentLanguage(AppStrings.bookingPage),
                    onTap: () => cubit.changeTab(2),
                  ),
                  _buildNavItem(
                    context: context,
                    index: 3,
                    currentIndex: cubit.currentIndex,
                    icon: 'assets/svg/user_nav_icon.svg',
                    activeIcon: 'assets/svg/user_nav_icon_active.svg',
                    label: context.currentLanguage(AppStrings.profilePage),
                    onTap: () => cubit.changeTab(3),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required String icon,
    required String activeIcon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isActive = index == currentIndex;

    final double iconOffset = (index == 1) ? 6.0 : 0.0;

    return Expanded(
      child: Tooltip(
        message: label,
        triggerMode: TooltipTriggerMode.longPress,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isActive ? Colors.black : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: iconOffset),
                  child: SvgPicture.asset(
                    isActive ? activeIcon : icon,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      isActive ? Colors.white : Colors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}