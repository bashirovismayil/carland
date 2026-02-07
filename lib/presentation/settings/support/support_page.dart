import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      body: BlocListener<FeedbackCubit, FeedbackState>(
        listener: (context, state) {
          if (state is FeedbackSuccess) {
            _resetForm(selectedType, descriptionController, selectedFile);
            _navigateToSuccessPage(context);
          } else if (state is FeedbackError) {
            _showErrorSnackbar(context, state.message);
          } else if (state is FeedbackValidationFailed) {
            _showValidationError(context, state.error);
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _TypeDropdownSection(selectedType: selectedType),
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
              _SubmitButtonSection(
                selectedType: selectedType,
                descriptionController: descriptionController,
                selectedFile: selectedFile,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
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

  void _showValidationError(
      BuildContext context,
      FeedbackValidationError error,
      ) {
    String message;
    switch (error) {
      case FeedbackValidationError.typeRequired:
        message = AppTranslation.translate(AppStrings.selectRequestType);
        break;
      case FeedbackValidationError.descriptionRequired:
        message = AppTranslation.translate(AppStrings.enterDescription);
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
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
}
class _TypeDropdownSection extends StatelessWidget {
  final ValueNotifier<String?> selectedType;

  const _TypeDropdownSection({required this.selectedType});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedbackCubit, FeedbackState>(
      buildWhen: (previous, current) {
        return current is FeedbackTypesLoaded;
      },
      builder: (context, state) {
        final supportTypes = state is FeedbackTypesLoaded
            ? state.types
            .where((type) => type == 'support' || type == 'bug_report')
            .toList()
            : <String>[];

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
      },
    );
  }

  String _getTypeDisplayName(String type) {
    final typeNames = {
      'support': AppTranslation.translate(AppStrings.supportTypeSupport),
      'bug_report': AppTranslation.translate(AppStrings.supportTypeBugReport),
    };
    return typeNames[type] ?? type;
  }
}

class _SubmitButtonSection extends HookWidget {
  final ValueNotifier<String?> selectedType;
  final TextEditingController descriptionController;
  final ValueNotifier<File?> selectedFile;

  const _SubmitButtonSection({
    required this.selectedType,
    required this.descriptionController,
    required this.selectedFile,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedbackCubit, FeedbackState>(
      buildWhen: (previous, current) {
        return (previous is! FeedbackLoading && current is FeedbackLoading) ||
            (previous is FeedbackLoading && current is! FeedbackLoading);
      },
      builder: (context, state) {
        final isLoading = state is FeedbackLoading;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
              context.read<FeedbackCubit>().submitSupportRequest(
                selectedType: selectedType.value,
                description: descriptionController.text,
                filePath: selectedFile.value?.path,
              );
            },
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
      },
    );
  }
}