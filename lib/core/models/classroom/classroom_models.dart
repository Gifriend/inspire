/// Model untuk kelas Google Classroom
class ClassroomCourse {
  final String id;
  final String name;
  final String? section;
  final String? descriptionHeading;
  final String? description;
  final String? room;
  final String ownerId;
  final String courseState;
  final String? alternateLink;
  final String? courseGroupEmail;

  const ClassroomCourse({
    required this.id,
    required this.name,
    this.section,
    this.descriptionHeading,
    this.description,
    this.room,
    required this.ownerId,
    required this.courseState,
    this.alternateLink,
    this.courseGroupEmail,
  });

  factory ClassroomCourse.fromJson(Map<String, dynamic> json) {
    return ClassroomCourse(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Tanpa Nama',
      section: json['section'] as String?,
      descriptionHeading: json['descriptionHeading'] as String?,
      description: json['description'] as String?,
      room: json['room'] as String?,
      ownerId: json['ownerId'] as String? ?? '',
      courseState: json['courseState'] as String? ?? 'ACTIVE',
      alternateLink: json['alternateLink'] as String?,
      courseGroupEmail: json['courseGroupEmail'] as String?,
    );
  }
}

/// Model untuk tugas/materi Google Classroom
class ClassroomCourseWork {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final String workType;
  final String state;
  final String? alternateLink;
  final DateTime? creationTime;
  final DateTime? updateTime;
  final DateTime? dueDate;
  final double? maxPoints;

  const ClassroomCourseWork({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.workType,
    required this.state,
    this.alternateLink,
    this.creationTime,
    this.updateTime,
    this.dueDate,
    this.maxPoints,
  });

  factory ClassroomCourseWork.fromJson(Map<String, dynamic> json) {
    DateTime? parseDueDate() {
      final dueDateMap = json['dueDate'] as Map<String, dynamic>?;
      if (dueDateMap == null) return null;
      final year = dueDateMap['year'] as int?;
      final month = dueDateMap['month'] as int?;
      final day = dueDateMap['day'] as int?;
      if (year == null || month == null || day == null) return null;
      return DateTime(year, month, day);
    }

    return ClassroomCourseWork(
      id: json['id'] as String? ?? '',
      courseId: json['courseId'] as String? ?? '',
      title: json['title'] as String? ?? 'Tanpa Judul',
      description: json['description'] as String?,
      workType: json['workType'] as String? ?? 'UNSPECIFIED',
      state: json['state'] as String? ?? 'PUBLISHED',
      alternateLink: json['alternateLink'] as String?,
      creationTime: json['creationTime'] != null
          ? DateTime.tryParse(json['creationTime'] as String)
          : null,
      updateTime: json['updateTime'] != null
          ? DateTime.tryParse(json['updateTime'] as String)
          : null,
      dueDate: parseDueDate(),
      maxPoints: (json['maxPoints'] as num?)?.toDouble(),
    );
  }

  /// Label tipe tugas yang mudah dibaca
  String get workTypeLabel {
    switch (workType) {
      case 'ASSIGNMENT':
        return 'Tugas';
      case 'MULTIPLE_CHOICE_QUESTION':
        return 'Pilihan Ganda';
      case 'SHORT_ANSWER_QUESTION':
        return 'Jawaban Singkat';
      case 'MATERIAL':
        return 'Materi';
      default:
        return workType;
    }
  }
}

/// Model untuk mahasiswa Google Classroom
class ClassroomStudent {
  final String courseId;
  final String userId;
  final String fullName;
  final String emailAddress;
  final String? photoUrl;

  const ClassroomStudent({
    required this.courseId,
    required this.userId,
    required this.fullName,
    required this.emailAddress,
    this.photoUrl,
  });

  factory ClassroomStudent.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    final name = profile['name'] as Map<String, dynamic>? ?? {};
    return ClassroomStudent(
      courseId: json['courseId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      fullName: name['fullName'] as String? ?? 'Tanpa Nama',
      emailAddress: profile['emailAddress'] as String? ?? '',
      photoUrl: profile['photoUrl'] as String?,
    );
  }
}
