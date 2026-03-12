import 'package:inspire/core/constants/enums/enums.dart';

class PresensiHistoryItem {
  const PresensiHistoryItem({
    required this.token,
    required this.type,
    required this.submittedAt,
    required this.message,
  });

  final String token;
  final PresensiType type;
  final DateTime submittedAt;
  final String message;

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'type': type.name,
      'submittedAt': submittedAt.toIso8601String(),
      'message': message,
    };
  }

  factory PresensiHistoryItem.fromJson(Map<String, dynamic> json) {
    return PresensiHistoryItem(
      token: json['token']?.toString() ?? '',
      type: _parseType(json['type']?.toString()),
      submittedAt: DateTime.tryParse(json['submittedAt']?.toString() ?? '') ??
          DateTime.now(),
      message: json['message']?.toString() ?? 'Presensi berhasil dikirim.',
    );
  }

  static PresensiType _parseType(String? rawType) {
    switch (rawType) {
      case 'uas':
        return PresensiType.uas;
      case 'event':
        return PresensiType.event;
      case 'kelas':
      default:
        return PresensiType.kelas;
    }
  }
}