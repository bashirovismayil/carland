import '../models/remote/delete_car_response.dart';

abstract class DeleteCarContractor {
  Future<DeleteCarResponse> deleteCar({required int carId});
}