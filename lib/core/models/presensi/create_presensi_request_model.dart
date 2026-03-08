import 'package:inspire/core/models/presensi/presensi_session_model.dart';

class CreatePresensiRequestModel {
  final String title;
  final SessionType type;
  final int? kelasPerkuliahanId;
  final String? deadlineDate; // YYYY-MM-DD
  final String? deadlineTime; // HH:mm

  CreatePresensiRequestModel({
    required this.title,
    required this.type,
    this.kelasPerkuliahanId,
    this.deadlineDate,
    this.deadlineTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': _typeToString(type),
      'kelasPerkuliahanId': kelasPerkuliahanId,
      'deadlineDate': deadlineDate,
      'deadlineTime': deadlineTime,
    }..removeWhere((key, value) => value == null);
  }

  String _typeToString(SessionType t) {
    switch (t) {
      case SessionType.kelas:
        return 'KELAS';
      case SessionType.uas:
        return 'UAS';
      case SessionType.event:
        return 'EVENT';
    }
  }
}
