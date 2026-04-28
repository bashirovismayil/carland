import 'package:flutter/material.dart';
import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/constants/values/app_theme.dart';
import '../../../../../core/localization/app_translation.dart';
import '../../../../../core/mixins/animated_list_mixin.dart';
import '../../../../../data/remote/models/remote/get_car_services_response.dart';
import '../../../../../data/remote/services/local/hidden_services_local_service.dart';
import '../../../../../data/remote/services/local/peek_hint_local_service.dart';
import '../../../../../utils/di/locator.dart';
import '../../../../../utils/helper/service_edit_helper.dart';
import '../../../../../utils/helper/service_percentage_calculator.dart';
import 'service_card.dart';
import 'services_list_header.dart';

class ServicesList extends StatefulWidget {
  final List<ResponseList> services;
  final int carId;
  final bool isLoading;
  final VoidCallback onRefresh;
  final ScrollController scrollController;
  final int? carModelYear;
  final int? currentMileage;

  const ServicesList({
    super.key,
    required this.services,
    required this.carId,
    required this.isLoading,
    required this.onRefresh,
    required this.scrollController,
    this.carModelYear,
    this.currentMileage,
  });

  @override
  State<ServicesList> createState() => _ServicesListState();
}

class _ServicesListState extends State<ServicesList>
    with TickerProviderStateMixin, AnimatedListReorderMixin {
  final _hiddenServicesService = locator<HiddenServicesLocalService>();
  final _peekHintService = locator<PeekHintLocalService>();
  bool _hiddenSectionExpanded = false;
  int? _expandedPercentageId;
  bool _peekHintTriggered = false;
  int? _peekTargetId;

  List<ResponseList>? _cachedSorted;
  List<ResponseList>? _cachedVisible;
  List<ResponseList>? _cachedHidden;

  @override
  void initState() {
    super.initState();
    initReorderAnimation();
    if (_peekHintService.isFirstAppLaunch) {
      _peekHintService.markFirstAppLaunchConsumed();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keys = _visibleServices.map((s) => s.percentageId).toList();
      handleReorder(keys);
      _resolvePeekTarget();
    });
  }

  @override
  void didUpdateWidget(covariant ServicesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.services != widget.services) {
      _invalidateAllCaches('services reference changed');
      final newVisibleKeys =
      _visibleServices.map((s) => s.percentageId).toList();
      handleReorder(newVisibleKeys);
      _peekHintTriggered = false;
      _peekTargetId = null;
      _resolvePeekTarget();
    }
  }

  void _invalidateAllCaches(String reason) {
    _cachedSorted = null;
    _cachedVisible = null;
    _cachedHidden = null;
    debugPrint('[SVC_LIST] caches invalidated (all) reason="$reason"');
  }

  void _invalidateHiddenPartitioning(String reason) {
    // sort sırası aynı, sadece visible/hidden partitioning değişir.
    _cachedVisible = null;
    _cachedHidden = null;
    debugPrint(
      '[SVC_LIST] caches invalidated (visible+hidden) reason="$reason"',
    );
  }

  void _resolvePeekTarget() {
    if (_peekHintTriggered) return;
    if (!_peekHintService.shouldShowPeekHint) return;

    final candidates = _visibleServices
        .where((s) => !ServiceEditHelper.needsEdit(s))
        .toList();

    if (candidates.isNotEmpty) {
      _peekTargetId = candidates.first.percentageId;
      _peekHintTriggered = true;
      debugPrint('[SVC_LIST] peek target set: $_peekTargetId');
      setState(() {});
    }
  }

  void _onPeekHintComplete() {
    _peekHintService.incrementPeekCount();
  }

  @override
  void dispose() {
    disposeReorderAnimation();
    super.dispose();
  }

  // === CACHE'Lİ GETTER'LAR ===

  List<ResponseList> get _sortedServices {
    final cached = _cachedSorted;
    if (cached != null) return cached;

    debugPrint('[SVC_LIST] sorting services (cache miss, n=${widget.services.length})');
    final sorted = List<ResponseList>.from(widget.services)
      ..sort((a, b) {
        final aNeedsEdit = ServiceEditHelper.needsEdit(a);
        final bNeedsEdit = ServiceEditHelper.needsEdit(b);
        if (aNeedsEdit != bNeedsEdit) {
          return aNeedsEdit ? 1 : -1;
        }
        return ServicePercentageCalculator.getEffectivePercentage(a)
            .compareTo(ServicePercentageCalculator.getEffectivePercentage(b));
      });
    _cachedSorted = sorted;
    return sorted;
  }

  List<ResponseList> get _visibleServices {
    final cached = _cachedVisible;
    if (cached != null) return cached;
    final v = _sortedServices
        .where((s) => !_hiddenServicesService.isHidden(s.percentageId))
        .toList(growable: false);
    _cachedVisible = v;
    return v;
  }

  List<ResponseList> get _hiddenServices {
    final cached = _cachedHidden;
    if (cached != null) return cached;
    final h = _sortedServices
        .where((s) => _hiddenServicesService.isHidden(s.percentageId))
        .toList(growable: false);
    _cachedHidden = h;
    return h;
  }

  void _onToggleHidden(int percentageId) {
    final wasVisible = !_hiddenServicesService.isHidden(percentageId);
    _hiddenServicesService.toggleHidden(percentageId);
    _invalidateHiddenPartitioning('hidden toggled id=$percentageId');
    setState(() {});

    if (wasVisible) {
      _showHiddenSnackBar();
    }
  }

  void _onCardExpanded(int percentageId) {
    if (_expandedPercentageId != percentageId) {
      setState(() => _expandedPercentageId = percentageId);
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

  List<WidgetBuilder> _buildItemBuilders() {
    final builders = <WidgetBuilder>[];
    final visible = _visibleServices;
    final hidden = _hiddenServices;

    builders.add((ctx) => ServicesListHeader(isLoading: widget.isLoading));
    builders.add((ctx) => const SizedBox(height: 12));

    for (var i = 0; i < visible.length; i++) {
      final service = visible[i];
      builders.add((ctx) {
        debugPrint('[SVC_LIST] build visible card id=${service.percentageId}');
        return buildAnimatedItem(
          itemKey: service.percentageId,
          child: _buildServiceCard(service, isHidden: false),
        );
      });
      final isLast = i == visible.length - 1;
      if (!isLast || hidden.isNotEmpty) {
        builders.add((ctx) => const SizedBox(height: 16));
      }
    }

    if (hidden.isNotEmpty) {
      builders.add((ctx) => _buildHiddenServicesDivider(hidden.length));
      if (_hiddenSectionExpanded) {
        builders.add((ctx) => const SizedBox(height: 16));
        for (var i = 0; i < hidden.length; i++) {
          final service = hidden[i];
          builders.add((ctx) {
            debugPrint(
              '[SVC_LIST] build hidden card id=${service.percentageId}',
            );
            return _buildServiceCard(service, isHidden: true);
          });
          if (i != hidden.length - 1) {
            builders.add((ctx) => const SizedBox(height: 16));
          }
        }
      }
    }

    return builders;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[SVC_LIST] build() — assembling item builders');
    final builders = _buildItemBuilders();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          debugPrint(
            '[SVC_LIST] itemBuilder index=$index/${builders.length}',
          );
          return builders[index](context);
        },
        childCount: builders.length,
      ),
    );
  }

  Widget _buildServiceCard(ResponseList service, {required bool isHidden}) {
    final needsEdit = ServiceEditHelper.needsEdit(service);
    final shouldPeek = _peekTargetId == service.percentageId;

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
          carModelYear: widget.carModelYear,
          currentMileage: widget.currentMileage,
          onExpand:
          needsEdit ? () => _onCardExpanded(service.percentageId) : null,
          isForceCollapsed: needsEdit &&
              _expandedPercentageId != null &&
              _expandedPercentageId != service.percentageId,
          shouldPeekHint: shouldPeek,
          onPeekHintComplete: shouldPeek ? _onPeekHintComplete : null,
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
                final target = (sc.offset + 250)
                    .clamp(0.0, sc.position.maxScrollExtent);
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
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility_off_outlined,
                      size: 16, color: Colors.grey.shade700),
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