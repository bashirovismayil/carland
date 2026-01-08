class ApiConstants {
  ApiConstants._();

  static const baseUrl = 'https://digital-innovation.agency';

  // Device token
  static const deviceToken =
      '$baseUrl/hospital/server/api/v1/device-tokens/post';

  // Delete account
  static const deleteAccount = '$baseUrl/auth/server/api/v1/users/delete';

  // auth - SignUp
  static const register =
      '$baseUrl/auth/server/api/v1/users/register?role=user';
  static const otpCreateSend = '$baseUrl/auth/server/api/v1/otp/createAndSend';
  static const otpVerify = '$baseUrl/auth/server/api/v1/otp/verify';
  static const setPassword = '$baseUrl/auth/server/api/v1/users/setPassword';

  // Login
  static const login = '$baseUrl/auth/server/api/v1/users/login';
  static const refresh = '$baseUrl/auth/server/api/v1/users/refresh';

  // forgot password
  static const forgotPassword =
      '$baseUrl/auth/server/api/v1/users/updatePassword';

  // Boss - invite
  static const inviteRole = '$baseUrl/auth/server/api/v1/users/invite';

  static const superAdminAddDetails =
      '$baseUrl/hospital/server-hospital/api/v1/super-admin/add-details';
  static const adminAddDetails =
      '$baseUrl/hospital/server-hospital/api/v1/admin/add-details';

  // Create Calendar - Doctor
  static const createCalendar =
      '$baseUrl/hospital/server-hospital/api/v1/calendar/create';

  // Get Admin Details
  static const getAdminDetails =
      '$baseUrl/hospital/server-hospital/api/v1/admin/profile/get';

  // Get Super Admin Details
  static const getSuperAdminDetails =
      '$baseUrl/hospital/server-hospital/api/v1/super-admin/profile/get';

  // Update Patient Details
  static const updatePatientDetails =
      '$baseUrl/hospital/server-hospital/api/v1/patient/update/profile';

  // Update Admin Details
  static const updateAdminDetails =
      '$baseUrl/hospital/server-hospital/api/v1/admin/update/profile';

  // Update Super Admin Details
  static const updateSuperAdminDetails =
      '$baseUrl/hospital/server-hospital/api/v1/super-admin/update/profile';

  // User add details
  static const userAddDetails =
      '$baseUrl/carland/server-carland/api/v1/user/add-details';

  // Profile photo
  static const uploadProfilePhoto =
      '$baseUrl/carland/server-carland/api/v1/photo/for/user/upload';
  static const getProfilePhoto =
      '$baseUrl/carland/server-carland/api/v1/photo/for/user/get';
  static const deleteProfilePhoto =
      '$baseUrl/carland/server-carland/api/v1/photo/for/user/delete';

  // Check VIN
  static const checkVin =
      '$baseUrl/carland/server-carland/api/v1/car/check/vin?vin=';

  static const getColorList =
      '$baseUrl/carland/server-carland/api/v1/car/get/color/list';

  static const getCarPhoto =
      '$baseUrl/carland/server-carland/api/v1/photo/for/car/get?carId=';

  static const getEngineTypeList =
      '$baseUrl/carland/server-carland/api/v1/group/by/get/engine/type/list';

  static const bodyTypeList =
      '$baseUrl/carland/server-carland/api/v1/group/by/get/body/list';

  static const transmissionTypeList =
      '$baseUrl/carland/server-carland/api/v1/group/by/get/transmission/list';

  static const getYearList =
      '$baseUrl/carland/server-carland/api/v1/group/by/get/year/list';

  static const updateCarMileage =
      '$baseUrl/carland/server-carland/api/v1/car/update/mileage';

  static const uploadCarPhoto =
      '$baseUrl/carland/server-carland/api/v1/photo/for/car/upload?carId=';

  static const addCar = '$baseUrl/carland/server-carland/api/v1/car/add';

  static const getCarRecords =
      '$baseUrl/carland/server-carland/api/v1/car/get/service/records?carId=';

  static const updateCarRecord =
      '$baseUrl/carland/server-carland/api/v1/car/update/record';

  static const getCarList =
      '$baseUrl/carland/server-carland/api/v1/car/get/list/by/user';

  static const getCarServices =
      '$baseUrl/carland/server-carland/api/v1/car/service/percentages?carId=';

  static const editCarServiceDetails =
      '$baseUrl/carland/server-carland/api/v1/car/service/edit/percentage';

  static const editCarDetails =
      '$baseUrl/carland/server-carland/api/v1/car/edit/details';

  static const executeCarService =
      '$baseUrl/carland/server-carland/api/v1/car/service/execute/percentages?carId=';

  static const deleteCar = '$baseUrl/carland/server-carland/api/v1/car/remove';

  static const privacyPolicy =
      '$baseUrl/carland/legal/legal/privacy/policy?lang=';
  static const termsConditions =
      '$baseUrl/carland/legal/legal/terms-and-conditions?lang=';
}
