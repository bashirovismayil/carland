import 'package:flutter/material.dart';
import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/constants/values/app_theme.dart';
import '../../../../../core/localization/app_translation.dart';
import '../../../../../data/remote/models/remote/get_car_services_response.dart';
import '../../../../../data/remote/services/local/hidden_services_local_service.dart';
import '../../../../../utils/di/locator.dart';
import '../../../../../utils/helper/service_percentage_calculator.dart';
import 'service_card.dart';
import 'services_list_header.dart';

class ServicesList extends StatefulWidget {
  final List<ResponseList> services;
  final int carId;
  final bool isLoading;
  final VoidCallback onRefresh;
  final ScrollController scrollController;

  const ServicesList({
    super.key,
    required this.services,
    required this.carId,
    required this.isLoading,
    required this.onRefresh,
    required this.scrollController,
  });

  @override
  State<ServicesList> createState() => _ServicesListState();
}

class _ServicesListState extends State<ServicesList> {
  final _hiddenServicesService = locator<HiddenServicesLocalService>();
  bool _hiddenSectionExpanded = false;

  List<ResponseList> get _sortedServices {
    final sorted = List<ResponseList>.from(widget.services)
      ..sort((a, b) {
        final aNeedsEdit = a.lastServiceKm == 0;
        final bNeedsEdit = b.lastServiceKm == 0;
        if (aNeedsEdit != bNeedsEdit) {
          return aNeedsEdit ? 1 : -1;
        }
        return ServicePercentageCalculator.getEffectivePercentage(a)
            .compareTo(ServicePercentageCalculator.getEffectivePercentage(b));
      });
    return sorted;
  }

  List<ResponseList> get _visibleServices =>
      _sortedServices.where((s) => !_hiddenServicesService.isHidden(s.percentageId)).toList();

  List<ResponseList> get _hiddenServices =>
      _sortedServices.where((s) => _hiddenServicesService.isHidden(s.percentageId)).toList();

  void _onToggleHidden(int percentageId) {
    final wasVisible = !_hiddenServicesService.isHidden(percentageId);
    _hiddenServicesService.toggleHidden(percentageId);
    setState(() {});

    if (wasVisible) {
      _showHiddenSnackBar();
    }
  }

  void _showHiddenSnackBar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final count = _hiddenServices.length;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.visibility_off_outlined,
              size: 16,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            Text(
              '${AppTranslation.translate(AppStrings.hiddenServices)} ($count)',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: AppTranslation.translate(AppStrings.show),
          textColor: Colors.white,
          onPressed: _scrollToHiddenSection,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.primaryBlack,
        duration: const Duration(seconds: 3),
        dismissDirection: DismissDirection.down,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: 24,
          right: 24,
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }

  void _scrollToHiddenSection() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() => _hiddenSectionExpanded = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sc = widget.scrollController;
      if (sc.hasClients) {
        sc.animateTo(
          sc.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleServices = _visibleServices;
    final hiddenServices = _hiddenServices;

    return SliverList(
      delegate: SliverChildListDelegate([
        ServicesListHeader(isLoading: widget.isLoading),
        const SizedBox(height: 12),
        ...visibleServices.expand((service) => [
          _buildServiceCard(service, isHidden: false),
          if (service != visibleServices.last || hiddenServices.isNotEmpty)
            const SizedBox(height: 16),
        ]),
        if (hiddenServices.isNotEmpty) ...[
          _buildHiddenServicesDivider(hiddenServices.length),
          if (_hiddenSectionExpanded) ...[
            const SizedBox(height: 16),
            ...hiddenServices.expand((service) => [
              _buildServiceCard(service, isHidden: true),
              if (service != hiddenServices.last) const SizedBox(height: 16),
            ]),
          ],
        ],
      ]),
    );
  }

  Widget _buildServiceCard(ResponseList service, {required bool isHidden}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      child: AnimatedOpacity(
        opacity: widget.isLoading ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: ServiceCard(
          service: service,
          carId: widget.carId,
          isHidden: isHidden,
          onRefresh: widget.onRefresh,
          onToggleHidden: () => _onToggleHidden(service.percentageId),
        ),
      ),
    );
  }

  Widget _buildHiddenServicesDivider(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      child: GestureDetector(
        onTap: () {
          setState(() => _hiddenSectionExpanded = !_hiddenSectionExpanded);
          if (_hiddenSectionExpanded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final sc = widget.scrollController;
              if (sc.hasClients) {
                final target = (sc.offset + 250).clamp(0.0, sc.position.maxScrollExtent);
                sc.animateTo(
                  target,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              }
            });
          }
        },
        child: Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility_off_outlined, size: 16, color: Colors.grey.shade700),
                  const SizedBox(width: 6),
                  Text(
                    '${AppTranslation.translate(AppStrings.hiddenServices)} ($count)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _hiddenSectionExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),
      ),
    );
  }
}