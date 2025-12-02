import '../../core/constants/texts/app_strings.dart';
import '../../core/localization/app_translation.dart';

class RoleHelper {
  static String getDisplayName(String role) {
    switch (role) {
      case 'BOSS':
        return AppTranslation.translate(AppStrings.boss);
      case 'SUPER_ADMIN':
        return AppTranslation.translate(AppStrings.superAdmin);
      case 'ADMIN':
        return AppTranslation.translate(AppStrings.admin);
      case 'USER':
        return AppTranslation.translate(AppStrings.user);
      default:
        return role;
    }
  }
}