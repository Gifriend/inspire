import 'package:freezed_annotation/freezed_annotation.dart';

part 'nilai_model.freezed.dart';
part 'nilai_model.g.dart';

/// Response for GET /nilai/kelas/:kelasId — class info + list of students with grades.
@freezed
abstract class KelasNilaiModel with _$KelasNilaiModel {
  const factory KelasNilaiModel({
    required int kelasId,
    required String namaKelas,
    required String kodeMK,
    required String namaMK,
    required int sks,
    required String academicYear,
    required String dosenNama,
    @Default([]) List<NilaiMahasiswaModel> mahasiswa,
  }) = _KelasNilaiModel;

  factory KelasNilaiModel.fromJson(Map<String, dynamic> json) =>
      _$KelasNilaiModelFromJson(json);
}

/// One student's grade record inside a class.
@freezed
abstract class NilaiMahasiswaModel with _$NilaiMahasiswaModel {
  const factory NilaiMahasiswaModel({
    @Default(0) int id,
    required int mahasiswaId,
    required String namaMahasiswa,
    @Default('-') String nim,
    required int mataKuliahId,
    required String kodeMK,
    required String namaMK,
    required int sks,
    required String academicYear,
    double? nilaiTugas,
    double? nilaiUTS,
    double? nilaiUAS,
    double? nilaiAkhir,
    String? nilaiHuruf,
    double? indeksNilai,
    @Default('BELUM_ADA') String status,
  }) = _NilaiMahasiswaModel;

  factory NilaiMahasiswaModel.fromJson(Map<String, dynamic> json) =>
      _$NilaiMahasiswaModelFromJson(json);
}

/// Item in the lecturer's class list (GET /nilai/kelas).
@freezed
abstract class KelasDosenItemModel with _$KelasDosenItemModel {
  const factory KelasDosenItemModel({
    required int kelasId,
    required String namaKelas,
    required String kodeMK,
    required String namaMK,
    required int sks,
    required String academicYear,
  }) = _KelasDosenItemModel;

  factory KelasDosenItemModel.fromJson(Map<String, dynamic> json) =>
      _$KelasDosenItemModelFromJson(json);
}

/// DTO for POST /nilai/input
@freezed
abstract class InputNilaiDto with _$InputNilaiDto {
  const factory InputNilaiDto({
    required int mahasiswaId,
    required int mataKuliahId,
    required String academicYear,
    double? nilaiTugas,
    double? nilaiUTS,
    double? nilaiUAS,
  }) = _InputNilaiDto;

  factory InputNilaiDto.fromJson(Map<String, dynamic> json) =>
      _$InputNilaiDtoFromJson(json);
}
