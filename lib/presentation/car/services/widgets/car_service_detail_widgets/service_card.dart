import 'package:flutter/material.dart';
import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/localization/app_translation.dart';
import '../../../../../data/remote/models/remote/get_car_services_response.dart';
import '../../../../../utils/helper/service_percentage_calculator.dart';
import '../../../details/maintenance_widgets/service_card_edit_content.dart';
import 'service_card_header.dart';
import 'service_info_row.dart';

class ServiceCard extends StatefulWidget {
  final ResponseList service;
  final int carId;
  final bool isHidden;
  final VoidCallback onRefresh;
  final VoidCallback onToggleHidden;

  const ServiceCard({
    super.key,
    required this.service,
    required this.carId,
    required this.isHidden,
    required this.onRefresh,
    required this.onToggleHidden,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  late AnimationController _controller;
  late Animation<double> _headerOpacity;
  late Animation<double> _headerHeight;
  late Animation<double> _contentSize;
  late Animation<double> _contentOpacity;

  bool get _needsEdit => widget.service.lastServiceKm == 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );

    _headerOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.linear),
      ),
    );
    _headerHeight = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.45, curve: Curves.linear),
      ),
    );

    _contentSize = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.9, curve: Curves.linear),
      ),
    );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 1.0, curve: Curves.linear),
      ),
    );
    if (!_needsEdit) {
      _isExpanded = true;
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!_needsEdit) return;
    _isExpanded = !_isExpanded;
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage =
        ServicePercentageCalculator.getEffectivePercentage(widget.service);
    final needsEdit = _needsEdit;

    return AnimatedOpacity(
      opacity: widget.isHidden ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _controller.value > 0.3
                    ? AppColors.primaryBlack.withOpacity(0.08)
                    : Colors.grey.shade200,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _toggle,
                  behavior: HitTestBehavior.opaque,
                  child: SizeTransition(
                    sizeFactor: _headerHeight,
                    axisAlignment: -1.0,
                    child: Opacity(
                      opacity: _headerOpacity.value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.service.serviceName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 22,
                              color: Colors.grey.shade500,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Full content
                SizeTransition(
                  sizeFactor: _contentSize,
                  axisAlignment: -1.0,
                  child: Opacity(
                    opacity: _contentOpacity.value,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (needsEdit) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: GestureDetector(
                                onTap: _toggle,
                                behavior: HitTestBehavior.opaque,
                                child: Text(
                                  widget.service.serviceName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ServiceCardEditContent(
                              key: ValueKey(
                                  'edit_${widget.service.percentageId}'),
                              carId: widget.carId,
                              serviceName: widget.service.serviceName,
                              onRefresh: widget.onRefresh,
                            ),
                          ] else ...[
                            ServiceCardHeader(
                              service: widget.service,
                              carId: widget.carId,
                              percentage: percentage,
                              isHidden: widget.isHidden,
                              onRefresh: widget.onRefresh,
                              onToggleHidden: widget.onToggleHidden,
                            ),
                            const SizedBox(height: 16),
                            ServiceInfoRow(
                              title: AppTranslation.translate(
                                  AppStrings.lastService),
                              km: widget.service.lastServiceKm,
                              date: widget.service.lastServiceDate,
                            ),
                            const SizedBox(height: 10),
                            ServiceInfoRow(
                              title: AppTranslation.translate(
                                  AppStrings.nextService),
                              km: widget.service.nextServiceKm,
                              date: widget.service.nextServiceDate,
                              isForNextService: true,
                              hasIntervalKm: widget.service.intervalKm > 0,
                              hasIntervalMonth:
                                  widget.service.intervalMonth > 0,
                            ),
                          ],
                          const SizedBox(height: 10),
                          if (needsEdit) ...[
                            const SizedBox(height: 5),
                            GestureDetector(
                              onTap: _toggle,
                              behavior: HitTestBehavior.opaque,
                              child: Center(
                                child: Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Colors.grey.shade600,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
