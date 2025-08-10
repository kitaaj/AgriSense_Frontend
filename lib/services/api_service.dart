import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/farm_model.dart';
import '../utils/logger.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _accessToken;
  String? _refreshToken;

  // Initialize the API service
  Future<void> initialize() async {
    _dio = Dio(BaseOptions(
      baseUrl: _getBaseUrl(),
      connectTimeout: Duration(seconds: AppConstants.connectionTimeout),
      receiveTimeout: Duration(seconds: AppConstants.receiveTimeout),
      sendTimeout: Duration(seconds: AppConstants.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => AppLogger.debug(object.toString()),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add authorization header if token exists
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle token expiration
        if (error.response?.statusCode == 401) {
          if (await _refreshAccessToken()) {
            // Retry the request with new token
            final options = error.requestOptions;
            options.headers['Authorization'] = 'Bearer $_accessToken';
            try {
              final response = await _dio.fetch(options);
              handler.resolve(response);
              return;
            } catch (e) {
              // If retry fails, proceed with original error
            }
          }
        }
        handler.next(error);
      },
    ));

    // Load stored tokens
    await _loadTokens();
  }

  String _getBaseUrl() {
    if (Platform.isAndroid) {
      return AppConstants.baseUrl;
    } else if (Platform.isIOS) {
      return AppConstants.baseUrlIOS;
    } else {
      return AppConstants.baseUrlProduction;
    }
  }

  Future<void> _loadTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(AppConstants.accessTokenKey);
      _refreshToken = prefs.getString(AppConstants.refreshTokenKey);
    } catch (e) {
      AppLogger.error('Failed to load tokens: $e');
    }
  }

  Future<void> _saveTokens(String accessToken, [String? refreshToken]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = accessToken;
      await prefs.setString(AppConstants.accessTokenKey, accessToken);

      if (refreshToken != null) {
        _refreshToken = refreshToken;
        await prefs.setString(AppConstants.refreshTokenKey, refreshToken);
      }
    } catch (e) {
      AppLogger.error('Failed to save tokens: $e');
    }
  }

  Future<void> _clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = null;
      _refreshToken = null;
      await prefs.remove(AppConstants.accessTokenKey);
      await prefs.remove(AppConstants.refreshTokenKey);
    } catch (e) {
      AppLogger.error('Failed to clear tokens: $e');
    }
  }

  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await _dio.post(
        AppConstants.refreshTokenEndpoint,
        options: Options(
          headers: {'Authorization': 'Bearer $_refreshToken'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _saveTokens(data['access_token']);
        return true;
      }
    } catch (e) {
      AppLogger.error('Failed to refresh token: $e');
      await _clearTokens();
    }
    return false;
  }

  // Authentication methods
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        AppConstants.loginEndpoint,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _saveTokens(authResponse.accessToken, authResponse.refreshToken);

      return authResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        AppConstants.registerEndpoint,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _saveTokens(authResponse.accessToken, authResponse.refreshToken);

      return authResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(AppConstants.logoutEndpoint);
    } catch (e) {
      AppLogger.warning('Logout request failed: $e');
    } finally {
      await _clearTokens();
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get(AppConstants.currentUserEndpoint);
      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Farm management methods
  Future<FarmsListResponse> getFarms() async {
    try {
      final response = await _dio.get(AppConstants.farmsEndpoint);
      return FarmsListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<FarmResponse> createFarm(CreateFarmRequest request) async {
    try {
      final response = await _dio.post(
        AppConstants.farmsEndpoint,
        data: request.toJson(),
      );
      return FarmResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Farm> getFarm(int farmId) async {
    try {
      final response = await _dio.get('${AppConstants.farmsEndpoint}/$farmId');
      return Farm.fromJson(response.data['farm']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<FarmResponse> updateFarm(int farmId, UpdateFarmRequest request) async {
    try {
      final response = await _dio.put(
        '${AppConstants.farmsEndpoint}/$farmId',
        data: request.toJson(),
      );
      return FarmResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteFarm(int farmId) async {
    try {
      await _dio.delete('${AppConstants.farmsEndpoint}/$farmId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<FarmStatsResponse> getFarmStats(int farmId) async {
    try {
      final response =
          await _dio.get('${AppConstants.farmsEndpoint}/$farmId/stats');
      return FarmStatsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Soil analysis methods
  Future<Map<String, dynamic>> analyzeSoil(int farmId,
      [Map<String, dynamic>? data]) async {
    try {
      final response = await _dio.post(
        '${AppConstants.farmsEndpoint}/$farmId${AppConstants.soilAnalysisEndpoint}',
        data: data ?? {},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getAllUserSoilAnalyses(
      {int? limit, int? offset}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _dio.get(
        '/soil-analyses', // The new endpoint
        queryParameters: queryParams,
      );
      // AppLogger.info(
      //     'Fetched all user soil analyses with limit: $limit, offset: $offset : ${response.data}');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getFarmSoilAnalyses(int farmId,
      {int? limit, int? offset}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _dio.get(
        '${AppConstants.farmsEndpoint}/$farmId/soil-analyses',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getSoilAnalysis(int analysisId) async {
    try {
      final response = await _dio.get('/soil-analyses/$analysisId');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getFarmSoilHealthSummary(int farmId) async {
    try {
      final response = await _dio
          .get('${AppConstants.farmsEndpoint}/$farmId/soil-health-summary');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Utility methods
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await _dio.get(AppConstants.dashboardEndpoint);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> search(String query) async {
    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {'q': query},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<UserProfile> getProfile() async {
    try {
      final response = await _dio.get(AppConstants.profileEndpoint);
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await _dio.put(
        AppConstants.profileEndpoint,
        data: request.toJson(),
      );
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      await _dio.post(
        '/change-password',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getStatistics([int days = 30]) async {
    try {
      final response = await _dio.get(
        AppConstants.statisticsEndpoint,
        queryParameters: {'days': days},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getAppInfo() async {
    try {
      final response = await _dio.get('/app-info');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Helper methods
  bool get isAuthenticated => _accessToken != null;

  String? get accessToken => _accessToken;

  Exception _handleDioError(DioException error) {
    String message;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = AppConstants.networkErrorMessage;
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        if (statusCode == 401) {
          message = AppConstants.authenticationErrorMessage;
        } else if (statusCode != null && statusCode >= 500) {
          message = AppConstants.serverErrorMessage;
        } else if (responseData is Map && responseData.containsKey('message')) {
          message = responseData['message'];
        } else if (responseData is Map && responseData.containsKey('error')) {
          message = responseData['error'];
        } else {
          message = AppConstants.validationErrorMessage;
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;
      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          message = AppConstants.networkErrorMessage;
        } else {
          message = AppConstants.serverErrorMessage;
        }
        break;
    }

    AppLogger.error('API Error: $message', error);
    return Exception(message);
  }
}
