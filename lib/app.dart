import 'package:carcat/utils/di/locator.dart';
import 'package:carcat/utils/helper/app_localization.dart';
import 'package:carcat/utils/helper/app_router.dart';
import 'package:carcat/utils/helper/custom_multi_bloc_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/colors/app_colors.dart';
import 'cubit/language/language_cubit.dart';
import 'cubit/language/language_state.dart';
import 'data/remote/services/local/onboard_local_services.dart';
import 'data/remote/services/local/login_local_services.dart';
import 'data/remote/services/remote/auth_manager_services.dart';

class CarCatApp extends StatefulWidget {
  const CarCatApp({super.key});

  @override
  State<CarCatApp> createState() => _CarCatAppState();
}

class _CarCatAppState extends State<CarCatApp> {
  final _authManager = locator<AuthManagerService>();
  final _onboardService = locator<OnboardLocalService>();
  final _loginLocalService = locator<LoginLocalService>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AppRouter _appRouter;
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(_navigatorKey);
    locator.registerSingleton<GlobalKey<NavigatorState>>(_navigatorKey);
    _initializationFuture = _initializeDependencies();
  }

  Future<void> _initializeDependencies() async {
    await _checkRememberMeOnStartup();
    _setupAuthListener();
  }

  Future<void> _checkRememberMeOnStartup() async {
    print("🚀 App achildi - 'remember me check edilir...");
    await _loginLocalService.checkRememberMeOnStartup();
    print("✅ remember me tamamlandı.");
  }

  void _setupAuthListener() {
    _authManager.authStateStream.listen((authState) {
      print('📡 AuthState deyişdi: $authState');
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
      print("📖 Onboarding görülmeyib - Onboarding page-e gedir");
      return _appRouter.getOnboardPage();
    }

    final authState = _authManager.currentAuthState;
    print("🔍 Mövcud state: $authState");
    return _appRouter.getPageForAuthState(authState);
  }

  @override
  Widget build(BuildContext context) {
    return CustomMultiBlocProviderHelper(
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, languageState) {
          return FutureBuilder(
            future: _initializationFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlack,
                      ),
                    ),
                  ),
                );
              }

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
                localizationsDelegates: [
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
                    seedColor: AppColors.primaryBlack,
                  ),
                  textTheme: GoogleFonts.poppinsTextTheme(
                    Theme.of(context).textTheme,
                  ),
                  useMaterial3: true,
                ),
                home: _getInitialPage(),
              );
            },
          );
        },
      ),
    );
  }
}