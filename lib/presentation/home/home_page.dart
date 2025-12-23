import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/language/language_cubit.dart';
import '../../cubit/language/language_state.dart';
import 'widgets/home_body.dart';
import 'widgets/home_drawer_wrapper.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        return Scaffold(
          key: ValueKey(state.locale),
          backgroundColor: Colors.white,
          drawer: const HomeDrawerWrapper(),
          body: const SafeArea(child: HomeBody()),
        );
      },
    );
  }
}