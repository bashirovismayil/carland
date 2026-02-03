import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carcat/cubit/feedback/send_feedback_cubit.dart';
import 'package:carcat/cubit/feedback/send_feedback_state.dart';

import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/localization/app_translation.dart';
import '../../../widgets/screenshoot_upload.dart';
import '../../../widgets/support_success_page.dart';

class SupportPage extends HookWidget {
  const SupportPage({super.key});

  static const _maxFileSizeMB = 10.0;
  static const _maxFileSizeBytes = _maxFileSizeMB * 1024 * 1024;

  @override
  Widget build(BuildContext context) {
    final selectedType = useState<String?>(null);
    final descriptionController = useTextEditingController();
    final selectedFile = useState<File?>(null);

    useEffect(() {
      context.read<FeedbackCubit>().loadFeedbackTypes();
      return null;
    }, const []);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: BlocConsumer<FeedbackCubit, FeedbackState>(
        listener: (context, state) => _handleStateChanges(
          context: context,
          state: state,
          selectedType: selectedType,
          descriptionController: descriptionController,
          selectedFile: selectedFile,
        ),
        builder: (context, state) {
          final isLoading = state is FeedbackLoading;
          final supportTypes = _extractSupportTypes(state);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildTypeDropdown(
                  selectedType: selectedType,
                  supportTypes: supportTypes,
                ),
                const SizedBox(height: 20),
                _buildDescriptionField(descriptionController),
                const SizedBox(height: 20),
                ScreenshotUploadWidget(
                  selectedFile: selectedFile.value,
                  onFileChanged: (file) => selectedFile.value = file,
                  isOptional: true,
                  maxFileSizeMB: _maxFileSizeMB,
                  height: 220,
                ),
                const SizedBox(height: 32),
                _buildSubmitButton(
                  context: context,
                  isLoading: isLoading,
                  selectedType: selectedType.value,
                  description: descriptionController.text,
                  filePath: selectedFile.value?.path,
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  List<String> _extractSupportTypes(FeedbackState state) {
    if (state is FeedbackTypesLoaded) {
      return state.types
          .where((type) => type == 'support' || type == 'bug_report')
          .toList();
    }
    return const [];
  }

  void _handleStateChanges({
    required BuildContext context,
    required FeedbackState state,
    required ValueNotifier<String?> selectedType,
    required TextEditingController descriptionController,
    required ValueNotifier<File?> selectedFile,
  }) {
    if (state is FeedbackSuccess) {
      _resetForm(selectedType, descriptionController, selectedFile);
      _navigateToSuccessPage(context);
    } else if (state is FeedbackError) {
      _showErrorSnackbar(context, state.message);
    }
  }

  void _navigateToSuccessPage(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const SupportSuccessPage(
          isFeedback: false,
          howManySeconds: 3,
        ),
      ),
          (route) => false,
    );
  }

  void _resetForm(
      ValueNotifier<String?> selectedType,
      TextEditingController descriptionController,
      ValueNotifier<File?> selectedFile,
      ) {
    selectedType.value = null;
    descriptionController.clear();
    selectedFile.value = null;
  }

  bool _validateForm(
      BuildContext context, {
        required String? selectedType,
        required String description,
      }) {
    if (selectedType == null) {
      _showWarningSnackbar(
          context, AppTranslation.translate(AppStrings.selectRequestType));
      return false;
    }

    if (description.trim().isEmpty) {
      _showWarningSnackbar(
          context, AppTranslation.translate(AppStrings.enterDescription));
      return false;
    }

    return true;
  }

  void _submitSupport(
      BuildContext context, {
        required String? selectedType,
        required String description,
        required String? filePath,
      }) {
    if (!_validateForm(context,
        selectedType: selectedType, description: description)) {
      return;
    }

    context.read<FeedbackCubit>().submitFeedback(
      type: selectedType!,
      subject: 'Support Topic',
      description: description.trim(),
      filePath: filePath,
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    final errorMessage = _mapErrorMessage(message);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showWarningSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _mapErrorMessage(String message) {
    if (message.contains('403')) {
      return AppTranslation.translate(AppStrings.operationNotAuthorized);
    }
    if (message.contains('404')) {
      return AppTranslation.translate(AppStrings.serviceNotFound);
    }
    if (message.contains('network')) {
      return AppTranslation.translate(AppStrings.checkInternetConnection);
    }
    return AppTranslation.translate(AppStrings.errorOccurred);
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.primaryWhite,
      elevation: 0,
      leading: _buildBackButton(context),
      title: Text(
        AppTranslation.translate(AppStrings.supportText),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            width: 41,
            height: 41,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F1F1),
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(
                Icons.arrow_back_ios,
                size: 15,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      AppTranslation.translate(AppStrings.sendingRequest),
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTypeDropdown({
    required ValueNotifier<String?> selectedType,
    required List<String> supportTypes,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTranslation.translate(AppStrings.requestType),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedType.value,
            decoration: InputDecoration(
              hintText: AppTranslation.translate(AppStrings.select),
              hintStyle: const TextStyle(color: AppColors.hintColor),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            dropdownColor: Colors.white,
            icon: const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ),
            isExpanded: true,
            items: supportTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_getTypeDisplayName(type)),
              );
            }).toList(),
            onChanged: (value) => selectedType.value = value,
          ),
        ),
      ],
    );
  }

  String _getTypeDisplayName(String type) {
    final typeNames = {
      'support': AppTranslation.translate(AppStrings.supportTypeSupport),
      'bug_report': AppTranslation.translate(AppStrings.supportTypeBugReport),
    };
    return typeNames[type] ?? type;
  }

  Widget _buildDescriptionField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTranslation.translate(AppStrings.describeSupportInDetail),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: AppTranslation.translate(AppStrings.describeRequestHere),
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[400]!,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton({
    required BuildContext context,
    required bool isLoading,
    required String? selectedType,
    required String description,
    required String? filePath,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () => _submitSupport(
          context,
          selectedType: selectedType,
          description: description,
          filePath: filePath,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          disabledBackgroundColor: Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          AppTranslation.translate(AppStrings.submit),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}