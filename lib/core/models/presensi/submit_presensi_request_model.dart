class SubmitPresensiRequestModel {
  // final int sessionId;
  final String token;

  const SubmitPresensiRequestModel({
    // required this.sessionId,
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      // 'sessionId': sessionId,
      'token': token,
    };
  }
}
