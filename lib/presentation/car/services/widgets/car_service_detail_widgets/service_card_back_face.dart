import 'package:flutter/material.dart';
import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/localization/app_translation.dart';
import '../../../../../utils/helper/service_percentage_calculator.dart';

class ServiceCardBackFace extends StatelessWidget {
  final int remainingKm;
  final String remainingMonths;
  final int kmPercentage;
  final int monthPercentage;
  final bool isTimeBased;
  final bool hasBoth;

  const ServiceCardBackFace({
    super.key,
    required this.remainingKm,
    required this.remainingMonths,
    required this.kmPercentage,
    required this.monthPercentage,
    required this.isTimeBased,
    required this.hasBoth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlack.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppTranslation.translate(AppStrings.remainingService),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 19),
            if (!hasBoth && isTimeBased)
              _buildInfoTile(
                icon: Icons.calendar_month_rounded,
                value: _formatDays(remainingMonths),
                label: AppTranslation.translate(AppStrings.remainingMonths),
                percentage: monthPercentage,
                isActive: true,
              )
            else if (!hasBoth && !isTimeBased)
              _buildInfoTile(
                icon: Icons.route_rounded,
                value: _formatKm(remainingKm),
                label: AppTranslation.translate(AppStrings.remainingKm),
                percentage: kmPercentage,
                isActive: true,
              )
            else ...[
              _buildInfoTile(
                icon: Icons.route_rounded,
                value: _formatKm(remainingKm),
                label: AppTranslation.translate(AppStrings.remainingKm),
                percentage: kmPercentage,
                isActive: !isTimeBased,
              ),
              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 16),
              _buildInfoTile(
                icon: Icons.calendar_month_rounded,
                value: _formatDays(remainingMonths),
                label: AppTranslation.translate(AppStrings.remainingMonths),
                percentage: monthPercentage,
                isActive: isTimeBased,
              ),
            ],
            if (!hasBoth) const SizedBox(height: 78),
          //  const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String value,
    required String label,
    required int percentage,
    required bool isActive,
  }) {
    final color = ServicePercentageCalculator.getChartColor(percentage);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive ? color : Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color:
                      isActive ? AppColors.textPrimary : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        _buildPercentageBadge(percentage, color, isActive),
      ],
    );
  }

  Widget _buildPercentageBadge(int percentage, Color color, bool isActive) {
    return Column(
      children: [
        Container(
          width: 52,
          padding: const EdgeInsets.symmetric(vertical: 5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.12) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: isActive
                ? Border.all(color: color.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? color : Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(AppTranslation.translate(AppStrings.left), style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
    );
  }

  String _formatKm(int km) {
    final abs = km.abs().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < abs.length; i++) {
      if (i > 0 && (abs.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(abs[i]);
    }

    return '${km < 0 ? '-' : ''}${buffer.toString()} km';
  }

  String _formatDays(String rawDays) {
    final totalDays = int.tryParse(rawDays);
    if (totalDays == null) return rawDays;

    final years = totalDays.abs() ~/ 365;
    final remainingDays = totalDays.abs() % 365;
    final months = remainingDays ~/ 30;
    final days = remainingDays % 30;

    final parts = <String>[];

    if (years > 0) {
      parts.add('$years ${AppTranslation.translate(AppStrings.yearText)}');
    }
    if (months > 0) {
      parts.add('$months ${AppTranslation.translate(AppStrings.monthText)}');
    }
    if (days > 0) {
      parts.add('$days ${AppTranslation.translate(AppStrings.dayText)}');
    }

    return parts.isEmpty
        ? '0 ${AppTranslation.translate(AppStrings.dayText)}'
        : parts.join(' ');
  }
}
