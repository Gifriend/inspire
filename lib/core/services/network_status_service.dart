import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final networkStatusServiceProvider = Provider<NetworkStatusService>((ref) {
  final service = NetworkStatusService();
  ref.onDispose(service.dispose);
  return service;
});

final networkStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(networkStatusServiceProvider);
  service.start();
  return service.statusStream;
});

class NetworkStatusService {
  final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();

  Timer? _statusTimer;
  bool? _lastStatus;
  bool _isChecking = false;

  Stream<bool> get statusStream => _statusController.stream;

  void start({Duration interval = const Duration(seconds: 4)}) {
    if (_statusTimer != null) {
      return;
    }

    _emitCurrentStatus();
    _statusTimer = Timer.periodic(interval, (_) => _emitCurrentStatus());
  }

  Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('one.one.one.one')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _emitCurrentStatus() async {
    if (_isChecking || _statusController.isClosed) {
      return;
    }

    _isChecking = true;
    final isOnlineNow = await isOnline();

    if (_lastStatus != isOnlineNow && !_statusController.isClosed) {
      _lastStatus = isOnlineNow;
      _statusController.add(isOnlineNow);
    } else {
      _lastStatus ??= isOnlineNow;
    }

    _isChecking = false;
  }

  void dispose() {
    _statusTimer?.cancel();
    _statusController.close();
  }
}