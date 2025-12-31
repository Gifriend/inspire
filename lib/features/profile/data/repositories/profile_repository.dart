import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/data_sources/network/dio_client.dart';
import 'package:inspire/core/models/user/user_model.dart';

abstract class ProfileRepository {
  Future<UserModel> getProfile();
}

class ProfileRepositoryImpl implements ProfileRepository {
  final DioClient _dioClient;

  ProfileRepositoryImpl(this._dioClient);

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        Endpoint.profile,
      );

      if (response == null) {
        throw DioException(
          requestOptions: RequestOptions(path: Endpoint.profile),
          error: 'Response is null',
        );
      }

      return UserModel.fromJson(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized');
      }
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(dioClientProvider));
});
