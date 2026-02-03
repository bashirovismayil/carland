import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carcat/cubit/feedback/send_feedback_cubit.dart';
import 'package:carcat/cubit/feedback/send_feedback_state.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/localization/app_translation.dart';
import '../../../widgets/emoji_rating.dart';
import '../../../widgets/support_success_page.dart';
import '../support/support_page.dart';

class FeedbackPage extends HookWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedRating = useState<int?>(null);
    final descriptionController = useTextEditingController();
    final isLoading = useState(false);

    void submitFeedback() {
      if (selectedRating.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text(AppTranslation.translate(AppStrings.pleaseGiveRating)),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (descriptionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppTranslation.translate(AppStrings.pleaseEnterDescription)),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      context.read<FeedbackCubit>().submitFeedback(
        type: 'feedback',
        subject: 'General Feedback',
        description: descriptionController.text.trim(),
        rating: selectedRating.value,
      );
    }

    void navigateToSuccessPage() {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const SupportSuccessPage(
            isFeedback: true,
            howManySeconds: 3,
          ),
        ),
            (route) => false,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
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
            ],
          ),
        ),
        title: Text(
          AppTranslation.translate(AppStrings.feedback),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocListener<FeedbackCubit, FeedbackState>(
        listener: (context, state) {
          if (state is FeedbackSuccess) {
            isLoading.value = false;
            selectedRating.value = null;
            descriptionController.clear();

            navigateToSuccessPage();
          } else if (state is FeedbackError) {
            isLoading.value = false;
            String errorMessage =
            AppTranslation.translate(AppStrings.errorOccurred);

            if (state.message.contains('403')) {
              errorMessage =
                  AppTranslation.translate(AppStrings.noPermission);
            } else if (state.message.contains('404')) {
              errorMessage =
                  AppTranslation.translate(AppStrings.serviceNotFound);
            } else if (state.message.contains('network')) {
              errorMessage =
                  AppTranslation.translate(AppStrings.checkInternet);
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: AppTranslation.translate(AppStrings.retry),
                  textColor: Colors.white,
                  onPressed: submitFeedback,
                ),
              ),
            );
          } else if (state is FeedbackLoading) {
            isLoading.value = true;
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        AppTranslation.translate(AppStrings.feedbackQuestion),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        final rating = index + 1;
                        final isSelected = selectedRating.value == rating;

                        return EmojiRating(
                          rating: rating,
                          isSelected: isSelected,
                          onTap: () {
                            selectedRating.value = rating;
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      AppTranslation.translate(AppStrings.describeInDetail),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: AppTranslation.translate(
                            AppStrings.shareYourThoughts),
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: AppColors.primaryWhite,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.borderGrey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.borderGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          BorderSide(color: AppColors.borderGrey, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 17, right: 17, bottom: 40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading.value ? null : submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading.value
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    AppTranslation.translate(AppStrings.send),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}