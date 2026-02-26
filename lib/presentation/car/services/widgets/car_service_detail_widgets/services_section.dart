import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../cubit/services/get_services/get_car_services_cubit.dart';
import '../../../../../cubit/services/get_services/get_car_services_state.dart';
import '../../../../../data/remote/models/remote/get_car_services_response.dart';
import 'services_empty_state.dart';
import 'services_error_state.dart';
import 'services_list.dart';

class ServicesSection extends StatefulWidget {
  final bool isAddNewCarSelected;
  final VoidCallback onRefresh;
  final ScrollController scrollController;

  const ServicesSection({
    super.key,
    required this.isAddNewCarSelected,
    required this.onRefresh,
    required this.scrollController,
  });

  @override
  State<ServicesSection> createState() => _ServicesSectionState();
}

class _ServicesSectionState extends State<ServicesSection> {
  List<ResponseList>? _previousServices;

  @override
  Widget build(BuildContext context) {
    if (widget.isAddNewCarSelected) {
      return const SliverToBoxAdapter(
        child: ServicesEmptyState(isAddNewCarSelected: true),
      );
    }

    return BlocBuilder<GetCarServicesCubit, GetCarServicesState>(
      builder: (context, state) {
        if (state is GetCarServicesLoading && _previousServices == null) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlack),
            ),
          );
        }

        if (state is GetCarServicesSuccess) {
          _previousServices = state.servicesData.responseList;
          if (state.servicesData.responseList.isEmpty) {
            return const SliverToBoxAdapter(
              child: ServicesEmptyState(isAddNewCarSelected: false),
            );
          }
          return ServicesList(
            services: state.servicesData.responseList,
            carId: state.servicesData.carId ?? 0,
            isLoading: false,
            onRefresh: widget.onRefresh,
            scrollController: widget.scrollController,
          );
        }

        if (state is GetCarServicesError) {
          return SliverToBoxAdapter(
            child: ServicesErrorState(message: state.message),
          );
        }

        if (state is GetCarServicesLoading && _previousServices != null) {
          final currentState = context.read<GetCarServicesCubit>().state;
          int carId = 0;
          if (currentState is GetCarServicesSuccess) {
            carId = currentState.servicesData.carId ?? 0;
          }
          return ServicesList(
            services: _previousServices!,
            carId: carId,
            isLoading: true,
            onRefresh: widget.onRefresh,
            scrollController: widget.scrollController,
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}