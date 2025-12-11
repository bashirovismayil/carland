class ApiConstants {
  ApiConstants._();

  static const baseUrl = 'https://digital-innovation.agency';

  // Device token
  static const deviceToken =
      '$baseUrl/hospital/server/api/v1/device-tokens/post';

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
  static const doctorAddDetails =
      '$baseUrl/hospital/server-hospital/api/v1/doctor/add-details';
  static const patientAddDetails =
      '$baseUrl/hospital/server-hospital/api/v1/patient/add-details';

  // Create Calendar - Doctor
  static const createCalendar =
      '$baseUrl/hospital/server-hospital/api/v1/calendar/create';

  // Get User Details
  static const getPatientDetails =
      '$baseUrl/hospital/server-hospital/api/v1/patient/profile/get';

  // Get Doctor Details
  static const getDoctorDetails =
      '$baseUrl/hospital/server-hospital/api/v1/doctor/profile/get';

  // Get Admin Details
  static const getAdminDetails =
      '$baseUrl/hospital/server-hospital/api/v1/admin/profile/get';

  // Get Super Admin Details
  static const getSuperAdminDetails =
      '$baseUrl/hospital/server-hospital/api/v1/super-admin/profile/get';

  // Update Patient Details
  static const updatePatientDetails =
      '$baseUrl/hospital/server-hospital/api/v1/patient/update/profile';

  // Update Doctor Details
  static const updateDoctorDetails =
      '$baseUrl/hospital/server-hospital/api/v1/doctor/update/profile';

  // Doctor work status
  static const updateDoctorWorkStatus =
      '$baseUrl/hospital/server-hospital/api/v1/doctor/set/availability?atWork=';

  // Update Admin Details
  static const updateAdminDetails =
      '$baseUrl/hospital/server-hospital/api/v1/admin/update/profile';

  // Update Super Admin Details
  static const updateSuperAdminDetails =
      '$baseUrl/hospital/server-hospital/api/v1/super-admin/update/profile';

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
}