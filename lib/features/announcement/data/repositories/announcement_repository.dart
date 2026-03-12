import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/data_sources/network/dio_client.dart';
import 'package:inspire/core/data_sources/network/network.dart';
import 'package:inspire/core/models/announcement/announcement_model.dart';

abstract class AnnouncementRepository {
  Future<List<AnnouncementModel>> getAnnouncements();
  Future<AnnouncementModel> getAnnouncementById(int id);
  Future<AnnouncementModel> createClassAnnouncement({
    required String judul,
    required String isi,
    required int kelasId,
  });
  Future<AnnouncementModel> createGlobalAnnouncement({
    required String judul,
    required String isi,
  });
  Future<List<AnnouncementModel>> getCoordinatorAnnouncements();
  Future<List<AnnouncementModel>> getLecturerAnnouncements({int? kelasId});
  Future<void> deleteAnnouncement(int id);
}

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final DioClient _dioClient;

  AnnouncementRepositoryImpl(this._dioClient);

  @override
  Future<List<AnnouncementModel>> getAnnouncements() async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        Endpoint.announcementMahasiswa,
      );

      if (response == null) {
        throw DioException(
          requestOptions: RequestOptions(path: Endpoint.announcementMahasiswa),
          error: 'Response is null',
        );
      }

      final envelope = ApiEnvelope.fromDynamic<List<AnnouncementModel>>(
        response,
        dataParser: (data) {
          if (data is List) {
            return data
                .map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
        defaultMessage: 'Gagal memuat pengumuman',
      );

      return envelope.data;
    } on DioException catch (e) {
      final apiException = ApiException.from(e, fallbackMessage: 'Gagal memuat pengumuman');
      throw Exception(apiException.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  @override
  Future<AnnouncementModel> getAnnouncementById(int id) async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        '${Endpoint.announcement}/$id',
      );

      if (response == null) {
        throw DioException(
          requestOptions: RequestOptions(path: '${Endpoint.announcement}/$id'),
          error: 'Response is null',
        );
      }

      final envelope = ApiEnvelope.fromDynamic<AnnouncementModel>(
        response,
        dataParser: (data) => AnnouncementModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memuat pengumuman',
      );

      return envelope.data;
    } on DioException catch (e) {
      final apiException = ApiException.from(e, 
          fallbackMessage: e.response?.statusCode == 404 
              ? 'Pengumuman tidak ditemukan' 
              : 'Gagal memuat pengumuman');
      throw Exception(apiException.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  @override
  Future<AnnouncementModel> createClassAnnouncement({
    required String judul,
    required String isi,
    required int kelasId,
  }) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        Endpoint.announcementCreate,
        data: {
          'title': judul,
          'content': isi,
          'category': 'KELAS',
          'kelasIds': [kelasId],
        },
      );

      if (response == null) {
        throw DioException(
          requestOptions: RequestOptions(path: Endpoint.announcementCreate),
          error: 'Response is null',
        );
      }

      final envelope = ApiEnvelope.fromDynamic<AnnouncementModel>(
        response,
        dataParser: (data) => AnnouncementModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal membuat pengumuman',
      );

      return envelope.data;
    } on DioException catch (e) {
      final apiException = ApiException.from(e, fallbackMessage: 'Gagal membuat pengumuman');
      throw Exception(apiException.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  @override
  Future<AnnouncementModel> createGlobalAnnouncement({
    required String judul,
    required String isi,
  }) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        Endpoint.announcementCreate,
        data: {'title': judul, 'content': isi, 'category': 'GLOBAL'},
      );

      if (response == null) {
        throw DioException(
          requestOptions: RequestOptions(path: Endpoint.announcementCreate),
          error: 'Response is null',
        );
      }

      final envelope = ApiEnvelope.fromDynamic<AnnouncementModel>(
        response,
        dataParser: (data) => AnnouncementModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal membuat pengumuman',
      );

      return envelope.data;
    } on DioException catch (e) {
      final apiException = ApiException.from(e, fallbackMessage: 'Gagal membuat pengumuman');
      throw Exception(apiException.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  @override
  Future<List<AnnouncementModel>> getCoordinatorAnnouncements() async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        Endpoint.announcementCoordinatorAll,
      );

      if (response == null) {
        return [];
      }

      final envelope = ApiEnvelope.fromDynamic<List<AnnouncementModel>>(
        response,
        dataParser: (data) {
          if (data is List) {
            return data
                .map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
        defaultMessage: 'Gagal memuat pengumuman',
      );

      return envelope.data;
    } on DioException catch (e) {
      final apiException = ApiException.from(e, fallbackMessage: 'Gagal memuat pengumuman');
      throw Exception(apiException.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  @override
  Future<List<AnnouncementModel>> getLecturerAnnouncements({
    int? kelasId,
  }) async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        kelasId != null
            ? Endpoint.announcementLecturerByClass(kelasId)
            : Endpoint.announcementLecturerHistory,
      );

      if (response == null) {
        return [];
      }

      final envelope = ApiEnvelope.fromDynamic<List<AnnouncementModel>>(
        response,
        dataParser: (data) {
          if (data is List) {
            return data
                .map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
        defaultMessage: 'Gagal memuat pengumuman',
      );

      return envelope.data;
    } on DioException catch (e) {
      final apiException = ApiException.from(e, fallbackMessage: 'Gagal memuat pengumuman');
      throw Exception(apiException.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  @override
  Future<void> deleteAnnouncement(int id) async {
    try {
      final response = await _dioClient.delete<Map<String, dynamic>>(
        '${Endpoint.announcement}/$id',
      );

      if (response != null) {
        ApiEnvelope.fromDynamic<Object?>(
          response,
          dataParser: (_) => null,
          defaultMessage: 'Gagal menghapus pengumuman',
        );
      }
    } on DioException catch (e) {
      final apiException = ApiException.from(e, fallbackMessage: 'Gagal menghapus pengumuman');
      throw Exception(apiException.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl(ref.watch(dioClientProvider));
});
