import 'dart:io';

import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://makemydaybackend-production.up.railway.app",
      // baseUrl: "http://192.168.1.20:3000",
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
    ),
  );

  ApiService() {
    // Interceptor to prefer IPv4 addresses when making requests. This rewrites
    // the request URL to use the resolved IPv4 address and sets the original
    // host in the Host header. This can fix issues where mobile networks
    // have different DNS/IPv6 behavior compared to WiFi.
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      try {
        final uri = options.uri; // resolved uri (baseUrl + path)
        final host = uri.host;
        // Lookup IPv4 addresses for the host
        final addresses = await InternetAddress.lookup(host, type: InternetAddressType.IPv4);
        if (addresses.isNotEmpty) {
          final ip = addresses.first.address;
          final newUri = uri.replace(host: ip);
          // Set Host header to original host so TLS/SNI and virtual hosting work
          options.headers['host'] = host;
          // Replace the path with an absolute URL pointing to the IP
          options.path = newUri.toString();
        }
      } catch (e) {
        // Ignore and let Dio use the original URL
      }
      handler.next(options);
    }));
  }

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
  Future<dynamic> postRequest(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, dynamic>? headers,
  }) async {
    try {
      Options? options;
      if (headers != null) {
        options = Options(headers: headers);
      }
      Response response = await _dio.post(endpoint, data: data, options: options);
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
