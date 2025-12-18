import 'dart:typed_data';
import '../models/remote/get_car_list_response.dart';

abstract class GetCarListContractor {
  Future<List<GetCarListResponse>> getCarList();
}