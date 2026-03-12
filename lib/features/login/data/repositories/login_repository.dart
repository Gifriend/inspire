import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/data_sources/data_sources.dart';
import 'package:inspire/core/models/models.dart';
import 'package:inspire/core/data_sources/network/network.dart';

part 'login_repository.g.dart';

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

      final envelope = ApiEnvelope.fromDynamic<AuthData>(
        response,
        dataParser: (data) => AuthData.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Login gagal',
      );

      return envelope.data;
    } on DioException catch (e) {
      final apiException = ApiException.from(e, fallbackMessage: 'Identifier atau password salah');
      throw Exception(apiException.message);
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

      final envelope = ApiEnvelope.fromDynamic<AuthData>(
        response,
        dataParser: (data) => AuthData.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Refresh token gagal',
      );

      return envelope.data;
    } on DioException catch (e) {
      final apiException = ApiException.from(e, fallbackMessage: 'Refresh token tidak valid');
      throw Exception(apiException.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}

@riverpod
LoginRepository loginRepository(Ref ref) {
  return LoginRepositoryImpl(ref.watch(dioClientProvider));
}
