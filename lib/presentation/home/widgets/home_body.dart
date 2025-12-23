import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../cubit/add/car/get_car_list_cubit.dart';
import '../../../cubit/add/car/get_car_list_state.dart';
import 'add_car_button.dart';
import 'car_list_view.dart';
import 'empty_state.dart';
import 'home_header.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  @override
  void initState() {
    super.initState();
    _loadCarList();
  }

  void _loadCarList() => context.read<GetCarListCubit>().getCarList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeHeader(),
          const SizedBox(height: 24),
          Expanded(child: _buildContent()),
          const SizedBox(height: 5),
          AddCarButton(onCarAdded: _loadCarList),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<GetCarListCubit, GetCarListState>(
      builder: (context, state) => switch (state) {
        GetCarListLoading() => const _LoadingIndicator(),
        GetCarListSuccess(:final carList) when carList.isNotEmpty =>
            CarListView(carList: carList, onRefresh: _loadCarList),
        _ => const EmptyState(),
      },
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryBlack),
    );
  }
}