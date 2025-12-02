import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/navigation/user/patient_nav_bar_cubit.dart';
import '../../cubit/navigation/user/patient_nav_bar_state.dart';

class UserMainNavigationPage extends StatelessWidget {
  const UserMainNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => UserNavBarCubit(),
      child: UserMainNavigationView(),
    );
  }
}

class UserMainNavigationView extends StatelessWidget {
  UserMainNavigationView({super.key});

  final List<Widget> _pages = [
    // const UserHomeNavigation(),
    // AppointmentListPage(),
    // PatientAnalyzeListPage(),
    // const UserProfilePage(),
  ];

  List<BottomNavigationBarItem> _getNavItems(BuildContext context) {
    return [
    //   BottomNavigationBarItem(
    //     icon: const Icon(Icons.home_outlined),
    //     activeIcon: const Icon(Icons.home),
    //     label: context.currentLanguage(AppStrings.homePage),
    //   ),
    //   BottomNavigationBarItem(
    //     icon: const Icon(Icons.note_add_outlined),
    //     activeIcon: const Icon(Icons.note_add),
    //     label: context.currentLanguage(AppStrings.appointmentList),
    //   ),
    //   BottomNavigationBarItem(
    //     icon: const Icon(Icons.analytics_outlined),
    //     activeIcon: const Icon(Icons.analytics),
    //     label: context.currentLanguage(AppStrings.analyzes),
    //   ),
    //   BottomNavigationBarItem(
    //     icon: const Icon(Icons.person_add_outlined),
    //     activeIcon: const Icon(Icons.person_add),
    //     label: context.currentLanguage(AppStrings.profile),
    //   ),
     ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserNavBarCubit, UserNavBarState>(
      builder: (context, state) {
        final cubit = context.read<UserNavBarCubit>();

        return Scaffold(
          body: IndexedStack(
            index: cubit.currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: cubit.currentIndex,
              onTap: (index) => cubit.changeTab(index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF059669),
              unselectedItemColor: Colors.grey[600],
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 11,
              ),
              elevation: 0,
              items: _getNavItems(context),
            ),
          ),
        );
      },
    );
  }
}