// ===== 1. NETWORKING SERVICE (networking_service.dart) =====
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NetworkingService {
  static final NetworkingService _instance = NetworkingService._internal();
  factory NetworkingService() => _instance;
  NetworkingService._internal();

  final http.Client _client = http.Client();
  final Connectivity _connectivity = Connectivity();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Base URL untuk API - menggunakan IP lokal Anda
  static const String _baseUrl = 'http://192.168.56.1:8000/api';
  
  // Headers default
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'SmartComp-Admin-App',
  };

  // Network monitoring
  Stream<ConnectivityResult> get connectivityStream => 
      _connectivity.onConnectivityChanged;

  // Get current connectivity status
  Future<ConnectivityResult> getCurrentConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return ConnectivityResult.none;
    }
  }

  // GET Request with comprehensive error handling
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
    Duration timeout = const Duration(seconds: 30),
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Check connectivity first
      final connectivity = await getCurrentConnectivity();
      if (connectivity == ConnectivityResult.none) {
        throw NetworkException('No internet connection available');
      }

      // Build URL dengan query parameters
      final url = _buildUrl(endpoint, queryParams);
      
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          ..._defaultHeaders,
          ...?headers,
        },
      ).timeout(timeout, onTimeout: () {
        throw NetworkException('Request timeout after ${timeout.inSeconds} seconds');
      });

      stopwatch.stop();

      return _handleResponse<T>(
        response, 
        stopwatch.elapsedMilliseconds,
        fromJson,
      );
    } catch (e) {
      stopwatch.stop();
      return ApiResponse.error(
        _handleError(e),
        stopwatch.elapsedMilliseconds,
      );
    }
  }

  // POST Request with comprehensive error handling
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final connectivity = await getCurrentConnectivity();
      if (connectivity == ConnectivityResult.none) {
        throw NetworkException('No internet connection available');
      }

      final url = _buildUrl(endpoint);
      
      final response = await _client.post(
        Uri.parse(url),
        headers: {
          ..._defaultHeaders,
          ...?headers,
        },
        body: body != null ? json.encode(body) : null,
      ).timeout(timeout, onTimeout: () {
        throw NetworkException('Request timeout after ${timeout.inSeconds} seconds');
      });

      stopwatch.stop();

      return _handleResponse<T>(
        response, 
        stopwatch.elapsedMilliseconds,
        fromJson,
      );
    } catch (e) {
      stopwatch.stop();
      return ApiResponse.error(
        _handleError(e),
        stopwatch.elapsedMilliseconds,
      );
    }
  }

  // PUT Request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final connectivity = await getCurrentConnectivity();
      if (connectivity == ConnectivityResult.none) {
        throw NetworkException('No internet connection available');
      }

      final url = _buildUrl(endpoint);
      
      final response = await _client.put(
        Uri.parse(url),
        headers: {
          ..._defaultHeaders,
          ...?headers,
        },
        body: body != null ? json.encode(body) : null,
      ).timeout(timeout, onTimeout: () {
        throw NetworkException('Request timeout after ${timeout.inSeconds} seconds');
      });

      stopwatch.stop();

      return _handleResponse<T>(
        response, 
        stopwatch.elapsedMilliseconds,
        fromJson,
      );
    } catch (e) {
      stopwatch.stop();
      return ApiResponse.error(
        _handleError(e),
        stopwatch.elapsedMilliseconds,
      );
    }
  }

  // DELETE Request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final connectivity = await getCurrentConnectivity();
      if (connectivity == ConnectivityResult.none) {
        throw NetworkException('No internet connection available');
      }

      final url = _buildUrl(endpoint);
      
      final response = await _client.delete(
        Uri.parse(url),
        headers: {
          ..._defaultHeaders,
          ...?headers,
        },
      ).timeout(timeout, onTimeout: () {
        throw NetworkException('Request timeout after ${timeout.inSeconds} seconds');
      });

      stopwatch.stop();

      return _handleResponse<T>(
        response, 
        stopwatch.elapsedMilliseconds,
        fromJson,
      );
    } catch (e) {
      stopwatch.stop();
      return ApiResponse.error(
        _handleError(e),
        stopwatch.elapsedMilliseconds,
      );
    }
  }

  // Build URL dengan base URL dan query parameters
  String _buildUrl(String endpoint, [Map<String, String>? queryParams]) {
    final url = '$_baseUrl/$endpoint'.replaceAll(RegExp(r'/+'), '/').replaceFirst('http:/', 'http://');
    
    if (queryParams != null && queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      return '$url?$queryString';
    }
    
    return url;
  }

  // Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    int responseTime,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final Map<String, dynamic> responseData = {
      'statusCode': response.statusCode,
      'headers': response.headers,
      'responseTime': responseTime,
    };

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        if (response.body.isEmpty) {
          return ApiResponse.success(null as T, responseTime, responseData);
        }
        
        final jsonData = json.decode(response.body);
        final data = fromJson != null ? fromJson(jsonData) : jsonData;
        return ApiResponse.success(data, responseTime, responseData);
      } catch (e) {
        return ApiResponse.error(
          'Failed to parse response: ${e.toString()}',
          responseTime,
        );
      }
    } else {
      String errorMessage = 'HTTP ${response.statusCode}';
      try {
        final errorData = json.decode(response.body);
        errorMessage = errorData['message'] ?? 
                     errorData['error'] ?? 
                     errorMessage;
      } catch (e) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      
      return ApiResponse.error(errorMessage, responseTime);
    }
  }

  // Handle errors
  String _handleError(dynamic error) {
    if (error is SocketException) {
      return 'Network connection failed. Please check your internet connection.';
    } else if (error is HttpException) {
      return 'HTTP error occurred: ${error.message}';
    } else if (error is FormatException) {
      return 'Invalid response format received from server.';
    } else if (error is NetworkException) {
      return error.message;
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timeout. Please try again.';
    } else {
      return 'An unexpected error occurred: ${error.toString()}';
    }
  }

  // Get device information
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'model': androidInfo.model,
          'version': androidInfo.version.release,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'sdkInt': androidInfo.version.sdkInt,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'model': iosInfo.model,
          'version': iosInfo.systemVersion,
          'name': iosInfo.name,
          'device': iosInfo.utsname.machine,
        };
      }
    } catch (e) {
      return {'error': 'Failed to get device info: ${e.toString()}'};
    }
    return {'platform': 'Unknown'};
  }

  // Test network connectivity dengan IP lokal
  Future<NetworkTestResult> testNetworkConnection([String? testUrl]) async {
    final stopwatch = Stopwatch()..start();
    final url = testUrl ?? 'http://192.168.56.1:8000/api/health';
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {'Cache-Control': 'no-cache'},
      ).timeout(Duration(seconds: 10));
      
      stopwatch.stop();
      
      return NetworkTestResult(
        isConnected: response.statusCode == 200,
        responseTime: stopwatch.elapsedMilliseconds,
        statusCode: response.statusCode,
        error: null,
        testUrl: url,
      );
    } catch (e) {
      stopwatch.stop();
      return NetworkTestResult(
        isConnected: false,
        responseTime: stopwatch.elapsedMilliseconds,
        statusCode: null,
        error: _handleError(e),
        testUrl: url,
      );
    }
  }

  // Get network speed estimate untuk server lokal
  Future<NetworkSpeedResult> testNetworkSpeed() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Test dengan endpoint lokal atau fallback ke httpbin
      String testUrl = 'http://192.168.56.1:8000/api/test/speed';
      
      final response = await _client.get(
        Uri.parse(testUrl),
      ).timeout(Duration(seconds: 30));
      
      stopwatch.stop();
      
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes.length;
        final timeInSeconds = stopwatch.elapsedMilliseconds / 1000.0;
        final speedKbps = (bytes * 8) / (timeInSeconds * 1000); // Kbps
        
        return NetworkSpeedResult(
          speedKbps: speedKbps,
          responseTime: stopwatch.elapsedMilliseconds,
          bytesTransferred: bytes,
          isSuccess: true,
        );
      } else {
        // Fallback ke httpbin jika endpoint lokal tidak tersedia
        return await _testNetworkSpeedFallback();
      }
    } catch (e) {
      // Fallback ke httpbin jika server lokal tidak tersedia
      return await _testNetworkSpeedFallback();
    }
  }

  // Fallback speed test dengan external service
  Future<NetworkSpeedResult> _testNetworkSpeedFallback() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final response = await _client.get(
        Uri.parse('https://httpbin.org/bytes/1024'), // 1KB test file
      ).timeout(Duration(seconds: 30));
      
      stopwatch.stop();
      
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes.length;
        final timeInSeconds = stopwatch.elapsedMilliseconds / 1000.0;
        final speedKbps = (bytes * 8) / (timeInSeconds * 1000); // Kbps
        
        return NetworkSpeedResult(
          speedKbps: speedKbps,
          responseTime: stopwatch.elapsedMilliseconds,
          bytesTransferred: bytes,
          isSuccess: true,
        );
      } else {
        return NetworkSpeedResult(
          speedKbps: 0,
          responseTime: stopwatch.elapsedMilliseconds,
          bytesTransferred: 0,
          isSuccess: false,
          error: 'HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      final stopwatch = Stopwatch()..stop();
      return NetworkSpeedResult(
        speedKbps: 0,
        responseTime: stopwatch.elapsedMilliseconds,
        bytesTransferred: 0,
        isSuccess: false,
        error: _handleError(e),
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

// ===== 2. API RESPONSE MODELS =====

// API Response wrapper
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? error;
  final int responseTime;
  final Map<String, dynamic>? metadata;

  ApiResponse._({
    required this.isSuccess,
    this.data,
    this.error,
    required this.responseTime,
    this.metadata,
  });

  factory ApiResponse.success(T data, int responseTime, [Map<String, dynamic>? metadata]) {
    return ApiResponse._(
      isSuccess: true,
      data: data,
      responseTime: responseTime,
      metadata: metadata,
    );
  }

  factory ApiResponse.error(String error, int responseTime) {
    return ApiResponse._(
      isSuccess: false,
      error: error,
      responseTime: responseTime,
    );
  }

  @override
  String toString() {
    return 'ApiResponse{isSuccess: $isSuccess, data: $data, error: $error, responseTime: ${responseTime}ms}';
  }
}

// Network test result
class NetworkTestResult {
  final bool isConnected;
  final int responseTime;
  final int? statusCode;
  final String? error;
  final String testUrl;

  NetworkTestResult({
    required this.isConnected,
    required this.responseTime,
    this.statusCode,
    this.error,
    required this.testUrl,
  });

  @override
  String toString() {
    return 'NetworkTestResult{isConnected: $isConnected, responseTime: ${responseTime}ms, statusCode: $statusCode, testUrl: $testUrl}';
  }
}

// Network speed result
class NetworkSpeedResult {
  final double speedKbps;
  final int responseTime;
  final int bytesTransferred;
  final bool isSuccess;
  final String? error;

  NetworkSpeedResult({
    required this.speedKbps,
    required this.responseTime,
    required this.bytesTransferred,
    required this.isSuccess,
    this.error,
  });

  String get speedFormatted {
    if (speedKbps < 1000) {
      return '${speedKbps.toStringAsFixed(1)} Kbps';
    } else {
      return '${(speedKbps / 1000).toStringAsFixed(1)} Mbps';
    }
  }

  @override
  String toString() {
    return 'NetworkSpeedResult{speed: $speedFormatted, responseTime: ${responseTime}ms, bytes: $bytesTransferred}';
  }
}

// Network exception
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

// ===== 3. ENHANCED FIREBASE SERVICE WITH NETWORKING =====

class EnhancedFirebaseService {
  final NetworkingService _networkingService = NetworkingService();
  
  // Authentication token - dalam implementasi nyata ini harus dari secure storage
  String? _authToken;
  
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  Map<String, String> get _authHeaders => {
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // Test API endpoint connection dengan IP lokal
  Future<ApiResponse<Map<String, dynamic>>> testApiConnection([String? endpoint]) async {
    final testEndpoint = endpoint ?? 'health';
    return await _networkingService.get<Map<String, dynamic>>(
      testEndpoint,
      headers: _authHeaders,
      fromJson: (json) => json,
    );
  }

  // Get dashboard stats with network monitoring
  Future<ApiResponse<Map<String, int>>> getDashboardStatsWithNetworking() async {
    try {
      final response = await _networkingService.get<Map<String, dynamic>>(
        'admin/dashboard/stats',
        headers: _authHeaders,
      );

      if (response.isSuccess && response.data != null) {
        final stats = <String, int>{};
        response.data!.forEach((key, value) {
          if (value is int) {
            stats[key] = value;
          } else if (value is String) {
            stats[key] = int.tryParse(value) ?? 0;
          }
        });
        
        return ApiResponse.success(stats, response.responseTime);
      } else {
        return ApiResponse.error(
          response.error ?? 'Failed to fetch dashboard stats',
          response.responseTime,
        );
      }
    } catch (e) {
      return ApiResponse.error(e.toString(), 0);
    }
  }

  // Get all users with pagination and filtering
  Future<ApiResponse<UserListResponse>> getUsersWithNetworking({
    int page = 1,
    int limit = 50,
    String? search,
    String? status,
    String? role,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status != 'all') 'status': status,
        if (role != null && role != 'all') 'role': role,
      };

      final response = await _networkingService.get<Map<String, dynamic>>(
        'admin/users',
        headers: _authHeaders,
        queryParams: queryParams,
      );

      if (response.isSuccess && response.data != null) {
        final userListResponse = UserListResponse.fromJson(response.data!);
        return ApiResponse.success(userListResponse, response.responseTime);
      } else {
        return ApiResponse.error(
          response.error ?? 'Failed to fetch users',
          response.responseTime,
        );
      }
    } catch (e) {
      return ApiResponse.error(e.toString(), 0);
    }
  }

  // Update user status with proper error handling
  Future<ApiResponse<Map<String, dynamic>>> updateUserStatusWithNetworking(
    String userId,
    String newStatus,
  ) async {
    try {
      final response = await _networkingService.put<Map<String, dynamic>>(
        'admin/users/$userId/status',
        body: {'status': newStatus},
        headers: _authHeaders,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(e.toString(), 0);
    }
  }

  // Delete user with proper error handling
  Future<ApiResponse<Map<String, dynamic>>> deleteUserWithNetworking(
    String userId,
  ) async {
    try {
      final response = await _networkingService.delete<Map<String, dynamic>>(
        'admin/users/$userId',
        headers: _authHeaders,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(e.toString(), 0);
    }
  }

  // Create new user
  Future<ApiResponse<Map<String, dynamic>>> createUserWithNetworking(
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _networkingService.post<Map<String, dynamic>>(
        'admin/users',
        body: userData,
        headers: _authHeaders,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(e.toString(), 0);
    }
  }

  // Update user data
  Future<ApiResponse<Map<String, dynamic>>> updateUserWithNetworking(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _networkingService.put<Map<String, dynamic>>(
        'admin/users/$userId',
        body: userData,
        headers: _authHeaders,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(e.toString(), 0);
    }
  }

  // Get user details
  Future<ApiResponse<Map<String, dynamic>>> getUserDetailsWithNetworking(
    String userId,
  ) async {
    try {
      final response = await _networkingService.get<Map<String, dynamic>>(
        'admin/users/$userId',
        headers: _authHeaders,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(e.toString(), 0);
    }
  }

  // Bulk operations
  Future<ApiResponse<Map<String, dynamic>>> bulkUpdateUsersWithNetworking(
    List<String> userIds,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _networkingService.put<Map<String, dynamic>>(
        'admin/users/bulk',
        body: {
          'userIds': userIds,
          'updateData': updateData,
        },
        headers: _authHeaders,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(e.toString(), 0);
    }
  }

  // Export users data
  Future<ApiResponse<String>> exportUsersWithNetworking({
    String format = 'csv', // csv, xlsx, json
    Map<String, String>? filters,
  }) async {
    try {
      final queryParams = <String, String>{
        'format': format,
        if (filters != null) ...filters,
      };

      final response = await _networkingService.get<String>(
        'admin/users/export',
        headers: _authHeaders,
        queryParams: queryParams,
        timeout: Duration(minutes: 5), // Export might take longer
      );

      return response;
    } catch (e) {
      return ApiResponse.error(e.toString(), 0);
    }
  }
}

// ===== 4. DATA MODELS =====

class UserListResponse {
  final List<Map<String, dynamic>> users;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  UserListResponse({
    required this.users,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      users: List<Map<String, dynamic>>.from(json['users'] ?? []),
      totalCount: json['totalCount'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
    );
  }
}

// ===== 5. NETWORK UTILITY FUNCTIONS =====

class NetworkUtils {
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String formatDuration(int milliseconds) {
    if (milliseconds < 1000) return '${milliseconds}ms';
    if (milliseconds < 60000) return '${(milliseconds / 1000).toStringAsFixed(1)}s';
    return '${(milliseconds / 60000).toStringAsFixed(1)}m';
  }

  static Color getConnectionColor(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return Colors.green;
      case ConnectivityResult.mobile:
        return Colors.blue;
      case ConnectivityResult.ethernet:
        return Colors.purple;
      default:
        return Colors.red;
    }
  }

  static IconData getConnectionIcon(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return Icons.wifi;
      case ConnectivityResult.mobile:
        return Icons.signal_cellular_4_bar;
      case ConnectivityResult.ethernet:
        return Icons.cable;
      default:
        return Icons.signal_wifi_off;
    }
  }
}