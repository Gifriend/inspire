import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.status,
    this.fieldErrors = const {},
  });

  final String message;
  final String? status;
  final Map<String, List<String>> fieldErrors;

  String? firstFieldError(String field) {
    final errors = fieldErrors[field];
    if (errors == null || errors.isEmpty) {
      return null;
    }
    return errors.first;
  }

  @override
  String toString() => message;

  static ApiException from(
    Object error, {
    String fallbackMessage = 'Terjadi kesalahan.',
  }) {
    if (error is ApiException) {
      return error;
    }

    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        final fieldErrors = _parseFieldErrors(responseData['data']);
        final rawMessage = _parseMessage(responseData['message']);

        return ApiException(
          status: responseData['status']?.toString(),
          fieldErrors: fieldErrors,
          message: _resolveMessage(
            rawMessage: rawMessage,
            fieldErrors: fieldErrors,
            fallbackMessage: fallbackMessage,
          ),
        );
      }

      final dioMessage = error.message?.trim();
      return ApiException(
        message: dioMessage?.isNotEmpty == true ? dioMessage! : fallbackMessage,
      );
    }

    final normalized = error.toString().replaceFirst('Exception: ', '').trim();
    return ApiException(
      message: normalized.isNotEmpty ? normalized : fallbackMessage,
    );
  }

  static String? _parseMessage(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    if (value is List) {
      final messages = value
          .map((item) => item?.toString().trim())
          .whereType<String>()
          .where((item) => item.isNotEmpty)
          .toList();
      if (messages.isNotEmpty) {
        return messages.join(', ');
      }
    }

    return null;
  }

  static Map<String, List<String>> _parseFieldErrors(Object? value) {
    if (value is! List) {
      return const {};
    }

    final result = <String, List<String>>{};

    for (final item in value) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      final field = item['field']?.toString().trim();
      if (field == null || field.isEmpty) {
        continue;
      }

      final errorsValue = item['errors'];
      final errors = <String>[];

      if (errorsValue is List) {
        for (final entry in errorsValue) {
          final text = entry?.toString().trim();
          if (text != null && text.isNotEmpty) {
            errors.add(text);
          }
        }
      } else {
        final text = errorsValue?.toString().trim();
        if (text != null && text.isNotEmpty) {
          errors.add(text);
        }
      }

      if (errors.isNotEmpty) {
        result[field] = errors;
      }
    }

    return result;
  }

  static String _resolveMessage({
    required String? rawMessage,
    required Map<String, List<String>> fieldErrors,
    required String fallbackMessage,
  }) {
    final firstFieldMessage = fieldErrors.values
        .expand((errors) => errors)
        .cast<String?>()
        .firstWhere(
          (value) => value != null && value.trim().isNotEmpty,
          orElse: () => null,
        );

    if (rawMessage == null || rawMessage.isEmpty) {
      return firstFieldMessage ?? fallbackMessage;
    }

    if (rawMessage.toLowerCase() == 'validation failed' &&
        firstFieldMessage != null) {
      return firstFieldMessage;
    }

    return rawMessage;
  }
}