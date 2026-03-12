import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/constants/enums/enums.dart';
import 'package:inspire/core/data_sources/local/local.dart';
import 'package:inspire/core/models/models.dart';

final presensiHistoryServiceProvider = Provider<PresensiHistoryService>((ref) {
  return PresensiHistoryService(ref.watch(hiveServiceProvider));
});

class PresensiHistoryService {
  PresensiHistoryService(this._hiveService);

  static const int _maxEntries = 10;

  final HiveService _hiveService;

  Future<List<PresensiHistoryItem>> getHistory(PresensiType type) async {
    final raw = await _hiveService.getPresensiHistory(_historyKey(type));
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = json.decode(raw);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(PresensiHistoryItem.fromJson)
        .toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  Future<void> addHistory({
    required PresensiType type,
    required String token,
    required String message,
  }) async {
    final current = await getHistory(type);
    final next = <PresensiHistoryItem>[
      PresensiHistoryItem(
        token: token,
        type: type,
        submittedAt: DateTime.now(),
        message: message,
      ),
      ...current.where((item) => item.token.toUpperCase() != token.toUpperCase()),
    ].take(_maxEntries).toList();

    final payload = json.encode(next.map((item) => item.toJson()).toList());
    await _hiveService.savePresensiHistory(_historyKey(type), payload);
  }

  String _historyKey(PresensiType type) => 'presensi_history_${type.name}';
}