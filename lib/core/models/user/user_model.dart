import 'package:freezed_annotation/freezed_annotation.dart';
import '../fakultas/fakultas_model.dart';
import '../prodi/prodi_model.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required int id,
    required String nim,
    String? nip,
    required String name,
    required String email,
    String? telepon,
    String? alamat,
    DateTime? tanggalLahir,
    String? gender,
    required String role,
    required String status,
    String? photo,
    String? fcmToken,
    int? fakultasId,
    int? prodiId,
    DateTime? createdAt,
    DateTime? updatedAt,
    FakultasModel? fakultas,
    ProdiModel? prodi,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
