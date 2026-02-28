import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void keepAliveFor(Ref ref, Duration duration) {
  final link = ref.keepAlive();
  Timer? timer;

  void startTimer() {
    timer?.cancel();
    timer = Timer(duration, link.close);
  }

  void cancelTimer() {
    timer?.cancel();
    timer = null;
  }

  ref
    ..onCancel(startTimer)
    ..onResume(cancelTimer)
    ..onDispose(cancelTimer);
}
