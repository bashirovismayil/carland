import '../../core/constants/texts/app_strings.dart';

class Translations {
  static final Map<String, Map<String, String>> translations = {
    'az': {
      AppStrings.countryAzerbaijan: 'Azərbaycan',
      AppStrings.countryTurkey: 'Türkiyə',
      AppStrings.countryRussia: 'Rusiya',
      AppStrings.countryGeorgia: 'Gürcüstan',
      AppStrings.countryKazakhstan: 'Qazaxıstan',

      AppStrings.skipButtonText: 'Keç',
      AppStrings.letsGetStartedText: 'Başlayaq!',

      // Language Selection
      AppStrings.selectLanguageToContinue: 'Davam edəcəyiniz dili seçin',
      AppStrings.useAppInYourLanguage:
          'Tətbiqi istədiyiniz dildə istifadə edin',
      AppStrings.closeButton: 'Bağla',
      AppStrings.exitButton: 'Çıxış',
      AppStrings.admin: 'Admin',
      AppStrings.superAdmin: 'Super Admin',

      // Onboarding
      AppStrings.onboardTitle_1: 'Avtomobiliniz – Bizim prioritetimiz',
      AppStrings.onboardSubtext_1:
          'Geniş avtoservis xidmətlərinə çıxış əldə edin və avtomobilinizin qayğısını bizə həvalə edin',
      AppStrings.onboardTitle_2: 'Servis randevusu və idarəetmə',
      AppStrings.onboardSubtext_2:
          'Ustalarla randevu təyin edin,\nmövcudluğu görün və xatırlatmalar alın',
      AppStrings.onboardTitle_3: 'Servis tarixçənizi izləyin',
      AppStrings.onboardSubtext_3:
          'Təmir qeydləri, texniki baxış tarixçəsi\nvə ehtiyat hissələrinə bir yerdən baxın',

      // Welcome Page
      AppStrings.welcomeToCarCat: 'CarCat\'a xoş gəlmisiniz',
      AppStrings.welcomeSubtitle:
          'Problemsiz avtomobil texniki baxımı üçün ağıllı köməkçiniz. İzləyin, planlaşdırın və xidmətləri bir tətbiqdən sifariş edin.',
      AppStrings.loginButton: 'Daxil ol',
      AppStrings.signUpButton: 'Qeydiyyat',

      // Login Page
      AppStrings.loginIntoYourAccount: 'Hesabınıza daxil olun',
      AppStrings.phoneLabel: 'Telefon',
      AppStrings.passwordLabel: 'Şifrə',
      AppStrings.forgotPassword: 'Şifrəni unutdunuz?',
      AppStrings.rememberMe: 'Məni xatırla',
      AppStrings.dontHaveAccount: 'Hesabınız yoxdur?',

// Validation Messages
      AppStrings.phoneRequired: 'Telefon nömrəsi daxil edin',
      AppStrings.phoneInvalidLength: 'Telefon nömrəsi 9 rəqəm olmalıdır',
      AppStrings.phoneInvalid: 'Telefon nömrəsi düzgün deyil',
      AppStrings.phoneInvalidOperator: 'Yanlış operator kodu',
      AppStrings.passwordRequired: 'Şifrə daxil edin',
      AppStrings.passwordTooShort: 'Şifrə ən azı 6 simvol olmalıdır',

      // Register Page
      AppStrings.createAnAccount: 'Hesab yaradın',
      AppStrings.nameLabel: 'Ad',
      AppStrings.nameHint: 'Adınızı daxil edin',
      AppStrings.surnameLabel: 'Soyad',
      AppStrings.surnameHint: 'Soyadınızı daxil edin',
      AppStrings.countryCodeLabel: 'Ölkə kodu',
      AppStrings.phoneNumberLabel: 'Telefon nömrəsi',
      AppStrings.selectCountryCode: 'Ölkə kodu seçin',
      AppStrings.nextButton: 'Növbəti',
      AppStrings.alreadyHaveAccount: 'Artıq hesabınız var?',
      AppStrings.signInButton: 'Daxil ol',

// Terms & Privacy
      AppStrings.iAgreeToThe: 'Razıyam: ',
      AppStrings.termsOfService: 'Xidmət şərtləri',
      AppStrings.privacyPolicy: 'Məxfilik siyasəti',
      AppStrings.pleaseAcceptTerms: 'Zəhmət olmasa şərtləri qəbul edin',

// Validation Messages - Name
      AppStrings.nameRequired: 'Ad daxil edin',
      AppStrings.nameTooShort: 'Ad ən azı 2 simvol olmalıdır',
      AppStrings.nameInvalid: 'Ad yalnız hərflərdən ibarət olmalıdır',

// Validation Messages - Surname
      AppStrings.surnameRequired: 'Soyad daxil edin',
      AppStrings.surnameTooShort: 'Soyad ən azı 2 simvol olmalıdır',
      AppStrings.surnameInvalid: 'Soyad yalnız hərflərdən ibarət olmalıdır',

// Error Messages
      AppStrings.userAlreadyExists: 'Bu istifadəçi artıq mövcuddur',

      // OTP Confirmation Dialog
      AppStrings.sendOtpTo: 'OTP Göndər',
      AppStrings.sendOtpDescription:
          '4 rəqəmli OTP kodu telefon\nnömrəsinə göndərin',

      // OTP Page
      AppStrings.otpVerification: 'OTP Doğrulama',
      AppStrings.otpSubtitle:
          'Təqdim etdiyiniz telefon nömrəsinə doğrulama kodu göndərildi',
      AppStrings.secLeft: 'san qaldı',
      AppStrings.didntReceiveCode: 'Kod almadınız?',
      AppStrings.resendCode: 'Yenidən göndər',
      AppStrings.backButton: 'Geri',

// OTP Validation & Errors
      AppStrings.enterCompleteOtp: 'Zəhmət olmasa 4 rəqəmli kodu daxil edin',
      AppStrings.wrongOtpCode: 'Yanlış kod',
      AppStrings.waitBeforeResend: 'Yenidən göndərmək üçün gözləyin',
      AppStrings.otpResent: 'Kod yenidən göndərildi',
      AppStrings.invalidPhoneNumber: 'Etibarsız telefon nömrəsi',
      AppStrings.errorOccurred: 'Xəta baş verdi',

      // Setup Password Page
      AppStrings.createPassword: 'Şifrə Yarat',
      AppStrings.enterNewPassword: 'Yeni Şifrə Daxil Edin',
      AppStrings.confirmNewPassword: 'Yeni Şifrəni Təsdiq Edin',
      AppStrings.registerButton: 'Qeydiyyat',

      AppStrings.setupPasswordText: 'Şifrə qurulması',
      AppStrings.setupPasswordHintText: 'Şifrənizi daxil edin',
      AppStrings.confirmPassword: 'Şifrəni təsdiqlə',
      AppStrings.confirmPasswordHint: 'Şifrəni yenidən daxil edin',
      AppStrings.continueButtonText: 'Davam et',
      AppStrings.passCannotEmptyText: 'Şifrə boş ola bilməz',
      AppStrings.passwordRulesText: 'Şifrə tələbləri',
      AppStrings.passwordsDoNotMatch: 'Şifrələr uyğun deyil',

      // Password Requirements
      AppStrings.capitalLetterRequired: 'Böyük hərf əlavə edilməlidir',
      AppStrings.lowercaseLetterRequired: 'Kiçik hərf əlavə edilməlidir',
      AppStrings.numberRequired: 'Rəqəm əlavə edilməlidir',
      AppStrings.specialCharRequired: 'Xüsusi simvol əlavə edilməlidir',
      AppStrings.passwordsMustMatch: 'Şifrələr eyni olmalıdır',
      AppStrings.forgotPasswordPageHeader: 'Şifrəni unutmusunuz',
      AppStrings.passwordResetSuccess: 'Şifrə uğurla yeniləndi',
      AppStrings.autoLoginFailed:
          'Avtomatik giriş uğursuz oldu. Zəhmət olmasa giriş səhifəsi ilə daxil olun',

      // LoginService Messages
      AppStrings.unknownInternalError: 'Bilinməyən daxili xəta',
      AppStrings.badRequest: 'Səhv sorğu',
      AppStrings.invalidCredentials: 'İstifadəçi adı və ya şifrə yanlışdır',
      AppStrings.forbidden: 'Girişə icazə verilməyib',
      AppStrings.userNotFound: 'İstifadəçi tapılmadı',
      AppStrings.invalidData: 'Məlumatlar düzgün deyil',
      AppStrings.serverError: 'Server xətası: Zəhmət olmasa yenidən cəhd edin',
      AppStrings.serviceUnavailable: 'Servis müvəqqəti əlçatan deyil',
      AppStrings.serviceDown: 'Xidmət əlçatan deyil: Servislər hazırda işləmir',
      AppStrings.timeoutError: 'Sorğu vaxtı bitdi',
      AppStrings.requestCancelled: 'Sorğu ləğv edildi',
      AppStrings.noInternet: 'İnternet yoxdur, şəbəkənizi yoxlayın və yenidən cəhd edin',
      AppStrings.badCertificate: 'Təhlükəsizlik sertifikatı xətası',
      AppStrings.networkError: 'Şəbəkə xətası baş verdi',
      AppStrings.loginFailed: 'Giriş uğursuz oldu',

      AppStrings.registrationSuccessful: 'Qeydiyyat Uğurludur',
      AppStrings.passwordResetSuccessful: 'Şifrə Sıfırlama Uğurlu',
      AppStrings.carAdded: 'Avtomobil Əlavə Edildi',

      AppStrings.registrationSuccessSubtext:
      'Hesabınız uğurla yaradıldı. İndi daxil olaraq avtomobilinizin texniki xidmətini asanlıqla idarə edə bilərsiniz.',
      AppStrings.passwordResetSuccessSubtext:
      'Hesabınız uğurla yaradıldı. İndi daxil olaraq avtomobilinizin texniki xidmətini asanlıqla idarə edə bilərsiniz.',
      AppStrings.carAddedSubtext:
      'Yeni Kart Əlavə Edildi BMW M4 Sports 2024',

      AppStrings.gotIt: 'Anladım',
      AppStrings.checkMyCars: 'Avtomobillərimə Bax',
      AppStrings.newCarAdded: 'Yeni Kart Əlavə Edildi',

    },
    'en': {
      AppStrings.countryAzerbaijan: 'Azerbaijan',
      AppStrings.countryTurkey: 'Turkey',
      AppStrings.countryRussia: 'Russia',
      AppStrings.countryGeorgia: 'Georgia',
      AppStrings.countryKazakhstan: 'Kazakhstan',

      AppStrings.skipButtonText: 'Skip',
      AppStrings.letsGetStartedText: "Let's Get Started!",

      // Language Selection
      AppStrings.selectLanguageToContinue: 'Select language to continue',
      AppStrings.useAppInYourLanguage: 'Use the app in your preferred language',
      AppStrings.closeButton: 'Close',
      AppStrings.exitButton: 'Exit',
      AppStrings.admin: 'Admin',
      AppStrings.superAdmin: 'Super Admin',

      // Onboarding
      AppStrings.onboardTitle_1: 'Your car – Our priority',
      AppStrings.onboardSubtext_1:
          'Get access to wide range of auto services\nand leave your car care to us',
      AppStrings.onboardTitle_2: 'Service appointments & management',
      AppStrings.onboardSubtext_2:
          'Schedule appointments with mechanics,\ncheck availability and get reminders',
      AppStrings.onboardTitle_3: 'Track your service history',
      AppStrings.onboardSubtext_3:
          'View repair records, maintenance history\nand spare parts in one place',

      // Welcome Page
      AppStrings.welcomeToCarCat: 'Welcome to CarCat',
      AppStrings.welcomeSubtitle:
          'Your smart companion for hassle-free car maintenance. Track, schedule, and book services all in one place.',
      AppStrings.loginButton: 'Login',
      AppStrings.signUpButton: 'Sign up',

      // Login Page
      AppStrings.loginIntoYourAccount: 'Login into your account',
      AppStrings.phoneLabel: 'Phone',
      AppStrings.passwordLabel: 'Password',
      AppStrings.forgotPassword: 'Forgot Password?',
      AppStrings.forgotPasswordPageHeader: 'Forgot Password',
      AppStrings.rememberMe: 'Remember me',
      AppStrings.dontHaveAccount: "Don't have an account?",

// Validation Messages
      AppStrings.phoneRequired: 'Please enter phone number',
      AppStrings.phoneInvalidLength: 'Phone number must be 9 digits',
      AppStrings.phoneInvalid: 'Invalid phone number',
      AppStrings.phoneInvalidOperator: 'Invalid operator code',
      AppStrings.passwordRequired: 'Please enter password',
      AppStrings.passwordTooShort: 'Password must be at least 6 characters',

      // Register Page
      AppStrings.createAnAccount: 'Create An Account',
      AppStrings.nameLabel: 'Name',
      AppStrings.nameHint: 'Enter your name',
      AppStrings.surnameLabel: 'Surname',
      AppStrings.surnameHint: 'Enter your surname',
      AppStrings.countryCodeLabel: 'Country Code',
      AppStrings.phoneNumberLabel: 'Phone Number',
      AppStrings.selectCountryCode: 'Select country code',
      AppStrings.nextButton: 'Next',
      AppStrings.alreadyHaveAccount: 'Already have an account?',
      AppStrings.signInButton: 'Sign in',

// Terms & Privacy
      AppStrings.iAgreeToThe: 'I agree to ',
      AppStrings.termsOfService: 'Terms of Service',
      AppStrings.privacyPolicy: 'Privacy Policy',
      AppStrings.pleaseAcceptTerms: 'Please accept terms and conditions',

// Validation Messages - Name
      AppStrings.nameRequired: 'Please enter your name',
      AppStrings.nameTooShort: 'Name must be at least 2 characters',
      AppStrings.nameInvalid: 'Name must contain only letters',

// Validation Messages - Surname
      AppStrings.surnameRequired: 'Please enter your surname',
      AppStrings.surnameTooShort: 'Surname must be at least 2 characters',
      AppStrings.surnameInvalid: 'Surname must contain only letters',

// Error Messages
      AppStrings.userAlreadyExists: 'This user already exists',

      // OTP Confirmation Dialog
      AppStrings.sendOtpTo: 'Send OTP To',
      AppStrings.sendOtpDescription:
          'Send an 4 - digits OTP code\nto phone number',

      // OTP Page
      AppStrings.otpVerification: 'OTP Verification',
      AppStrings.otpSubtitle:
          'An authorization code has been sent to your provided Phone Number',
      AppStrings.secLeft: 'sec left',
      AppStrings.didntReceiveCode: "I don't receive code",
      AppStrings.resendCode: 'Resend Code',
      AppStrings.backButton: 'Back',

// OTP Validation & Errors
      AppStrings.enterCompleteOtp: 'Please enter the complete 4-digit code',
      AppStrings.wrongOtpCode: 'Wrong code',
      AppStrings.waitBeforeResend: 'Please wait before resending',
      AppStrings.otpResent: 'Code resent successfully',
      AppStrings.invalidPhoneNumber: 'Invalid phone number',
      AppStrings.errorOccurred: 'An error occurred',

      // Setup Password Page
      AppStrings.createPassword: 'Create Password',
      AppStrings.enterNewPassword: 'Enter New Password',
      AppStrings.confirmNewPassword: 'Confirm New Password',
      AppStrings.registerButton: 'Register',

      AppStrings.setupPasswordText: 'Set Up Password',
      AppStrings.setupPasswordHintText: 'Enter your password',
      AppStrings.confirmPassword: 'Confirm Password',
      AppStrings.confirmPasswordHint: 'Re-enter your password',
      AppStrings.continueButtonText: 'Continue',
      AppStrings.passCannotEmptyText: 'Password cannot be empty',
      AppStrings.passwordRulesText: 'Password Rules',
      AppStrings.passwordsDoNotMatch: 'Passwords do not match',

      // Password Requirements
      AppStrings.capitalLetterRequired: 'The capital letter is not added yet',
      AppStrings.lowercaseLetterRequired:
          'The lowercase letter is not added yet',
      AppStrings.numberRequired: 'The number is not added yet',
      AppStrings.specialCharRequired: 'The special character is not added yet',
      AppStrings.passwordsMustMatch: 'Both Password should be match (same)',
      AppStrings.passwordResetSuccess: 'Password reset successful',
      AppStrings.autoLoginFailed:
          'Automatic login failed. Please login manually',

      // LoginService Messages
      AppStrings.unknownInternalError: 'Unknown internal error',
      AppStrings.badRequest: 'Bad request',
      AppStrings.invalidCredentials: 'Invalid username or password',
      AppStrings.forbidden: 'Access forbidden',
      AppStrings.userNotFound: 'User not found',
      AppStrings.invalidData: 'Invalid data',
      AppStrings.serverError: 'Server error: Please try again',
      AppStrings.serviceUnavailable: 'Service temporarily unavailable',
      AppStrings.serviceDown: 'Service unavailable: Services are currently down',
      AppStrings.timeoutError: 'Request timed out',
      AppStrings.requestCancelled: 'Request cancelled',
      AppStrings.noInternet: 'No internet, please check your connection and try again',
      AppStrings.badCertificate: 'Security certificate error',
      AppStrings.networkError: 'Network error occurred',
      AppStrings.loginFailed: 'Login failed',

      AppStrings.registrationSuccessful: 'Registration Successful',
      AppStrings.passwordResetSuccessful: 'Password Reset Successful',
      AppStrings.carAdded: 'Car Added',

      AppStrings.registrationSuccessSubtext:
      'Your account has been created successfully. You can now log in and start managing your car\'s maintenance with ease.',
      AppStrings.passwordResetSuccessSubtext:
      'Your account has been created successfully. You can now log in and start managing your car\'s maintenance with ease.',
      AppStrings.carAddedSubtext:
      'New Card Added BMW M4 Sports 2024',

      AppStrings.gotIt: 'Got It',
      AppStrings.checkMyCars: 'Check My Cars',
      AppStrings.newCarAdded: 'New Card Added',

    },
    'ru': {
      AppStrings.countryAzerbaijan: 'Азербайджан',
      AppStrings.countryTurkey: 'Турция',
      AppStrings.countryRussia: 'Россия',
      AppStrings.countryGeorgia: 'Грузия',
      AppStrings.countryKazakhstan: 'Казахстан',

      AppStrings.skipButtonText: 'Пропустить',
      AppStrings.letsGetStartedText: 'Давайте начнем!',

      // Language Selection
      AppStrings.selectLanguageToContinue: 'Выберите язык для продолжения',
      AppStrings.useAppInYourLanguage:
          'Используйте приложение на удобном языке',
      AppStrings.closeButton: 'Закрыть',
      AppStrings.exitButton: 'Выход',
      AppStrings.admin: 'Админ',
      AppStrings.superAdmin: 'Супер Админ',

      // Onboarding
      AppStrings.onboardTitle_1: 'Ваш автомобиль – Наш приоритет',
      AppStrings.onboardSubtext_1:
          'Получите доступ к широкому спектру автосервисов\nи доверьте заботу о машине нам',
      AppStrings.onboardTitle_2: 'Запись на сервис и управление',
      AppStrings.onboardSubtext_2:
          'Назначайте встречи с мастерами,\nпроверяйте доступность и получайте напоминания',
      AppStrings.onboardTitle_3: 'Отслеживайте историю обслуживания',
      AppStrings.onboardSubtext_3:
          'Просматривайте записи ремонта, историю ТО\nи запчасти в одном месте',

      // Welcome Page
      AppStrings.welcomeToCarCat: 'Добро пожаловать в CarCat',
      AppStrings.welcomeSubtitle:
          'Ваш умный помощник для беспроблемного обслуживания автомобиля. Отслеживайте, планируйте и бронируйте услуги в одном месте.',
      AppStrings.loginButton: 'Войти',
      AppStrings.signUpButton: 'Регистрация',

      // Login Page
      AppStrings.loginIntoYourAccount: 'Войдите в аккаунт',
      AppStrings.phoneLabel: 'Телефон',
      AppStrings.passwordLabel: 'Пароль',
      AppStrings.forgotPassword: 'Забыли пароль?',
      AppStrings.rememberMe: 'Запомнить меня',
      AppStrings.dontHaveAccount: 'Нет аккаунта?',

// Validation Messages
      AppStrings.phoneRequired: 'Введите номер телефона',
      AppStrings.phoneInvalidLength: 'Номер телефона должен содержать 9 цифр',
      AppStrings.phoneInvalid: 'Неверный номер телефона',
      AppStrings.phoneInvalidOperator: 'Неверный код оператора',
      AppStrings.passwordRequired: 'Введите пароль',
      AppStrings.passwordTooShort: 'Пароль должен быть не менее 6 символов',

      // Register Page
      AppStrings.createAnAccount: 'Создать аккаунт',
      AppStrings.nameLabel: 'Имя',
      AppStrings.nameHint: 'Введите ваше имя',
      AppStrings.surnameLabel: 'Фамилия',
      AppStrings.surnameHint: 'Введите вашу фамилию',
      AppStrings.countryCodeLabel: 'Код страны',
      AppStrings.phoneNumberLabel: 'Номер телефона',
      AppStrings.selectCountryCode: 'Выберите код страны',
      AppStrings.nextButton: 'Далее',
      AppStrings.alreadyHaveAccount: 'Уже есть аккаунт?',
      AppStrings.signInButton: 'Войти',

// Terms & Privacy
      AppStrings.iAgreeToThe: 'Я принимаю ',
      AppStrings.termsOfService: 'Условия использования',
      AppStrings.privacyPolicy: 'Политика конфиденциальности',
      AppStrings.pleaseAcceptTerms: 'Пожалуйста, примите условия',

// Validation Messages - Name
      AppStrings.nameRequired: 'Введите имя',
      AppStrings.nameTooShort: 'Имя должно содержать минимум 2 символа',
      AppStrings.nameInvalid: 'Имя должно содержать только буквы',

// Validation Messages - Surname
      AppStrings.surnameRequired: 'Введите фамилию',
      AppStrings.surnameTooShort: 'Фамилия должна содержать минимум 2 символа',
      AppStrings.surnameInvalid: 'Фамилия должна содержать только буквы',

// Error Messages
      AppStrings.userAlreadyExists: 'Этот пользователь уже существует',

      // OTP Confirmation Dialog
      AppStrings.sendOtpTo: 'Отправить OTP',
      AppStrings.sendOtpDescription:
          'Отправить 4-значный OTP код\nна номер телефона',

      // OTP Page
      AppStrings.otpVerification: 'OTP Верификация',
      AppStrings.otpSubtitle:
          'Код подтверждения был отправлен на указанный номер телефона',
      AppStrings.secLeft: 'сек осталось',
      AppStrings.didntReceiveCode: 'Не получили код?',
      AppStrings.resendCode: 'Отправить повторно',
      AppStrings.backButton: 'Назад',

// OTP Validation & Errors
      AppStrings.enterCompleteOtp: 'Пожалуйста, введите 4-значный код',
      AppStrings.wrongOtpCode: 'Неверный код',
      AppStrings.waitBeforeResend: 'Подождите перед повторной отправкой',
      AppStrings.otpResent: 'Код отправлен повторно',
      AppStrings.invalidPhoneNumber: 'Неверный номер телефона',
      AppStrings.errorOccurred: 'Произошла ошибка',

      // Setup Password Page
      AppStrings.createPassword: 'Создать Пароль',
      AppStrings.enterNewPassword: 'Введите Новый Пароль',
      AppStrings.confirmNewPassword: 'Подтвердите Новый Пароль',
      AppStrings.registerButton: 'Регистрация',

      AppStrings.setupPasswordText: 'Настройка пароля',
      AppStrings.setupPasswordHintText: 'Введите пароль',
      AppStrings.confirmPassword: 'Подтвердите пароль',
      AppStrings.confirmPasswordHint: 'Введите пароль ещё раз',
      AppStrings.continueButtonText: 'Продолжить',
      AppStrings.passCannotEmptyText: 'Пароль не может быть пустым',
      AppStrings.passwordRulesText: 'Правила пароля',
      AppStrings.passwordsDoNotMatch: 'Пароли не совпадают',

      // Password Requirements
      AppStrings.capitalLetterRequired: 'Заглавная буква еще не добавлена',
      AppStrings.lowercaseLetterRequired: 'Строчная буква еще не добавлена',
      AppStrings.numberRequired: 'Цифра еще не добавлена',
      AppStrings.specialCharRequired: 'Спецсимвол еще не добавлен',
      AppStrings.passwordsMustMatch: 'Пароли должны совпадать',
      AppStrings.forgotPasswordPageHeader: 'Забыли пароль',
      AppStrings.passwordResetSuccess: 'Пароль успешно сброшен',
      AppStrings.autoLoginFailed:
          'Автоматический вход не удался. Пожалуйста, войдите вручную',

      // LoginService Messages
      AppStrings.unknownInternalError: 'Неизвестная внутренняя ошибка',
      AppStrings.badRequest: 'Неверный запрос',
      AppStrings.invalidCredentials: 'Неверное имя пользователя или пароль',
      AppStrings.forbidden: 'Доступ запрещён',
      AppStrings.userNotFound: 'Пользователь не найден',
      AppStrings.invalidData: 'Неверные данные',
      AppStrings.serverError: 'Ошибка сервера: Пожалуйста, попробуйте снова',
      AppStrings.serviceUnavailable: 'Сервис временно недоступен',
      AppStrings.serviceDown: 'Сервис недоступен: Сервисы сейчас не работают',
      AppStrings.timeoutError: 'Время запроса истекло',
      AppStrings.requestCancelled: 'Запрос отменён',
      AppStrings.noInternet: 'Нет интернета, проверьте соединение и попробуйте снова',
      AppStrings.badCertificate: 'Ошибка сертификата безопасности',
      AppStrings.networkError: 'Произошла ошибка сети',
      AppStrings.loginFailed: 'Вход не выполнен',

      AppStrings.registrationSuccessful: 'Регистрация Успешна',
      AppStrings.passwordResetSuccessful: 'Сброс Пароля Успешен',
      AppStrings.carAdded: 'Автомобиль Добавлен',

      AppStrings.registrationSuccessSubtext:
      'Ваш аккаунт успешно создан. Теперь вы можете войти и начать управлять обслуживанием вашего автомобиля с легкостью.',
      AppStrings.passwordResetSuccessSubtext:
      'Ваш аккаунт успешно создан. Теперь вы можете войти и начать управлять обслуживанием вашего автомобиля с легкостью.',
      AppStrings.carAddedSubtext:
      'Новая Карта Добавлена BMW M4 Sports 2024',

      AppStrings.gotIt: 'Понятно',
      AppStrings.checkMyCars: 'Проверить Мои Автомобили',
      AppStrings.newCarAdded: 'Новая Карта Добавлена',

    },
  };

  static String translate(String key, String languageCode) {
    return translations[languageCode]?[key] ?? key;
  }
}
