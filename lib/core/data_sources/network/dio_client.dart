import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/constants/constants.dart';
import '../data_sources.dart';

class DioClient {
  late Dio _dio;
  late Dio _refreshDio;
  late String baseUrl;
  late HiveService hiveService;
  Future<AuthData?>? _refreshingAuth;

  DioClient({
    required this.baseUrl,
    required Dio dio,
    required this.hiveService,
    bool withAuth = true,
    Duration defaultConnectTimeout = const Duration(minutes: 2),
    Duration defaultReceiveTimeout = const Duration(minutes: 2),
  }) {
    _dio = dio;
    _refreshDio = Dio();
    _dio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout = defaultConnectTimeout
      ..options.receiveTimeout = defaultReceiveTimeout
      ..httpClientAdapter
      ..options.headers = {'Content-Type': 'application/json; charset=UTF-8'};

    _refreshDio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout = defaultConnectTimeout
      ..options.receiveTimeout = defaultReceiveTimeout
      ..options.headers = {'Content-Type': 'application/json; charset=UTF-8'};

    // _tokenDio = Dio();
    // _tokenDio.options = _dio.options;

    if (withAuth) {
      _dio.interceptors.add(
        QueuedInterceptorsWrapper(
          onRequest: (
            RequestOptions options,
            RequestInterceptorHandler handler,
          ) async {
            final auth = await hiveService.getAuth();
            if (auth != null) {
              options.headers['Authorization'] = 'Bearer ${auth.accessToken}';
            }

            // Leave body encoding to Dio. Removing manual json.encode to avoid
            // double-encoding (sending a JSON string instead of JSON object).
            // If callers need special handling (e.g., multipart), they should
            // provide the appropriate `Options` or data format.
            handler.next(options);
          },
          onError: (
            DioException error,
            ErrorInterceptorHandler handler,
          ) async {
            final requestOptions = error.requestOptions;
            final statusCode = error.response?.statusCode;
            final alreadyRetried = requestOptions.extra['_retried'] == true;
            final isAuthEndpoint = requestOptions.path.contains('/auth/login') ||
                requestOptions.path.contains('/auth/refresh');

            if (statusCode == 401 && !alreadyRetried && !isAuthEndpoint) {
              try {
                final refreshedAuth = await _refreshAuth();
                if (refreshedAuth != null) {
                  requestOptions.headers['Authorization'] =
                      'Bearer ${refreshedAuth.accessToken}';
                  requestOptions.extra['_retried'] = true;

                  final response = await _dio.fetch<dynamic>(requestOptions);
                  handler.resolve(response);
                  return;
                }
              } catch (refreshError) {
                debugPrint('[DioClient] Refresh token failed: $refreshError');
              }
            }

            handler.next(error);
          },
        ),
      );
    }

    if (kDebugMode) {
      final logInterceptor = LogInterceptor(
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: false,
        request: false,
        requestBody: true,
        logPrint: (obj) {
          log(obj.toString());
        },
      );
      _dio.interceptors.add(logInterceptor);
      _dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: false));


    }
  }

  Future<T?> get<T>(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await _dio.get<T>(
        uri,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<T?> post<T>(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await _dio.post<T>(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<T?> patch<T>(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await _dio.patch<T>(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<T?> put<T>(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await _dio.put<T>(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<T?> delete<T>(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      var response = await _dio.delete<T>(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  // Special method for downloading binary files (PDF, images, etc)
  Future<List<int>> downloadBytes(
    String uri, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await _dio.get<List<int>>(
        uri,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: onReceiveProgress,
      );
      
      final data = response.data;
      if (data == null) {
        throw Exception('No data received from server');
      }
      
      // Ensure we have List<int> (Uint8List is a subclass of List<int>)
      debugPrint('Downloaded ${data.length} bytes');
      return data;
        } on SocketException catch (e) {
      throw SocketException(e.toString());
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthData?> _refreshAuth() async {
    if (_refreshingAuth != null) {
      return _refreshingAuth;
    }

    final completer = Completer<AuthData?>();
    _refreshingAuth = completer.future;

    try {
      final currentAuth = await hiveService.getAuth();
      if (currentAuth == null || currentAuth.refreshToken.isEmpty) {
        completer.complete(null);
        return completer.future;
      }

      final response = await _refreshDio.post<dynamic>(
        Endpoint.refresh,
        data: {'refreshToken': currentAuth.refreshToken},
      );

      final responseData = response.data;
      if (responseData == null) {
        throw const ApiException(message: 'Refresh token gagal');
      }

      final authData = ApiEnvelope.fromDynamic<AuthData>(
        responseData,
        dataParser: (data) => AuthData.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Refresh token gagal',
      ).data;

      await hiveService.saveAuth(authData);
      completer.complete(authData);
      return authData;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _refreshingAuth = null;
    }
  }
}

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    dio: Dio(),
    hiveService: ref.watch(hiveServiceProvider),
    baseUrl: Endpoint.baseUrl,
    defaultConnectTimeout: const Duration(minutes: 3),
    defaultReceiveTimeout: const Duration(minutes: 3),
  );
});
