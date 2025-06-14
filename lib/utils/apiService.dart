import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "https://makemydaybackend-production.up.railway.app",
    // baseUrl: "http://192.168.1.20:3000",
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    headers: {"Content-Type": "application/json"},
  ));

  // GET Request
  Future<dynamic> getRequest(String endpoint) async { 
    try {
      Response response = await _dio.get(endpoint);
      return response.data;
    } catch (e) { 
      _handleError(e);
    }
  }

  // POST Request
  Future<dynamic> postRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      Response response = await _dio.post(endpoint, data: data);
      return response.data;
    } catch (e) {
      _handleError(e);
    }
  }

  // PUT Request
  Future<dynamic> putRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      Response response = await _dio.put(endpoint, data: data);
      return response.data;
    } catch (e) {
      _handleError(e);
    }
  }

  // DELETE Request
  Future<dynamic> deleteRequest(String endpoint) async {
    try {
      Response response = await _dio.delete(endpoint);
      return response.data;
    } catch (e) {
      _handleError(e);
    }
  }

  // Error Handler
  void _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          throw Exception("Connection Timeout");
        case DioExceptionType.receiveTimeout:
          throw Exception("Receive Timeout");
        case DioExceptionType.badResponse:
          throw Exception("Bad Response: ${error.response?.statusCode}");
        default:
          throw Exception("Unexpected Error: ${error.message}");
      }
    } else {
      throw Exception("Unknown Error: $error");
    }
  }
}