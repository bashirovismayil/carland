import 'dart:math' as math;
import 'package:carcat/presentation/history/history_page.dart';
import 'package:carcat/utils/helper/go.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
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
    with
        TickerProviderStateMixin,
        FlipCardMixin,
        PeekHintMixin,
        AutomaticKeepAliveClientMixin {
  // ============================================================
  // STATIC SABITLER (allocation azaltmak için)
  // Her build'de yeniden yaratılmak yerine class yükleme sırasında
  // bir kez hesaplanır ve paylaşılır.
  // ============================================================
  static const _kCardRadius = BorderRadius.all(Radius.circular(16));
  static const _kInnerHeaderRadius = BorderRadius.all(Radius.circular(8));
  static const _kBookButtonRadius = BorderRadius.all(Radius.circular(100));

  static const _kHeaderPadding =
  EdgeInsets.symmetric(horizontal: 16, vertical: 14);
  static const _kCardPadding = EdgeInsets.all(20);
  static const _kInnerHeaderPadding =
  EdgeInsets.symmetric(horizontal: 12, vertical: 6);
  static const _kDividerPadding =
  EdgeInsets.symmetric(vertical: 10, horizontal: 16);
  static const _kBookButtonPadding = EdgeInsets.symmetric(vertical: 14);
  static const _kEditTailPadding =
  EdgeInsets.only(top: 5.0, right: 1, left: 12);
  static const _kIconPadding = EdgeInsets.only(right: 6);

  static const _kNameStyleSemi = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const _kNameStyleBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const _kFadeDuration = Duration(milliseconds: 400);
  static const _kHideDuration = Duration(milliseconds: 300);
  static const _kFlipDuration = Duration(milliseconds: 280);
  static const _kVisibilityThreshold = 0.15;

  // Runtime-const (withOpacity/shade runtime hesaplanır, static final ile bir kez).
  static final _kShadow = <BoxShadow>[
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  static final _kBorderExpanded = AppColors.primaryBlack.withOpacity(0.08);
  static final _kBorderCollapsed = Colors.grey.shade200;

  // ============================================================
  // STATE
  // ============================================================
  bool _isExpanded = false;

  late AnimationController _controller;
  late Animation<double> _headerOpacity;
  late Animation<double> _headerHeight;
  late Animation<double> _contentSize;
  late Animation<double> _contentOpacity;

  final _peekHintService = locator<PeekHintLocalService>();

  /// İlk açılış mı? Session boyunca sabit.
  late final bool _isFirstLaunch;

  /// needsEdit memoized. initState'te bir kez, didUpdateWidget'ta service
  /// değişirse yeniden hesaplanır. Her build'de helper çağrısı yapılmaz.
  late bool _needsEdit;

  /// Touch hint ikonu için izole notifier.
  /// - null ise: ilk açılış, statik ikon gösterilir (animasyon yok)
  /// - non-null ise: 2+ açılış, VisibilityDetector bu notifier'ı günceller
  ///   ve SADECE ValueListenableBuilder rebuild olur, kart gövdesi DEĞİL.
  ValueNotifier<bool>? _iconVisibilityNotifier;

  // SliverChildBuilderDelegate state'i unmount etmesin diye.
  // mevcut SliverChildListDelegate davranışıyla eşdeğerlik sağlar.
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _isFirstLaunch = _peekHintService.isFirstAppLaunch;
    _needsEdit = ServiceEditHelper.needsEdit(widget.service);

    if (!_isFirstLaunch) {
      _iconVisibilityNotifier = ValueNotifier<bool>(false);
    }

    _controller = AnimationController(duration: _kFlipDuration, vsync: this);

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

    debugPrint(
      '[SVC_CARD] initState id=${widget.service.percentageId} '
          'name="${widget.service.serviceName}" '
          'firstLaunch=$_isFirstLaunch needsEdit=$_needsEdit',
    );

    if (widget.shouldPeekHint && !_needsEdit) {
      _schedulePeekHint();
    }
  }

  void _schedulePeekHint() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && !isFlipped) {
          triggerPeekHint();
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
      _schedulePeekHint();
    }

    if (oldWidget.service.percentageId != widget.service.percentageId) {
      if (isFlipped) {
        flipController.value = 0.0;
      }

      // Service değişti: memoized _needsEdit'i güncelle.
      _needsEdit = ServiceEditHelper.needsEdit(widget.service);
      debugPrint(
        '[SVC_CARD] service changed id=${widget.service.percentageId} '
            'needsEdit=$_needsEdit',
      );

      if (!_needsEdit) {
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
    _iconVisibilityNotifier?.dispose();
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
    cancelPeekHint();
    if (isFlipped) {
      unflipCard();
    } else {
      flipCard();
      _peekHintService.markUserFlipped();
    }
  }

  /// VisibilityDetector callback.
  /// KRİTİK: setState çağırmaz. Sadece notifier'ı günceller → kart
  /// gövdesi rebuild olmaz, yalnızca ValueListenableBuilder altındaki
  /// AnimatedOpacity subtree'si yenilenir.
  void _onVisibilityChanged(VisibilityInfo info) {
    final notifier = _iconVisibilityNotifier;
    if (notifier == null || !mounted) return;

    final nowVisible = info.visibleFraction > _kVisibilityThreshold;
    if (nowVisible != notifier.value) {
      notifier.value = nowVisible;
      // Scroll sırasında çok sık çıkar, sorun yoksa kapalı tutuyorum.
      // debugPrint('[SVC_CARD] vis ${widget.service.percentageId} → $nowVisible');
    }
  }

  @override
  Widget build(BuildContext context) {
    // AutomaticKeepAliveClientMixin gereği.
    super.build(context);

    // RİSKLİ NOKTA — ölçüm logu:
    // Bu log scroll sırasında tek bir kart için ÇOK sık çıkmamalı.
    // Eğer her scroll tick'inde ilgili kartın build'i düşüyorsa
    // isolation bozuk demektir. Normalde: initState, didUpdateWidget
    // ve ebeveyn setState'te düşer.
    debugPrint('[SVC_CARD] build id=${widget.service.percentageId}');

    final percentage =
    ServicePercentageCalculator.getEffectivePercentage(widget.service);
    final needsEdit = _needsEdit;
    final canFlip = !needsEdit;

    // Yüzleri build() başında BİR KEZ inşa ediyoruz.
    // AnimatedBuilder her flip tick'inde bunları REFERANS olarak
    // yeniden kullanır — subtree reconstruct EDİLMEZ.
    final frontFace =
    _buildFrontFace(percentage: percentage, needsEdit: needsEdit);
    final backFace = _buildBackFace();

    final Widget content = AnimatedOpacity(
      opacity: widget.isHidden ? 0.5 : 1.0,
      duration: _kHideDuration,
      child: RepaintBoundary(
        child: GestureDetector(
          onTap: canFlip ? _handleFlip : null,
          child: AnimatedBuilder(
            animation: flipAnimation,
            builder: (context, _) {
              final angle = flipAnimation.value * math.pi;
              final showBack = angle > math.pi / 2;
              return buildPeekHintTransform(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  // Prebuilt referanslar — builder her tick'inde yeniden
                  // inşa etmez, Flutter element tree aynı instance'ı görüp
                  // subtree'yi diff-skip eder.
                  child: showBack ? backFace : frontFace,
                ),
              );
            },
          ),
        ),
      ),
    );

    // İlk açılışta VisibilityDetector'a gerek yok — ikon statik.
    if (_isFirstLaunch) return content;

    return VisibilityDetector(
      key: Key('service_card_visibility_${widget.service.percentageId}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: content,
    );
  }

  Widget _buildBackFace() {
    // Rotated wrapper dahil önceden inşa; flip tick'lerinde yeniden
    // inşa edilmez.
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: ServiceCardBackFace(
        remainingKm: widget.service.remainingKm,
        remainingMonths: widget.service.remainingMonths,
        kmPercentage: widget.service.kmPercentage,
        monthPercentage: widget.service.monthPercentageDigit,
        isTimeBased: ServicePercentageCalculator.isTimeBased(widget.service),
        hasBoth: widget.service.intervalKm > 0 &&
            widget.service.intervalMonth > 0,
      ),
    );
  }

  Widget _buildFrontFace({required int percentage, required bool needsEdit}) {
    // "Stable content" = SizeTransition/FadeTransition sınırı altındaki
    // TÜM ağaç. ListenableBuilder'ın DIŞINDA inşa edilir; controller
    // tick'leri bu ağacı yeniden inşa etmez. SizeTransition/FadeTransition
    // zaten kendi animation dinleyicilerine sahip — izole güncellerler.
    final stableContent =
    _buildStableContent(percentage: percentage, needsEdit: needsEdit);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Controller'a bağlı TEK şey: Container shell'in border color'ı.
        // ListenableBuilder sadece Container'ı yeniden inşa eder,
        // stableContent child olarak AYNI referansla geçer.
        ListenableBuilder(
          listenable: _controller,
          child: stableContent,
          builder: (context, child) {
            final borderColor = _controller.value > 0.3
                ? _kBorderExpanded
                : _kBorderCollapsed;
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _kCardRadius,
                border: Border.all(color: borderColor),
                boxShadow: _kShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: child,
            );
          },
        ),
        if (!needsEdit) _buildTouchHintIcon(),
      ],
    );
  }

  Widget _buildStableContent({
    required int percentage,
    required bool needsEdit,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _toggle,
          behavior: HitTestBehavior.opaque,
          child: SizeTransition(
            sizeFactor: _headerHeight,
            axisAlignment: -1.0,
            // Opacity(value) yerine FadeTransition(animation) —
            // izole rebuild, tasarım birebir aynı.
            child: FadeTransition(
              opacity: _headerOpacity,
              child: Padding(
                padding: _kHeaderPadding,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.service.serviceName,
                        style: _kNameStyleSemi,
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
          child: FadeTransition(
            opacity: _contentOpacity,
            child: Padding(
              padding: _kCardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (needsEdit) ...[
                    Container(
                      padding: _kInnerHeaderPadding,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: _kInnerHeaderRadius,
                      ),
                      child: GestureDetector(
                        onTap: _toggle,
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          widget.service.serviceName,
                          style: _kNameStyleBold,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ServiceCardEditContent(
                      key: ValueKey('edit_${widget.service.percentageId}'),
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
                      title: AppTranslation.translate(AppStrings.lastService),
                      km: widget.service.lastServiceKm,
                      date: widget.service.lastServiceDate,
                    ),
                    Padding(
                      padding: _kDividerPadding,
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade200,
                      ),
                    ),
                    ServiceInfoRow(
                      title: AppTranslation.translate(AppStrings.nextService),
                      km: widget.service.nextServiceKm,
                      date: widget.service.nextServiceDate,
                      isForNextService: true,
                      hasIntervalKm: widget.service.intervalKm > 0,
                      hasIntervalMonth: widget.service.intervalMonth > 0,
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
                          padding: _kEditTailPadding,
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
    );
  }

  Widget _buildTouchHintIcon() {
    // İlk açılış: ORIGINAL DAVRANIŞ — statik ikon, animasyon yok.
    if (_isFirstLaunch) {
      return const Positioned(
        right: 4,
        top: 0,
        bottom: 0,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(right: 6),
            child: _TouchHintIconContent(),
          ),
        ),
      );
    }

    // 2. ve sonraki açılışlar: ValueListenable ile viewport-bazlı fade.
    // Kart gövdesi REBUILD OLMAZ — sadece bu küçük subtree yenilenir.
    return Positioned(
      right: 4,
      top: 0,
      bottom: 0,
      child: Center(
        child: Padding(
          padding: _kIconPadding,
          child: ValueListenableBuilder<bool>(
            valueListenable: _iconVisibilityNotifier!,
            // child parameter: _TouchHintIconContent her tick'te yeniden
            // inşa edilmez, referans olarak geçer.
            child: const _TouchHintIconContent(),
            builder: (context, visible, child) {
              return AnimatedOpacity(
                opacity: visible ? 1.0 : 0.0,
                duration: _kFadeDuration,
                curve: Curves.easeOut,
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBookServiceButton() {
    return GestureDetector(
      onTap: () {
        Go.to(context, HistoryPage());
      },
      child: Container(
        width: double.infinity,
        padding: _kBookButtonPadding,
        decoration: BoxDecoration(
          color: AppColors.primaryBlack,
          borderRadius: _kBookButtonRadius,
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Center(
          child: Text(
            AppTranslation.translate(AppStrings.bookServiceSlot),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryWhite,
            ),
          ),
        ),
      ),
    );
  }
}

/// İkon içeriği — hem statik hem animasyonlu modda aynı.
/// Const constructor sayesinde widget reuse edilir.
class _TouchHintIconContent extends StatelessWidget {
  const _TouchHintIconContent();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.touch_app_rounded,
      size: 17,
      color: Colors.grey.shade400,
    );
  }
}