// import 'package:dio/dio.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
//
// final publicDio = Dio()
//   ..options.baseUrl = 'https://digital-innovation.agency'
//   ..options.connectTimeout = const Duration(seconds: 30)
//   ..options.receiveTimeout = const Duration(seconds: 30)
//   ..interceptors.addAll([
//     PrettyDioLogger(
//       requestHeader: true,
//       requestBody: true,
//       responseBody: true,
//       responseHeader: false,
//       error: true,
//       compact: true,
//     ),
//   ]);