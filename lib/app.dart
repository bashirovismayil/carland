import 'package:carland/utils/di/locator.dart';
import 'package:carland/utils/helper/app_localization.dart';
import 'package:carland/utils/helper/app_router.dart';
import 'package:carland/utils/helper/custom_multi_bloc_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/colors/app_colors.dart';
import 'cubit/language/language_cubit.dart';
import 'cubit/language/language_state.dart';
import 'data/remote/services/local/onboard_local_services.dart';
import 'data/remote/services/remote/auth_manager_services.dart';

class CarCatApp extends StatefulWidget {
  const CarCatApp({super.key});

  @override
  State<CarCatApp> createState() => _CarCatAppState();
}

class _CarCatAppState extends State<CarCatApp> {
  final _authManager = locator<AuthManagerService>();
  final _onboardService = locator<OnboardLocalService>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(_navigatorKey);
    _setupAuthListener();
    locator.registerSingleton<GlobalKey<NavigatorState>>(_navigatorKey);
  }

  void _setupAuthListener() {
    _authManager.authStateStream.listen((authState) {
      print(' - Auth state changed: $authState');
      _handleAuthStateChange(authState);
    });
  }

  void _handleAuthStateChange(AuthState authState) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _appRouter.navigateToAuthState(authState);
      }
    });
  }

  Widget _getInitialPage() {
    if (!_onboardService.isOnboardSeen) {
      return _appRouter.getOnboardPage();
    }
    return _appRouter.getPageForAuthState(_authManager.currentAuthState);
  }

  @override
  Widget build(BuildContext context) {
    return CustomMultiBlocProviderHelper(
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, languageState) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'CarCat',
            locale: languageState.locale,
            supportedLocales: const [
              Locale('az', 'AZ'),
              Locale('en', 'US'),
              Locale('ru', 'RU'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale != null) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale.languageCode) {
                    return supportedLocale;
                  }
                }
              }
              return supportedLocales.first;
            },

            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primaryGreen,
              ),
              useMaterial3: true,
            ),
            home: _getInitialPage(),
          );
        },
      ),
    );
  }
}