class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.status,
    required this.message,
    required this.data,
  });

  final String status;
  final String message;
  final T data;

  bool get isSuccess => status.toLowerCase() == 'success';

  static ApiEnvelope<T> fromDynamic<T>(
    dynamic raw, {
    required T Function(Object? data) dataParser,
    String defaultMessage = '',
  }) {
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Invalid response format');
    }

    return ApiEnvelope<T>(
      status: raw['status']?.toString() ?? '',
      message: raw['message']?.toString() ?? defaultMessage,
      data: dataParser(raw['data']),
    );
  }

  static Map<String, dynamic> parseSingleMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is List && data.isNotEmpty && data.first is Map) {
      return Map<String, dynamic>.from(data.first as Map);
    }

    throw const FormatException('Invalid response data format');
  }
}