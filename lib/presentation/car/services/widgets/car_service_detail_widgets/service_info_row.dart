import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../core/constants/colors/app_colors.dart';
import 'not_applicable_placeholder.dart';

class ServiceInfoRow extends StatelessWidget {
  final String title;
  final dynamic km;
  final dynamic date;
  final bool hasIntervalKm;
  final bool hasIntervalMonth;
  final bool isForNextService;

  static const double kmSectionWidth = 110.0;

  const ServiceInfoRow({
    super.key,
    required this.title,
    required this.km,
    required this.date,
    this.hasIntervalKm = true,
    this.hasIntervalMonth = true,
    this.isForNextService = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _titleStyle),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _buildDateSection(context)),
            SizedBox(width: kmSectionWidth, child: _buildKmSection(context)),
          ],
        ),
      ],
    );
  }

  TextStyle get _titleStyle => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryBlack,
  );

  Widget _buildDateSection(BuildContext context) {
    if (isForNextService && !hasIntervalMonth) {
      return const NotApplicablePlaceholder(isForDate: true);
    }
    return _buildIconText('assets/svg/service_key_icon.svg', '$date');
  }

  Widget _buildKmSection(BuildContext context) {
    if (isForNextService && !hasIntervalKm) {
      return const NotApplicablePlaceholder(isForDate: false);
    }
    return _buildIconText('assets/svg/odometer_icon.svg', '$km km');
  }

  Widget _buildIconText(String asset, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(asset, width: 22, height: 22),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}