import 'dart:math' as math;
import 'package:carcat/presentation/history/history_page.dart';
import 'package:carcat/utils/helper/go.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/localization/app_translation.dart';
import '../../../../../core/mixins/flip_card_mixin.dart';
import '../../../../../core/mixins/peek_hint_mixin.dart';
import '../../../../../data/remote/models/remote/get_car_services_response.dart';
import '../../../../../data/remote/services/local/peek_hint_local_service.dart';
import '../../../../../utils/di/locator.dart';
import '../../../../../utils/helper/service_edit_helper.dart';
import '../../../../../utils/helper/service_percentage_calculator.dart';
import '../../../details/maintenance_widgets/service_card_edit_content.dart';
import 'service_card_back_face.dart';
import 'service_card_header.dart';
import 'service_info_row.dart';

class ServiceCard extends StatefulWidget {
  final ResponseList service;
  final int carId;
  final bool isHidden;
  final VoidCallback onRefresh;
  final VoidCallback onToggleHidden;
  final int? carModelYear;
  final int? currentMileage;
  final VoidCallback? onExpand;
  final bool isForceCollapsed;
  final bool shouldPeekHint;
  final VoidCallback? onPeekHintComplete;

  const ServiceCard({
    super.key,
    required this.service,
    required this.carId,
    required this.isHidden,
    required this.onRefresh,
    required this.onToggleHidden,
    this.carModelYear,
    this.currentMileage,
    this.onExpand,
    this.isForceCollapsed = false,
    this.shouldPeekHint = false,
    this.onPeekHintComplete,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard>
    with TickerProviderStateMixin, FlipCardMixin, PeekHintMixin {
  bool _isExpanded = false;

  late AnimationController _controller;
  late Animation<double> _headerOpacity;
  late Animation<double> _headerHeight;
  late Animation<double> _contentSize;
  late Animation<double> _contentOpacity;

  final _peekHintService = locator<PeekHintLocalService>();

  bool get _needsEdit => ServiceEditHelper.needsEdit(widget.service);

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

    initFlipController();
    initPeekHint(vsync: this, maxAngle: 40.0);

    debugPrint('---------------- ServiceCard initState: ${widget.service.serviceName}');
    debugPrint('---------------- shouldPeekHint: ${widget.shouldPeekHint}, needsEdit: $_needsEdit');

    if (widget.shouldPeekHint && !_needsEdit) {
      _schedulePeekHint();
    }
  }

  void _schedulePeekHint() {
    debugPrint('---------------- _schedulePeekHint called for ${widget.service.serviceName}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        debugPrint('---------------- Peek delay fired. mounted: $mounted, isFlipped: $isFlipped');
        if (mounted && !isFlipped) {
          triggerPeekHint();
          debugPrint('---------------- triggerPeekHint() called!');
          widget.onPeekHintComplete?.call();
        }
      });
    });
  }

  @override
  void didUpdateWidget(covariant ServiceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPeekHint &&
        !oldWidget.shouldPeekHint &&
        !_needsEdit &&
        !peekHintPlayed) {
      debugPrint('---------------- didUpdateWidget: shouldPeekHint changed to true for ${widget.service.serviceName}');
      _schedulePeekHint();
    }

    if (oldWidget.service.percentageId != widget.service.percentageId) {
      if (isFlipped) {
        flipController.value = 0.0;
      }

      final needsEdit = ServiceEditHelper.needsEdit(widget.service);
      if (!needsEdit) {
        _isExpanded = true;
        _controller.value = 1.0;
      } else {
        _isExpanded = false;
        _controller.value = 0.0;
      }
      return;
    }

    if (_needsEdit &&
        widget.isForceCollapsed != oldWidget.isForceCollapsed &&
        widget.isForceCollapsed &&
        _isExpanded) {
      _isExpanded = false;
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    disposePeekHint();
    disposeFlipController();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!_needsEdit) return;
    _isExpanded = !_isExpanded;
    if (_isExpanded) {
      widget.onExpand?.call();
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handleFlip() {
    // Cancel peek hint if it's still playing to avoid dual rotateY conflict.
    cancelPeekHint();

    if (isFlipped) {
      unflipCard();
    } else {
      flipCard();
      // Mark that the user has manually flipped a card.
      _peekHintService.markUserFlipped();
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage =
    ServicePercentageCalculator.getEffectivePercentage(widget.service);
    final needsEdit = _needsEdit;
    final bool canFlip = !needsEdit;

    return AnimatedOpacity(
      opacity: widget.isHidden ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: flipAnimation,
          builder: (context, _) {
            final angle = flipAnimation.value * math.pi;
            final showBack = angle > math.pi / 2;

            return GestureDetector(
              onTap: canFlip ? _handleFlip : null,
              child: buildPeekHintTransform(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  child: showBack
                      ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: ServiceCardBackFace(
                      remainingKm: widget.service.remainingKm,
                      remainingMonths: widget.service.remainingMonths,
                      kmPercentage: widget.service.kmPercentage,
                      monthPercentage:
                      widget.service.monthPercentageDigit,
                      isTimeBased:
                      ServicePercentageCalculator.isTimeBased(
                          widget.service),
                      hasBoth: widget.service.intervalKm > 0 &&
                          widget.service.intervalMonth > 0,
                    ),
                  )
                      : _buildFrontFace(
                    percentage: percentage,
                    needsEdit: needsEdit,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFrontFace({
    required int percentage,
    required bool needsEdit,
  }) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
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
                                    fontSize: 16,
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
                                carModelYear: widget.carModelYear,
                                currentMileage: widget.currentMileage,
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
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                child: Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Colors.grey.shade200,
                                ),
                              ),
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
                              if (percentage <= 10) ...[
                                const SizedBox(height: 16),
                                _buildBookServiceButton(),
                              ],
                            ],
                            if (needsEdit) ...[
                              const SizedBox(height: 11),
                              GestureDetector(
                                onTap: _toggle,
                                behavior: HitTestBehavior.opaque,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5.0, right: 1, left: 12),
                                    child: Icon(
                                      Icons.keyboard_arrow_up,
                                      color: Colors.grey.shade600,
                                      size: 20,
                                    ),
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
            ),
            if (!needsEdit)
              Positioned(
                right: 4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.touch_app_rounded,
                      size: 17,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBookServiceButton() {
    return GestureDetector(
      onTap: () {
        Go.to(context, HistoryPage());
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            AppTranslation.translate(AppStrings.bookServiceSlot),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}