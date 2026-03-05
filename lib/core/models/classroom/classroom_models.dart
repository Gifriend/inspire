import 'package:freezed_annotation/freezed_annotation.dart';

part 'classroom_models.freezed.dart';
part 'classroom_models.g.dart';

/// Freezed model for Google Classroom course
@freezed
abstract class ClassroomCourse with _$ClassroomCourse {
  const factory ClassroomCourse({
    required String id,
    required String name,
    String? section,
    String? descriptionHeading,
    String? description,
    String? room,
    required String ownerId,
    required String courseState,
    String? alternateLink,
    String? courseGroupEmail,
  }) = _ClassroomCourse;

  factory ClassroomCourse.fromJson(Map<String, dynamic> json) => _$ClassroomCourseFromJson(json);
}

/// Freezed model for Google Classroom coursework (assignments/materials)
@freezed
abstract class ClassroomCourseWork with _$ClassroomCourseWork {
  const factory ClassroomCourseWork({
    required String id,
    required String courseId,
    required String title,
    String? description,
    required String workType,
    required String state,
    String? alternateLink,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
        DateTime? creationTime,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
        DateTime? updateTime,
    @JsonKey(fromJson: _dueDateFromJson, toJson: _dueDateToJson)
        DateTime? dueDate,
    double? maxPoints,
  }) = _ClassroomCourseWork;

  factory ClassroomCourseWork.fromJson(Map<String, dynamic> json) => _$ClassroomCourseWorkFromJson(json);
}

/// Freezed model for a student in Google Classroom
@freezed
abstract class ClassroomStudent with _$ClassroomStudent {
  const factory ClassroomStudent({
    required String courseId,
    required String userId,
    required String fullName,
    required String emailAddress,
    String? photoUrl,
  }) = _ClassroomStudent;

  /// API returns nested `profile` object; keep a convenience parser for that shape.
  factory ClassroomStudent.fromApiJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    final name = profile['name'] as Map<String, dynamic>? ?? {};
    return ClassroomStudent(
      courseId: json['courseId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      fullName: name['fullName'] as String? ?? 'Unnamed',
      emailAddress: profile['emailAddress'] as String? ?? '',
      photoUrl: profile['photoUrl'] as String?,
    );
  }

  factory ClassroomStudent.fromJson(Map<String, dynamic> json) => _$ClassroomStudentFromJson(json);
}

/// Helper functions for (de)serializing DateTime fields
DateTime? _dateTimeFromJson(Object? value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

String? _dateTimeToJson(DateTime? dt) => dt?.toIso8601String();

DateTime? _dueDateFromJson(Map<String, dynamic>? map) {
  if (map == null) return null;
  final year = map['year'] as int?;
  final month = map['month'] as int?;
  final day = map['day'] as int?;
  if (year == null || month == null || day == null) return null;
  return DateTime(year, month, day);
}

Map<String, int>? _dueDateToJson(DateTime? dt) {
  if (dt == null) return null;
  return {'year': dt.year, 'month': dt.month, 'day': dt.day};
}

extension ClassroomCourseWorkExt on ClassroomCourseWork {
  String get workTypeLabel {
    switch (workType) {
      case 'ASSIGNMENT':
        return 'Assignment';
      case 'MULTIPLE_CHOICE_QUESTION':
        return 'Multiple Choice';
      case 'SHORT_ANSWER_QUESTION':
        return 'Short Answer';
      case 'MATERIAL':
        return 'Material';
      default:
        return workType;
    }
  }
}
