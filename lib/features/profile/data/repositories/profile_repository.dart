import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/data_sources/network/dio_client.dart';
import 'package:inspire/core/data_sources/network/network.dart';
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

      final envelope = ApiEnvelope.fromDynamic<UserModel>(
        response,
        dataParser: (data) => UserModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memuat profil',
      );

      return envelope.data;
    } on DioException catch (e) {
      final apiException = ApiException.from(e, fallbackMessage: 'Gagal memuat profil');
      throw Exception(apiException.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(dioClientProvider));
});
