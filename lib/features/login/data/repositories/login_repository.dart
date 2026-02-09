import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/data_sources/data_sources.dart';
import 'package:inspire/core/models/models.dart';

import '../../../../core/data_sources/network/dio_client.dart';

abstract class LoginRepository {
  Future<AuthData> login({required String identifier, required String password, String? fcmToken});
  Future<AuthData> refreshToken({required String refreshToken});
}

class LoginRepositoryImpl implements LoginRepository {
  final DioClient _dioClient;

  LoginRepositoryImpl(this._dioClient);

  @override
  Future<AuthData> login({
    required String identifier,
    required String password,
    String? fcmToken,
  }) async {
    try {
      final request = LoginRequest(identifier: identifier, password: password, fcmToken: fcmToken);
      final response = await _dioClient.post<Map<String, dynamic>>(
        Endpoint.login,
        data: request.toJson(),
      );

      if (response == null) {
        throw DioException(
          requestOptions: RequestOptions(path: Endpoint.login),
          error: 'Response is null',
        );
      }

      return AuthData.fromJson(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Identifier atau password salah');
      }
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  @override
  Future<AuthData> refreshToken({required String refreshToken}) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response == null) {
        throw DioException(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          error: 'Response is null',
        );
      }

      return AuthData.fromJson(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Refresh token tidak valid');
      }
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}

final loginRepositoryProvider = Provider<LoginRepository>((ref) {
  return LoginRepositoryImpl(ref.watch(dioClientProvider));
});
