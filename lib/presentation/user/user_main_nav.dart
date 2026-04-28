import 'package:carcat/core/constants/colors/app_colors.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:carcat/presentation/history/history_page.dart';
import 'package:carcat/presentation/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';
import '../../core/constants/texts/app_strings.dart';
import '../../cubit/navigation/user/user_nav_bar_cubit.dart';
import '../../cubit/navigation/user/user_nav_bar_state.dart';
import '../home/home_page.dart';
import '../reservation/reservation_list_page.dart';

const bool _kNativeNavBarEnabled = true;

final RouteObserver<ModalRoute<void>> navBarRouteObserver =
RouteObserver<ModalRoute<void>>();

/// Global key so that other pages (e.g. bottom-sheets in ReservationListPage)
/// can hide / show the native nav bar.
final GlobalKey<NativeGlassNavBarState> globalNavBarKey = GlobalKey();

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

class UserMainNavigationView extends StatefulWidget {
  const UserMainNavigationView({super.key});

  @override
  State<UserMainNavigationView> createState() => _UserMainNavigationViewState();
}

class _UserMainNavigationViewState extends State<UserMainNavigationView>
    with RouteAware {
  static const List<Widget> _pages = [
    HomePage(),
    HistoryPage(),
    ReservationListPage(),
    SettingsPage(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      navBarRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    navBarRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    if (_kNativeNavBarEnabled) {
      globalNavBarKey.currentState?.hide();
    }
  }

  @override
  void didPopNext() {
    if (_kNativeNavBarEnabled) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          globalNavBarKey.currentState?.show();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserNavBarCubit, UserNavBarState>(
      builder: (context, state) {
        final cubit = context.read<UserNavBarCubit>();
        final bottomPadding = MediaQuery.of(context).padding.bottom;

        return Scaffold(
          backgroundColor: AppColors.primaryWhite,
          body: IndexedStack(
            index: cubit.currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: _kNativeNavBarEnabled
              ? NativeGlassNavBar(
            key: globalNavBarKey,
            currentIndex: cubit.currentIndex,
            onTap: (index) => cubit.changeTab(index),
            tabs: [
              NativeGlassNavBarItem(
                  label: context.currentLanguage(AppStrings.homePage),
                  symbol: 'home_nav_icon'),
              NativeGlassNavBarItem(
                  label: context.currentLanguage(AppStrings.settingsPage),
                  symbol: 'settings_nav_icon'),
              NativeGlassNavBarItem(
                  label: context.currentLanguage(AppStrings.bookingPage),
                  symbol: 'calendar_nav_icon'),
              NativeGlassNavBarItem(
                  label: context.currentLanguage(AppStrings.profilePage),
                  symbol: 'user_nav_icon'),
            ],
            fallback:
            _buildOriginalNavBar(context, cubit, bottomPadding),
          )
              : _buildOriginalNavBar(context, cubit, bottomPadding),
        );
      },
    );
  }

  Widget _buildOriginalNavBar(
      BuildContext context,
      UserNavBarCubit cubit,
      double bottomPadding,
      ) {
    return Container(
      padding: EdgeInsets.only(
        left: 2,
        right: 2,
        top: 10,
        bottom: bottomPadding > 0 ? bottomPadding : 15,
      ),
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
    final double iconOffset = (index == 1) ? 5.0 : 0.0;

    return Expanded(
      child: Tooltip(
        message: label,
        triggerMode: TooltipTriggerMode.longPress,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.black : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(left: iconOffset),
                      child: SvgPicture.asset(
                        isActive ? activeIcon : icon,
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          isActive ? Colors.white : Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.1,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? Colors.black : Colors.grey,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}