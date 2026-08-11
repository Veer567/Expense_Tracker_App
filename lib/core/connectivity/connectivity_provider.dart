import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

@riverpod
class ConnectivityStatus extends _$ConnectivityStatus {
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  bool build() {
    _init();

    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      state = _isOnline(results);
    });

    ref.onDispose(() {
      _subscription.cancel();
    });

    return true; // Assume online initially
  }

  Future<void> _init() async {
    try {
      final results = await Connectivity().checkConnectivity();
      state = _isOnline(results);
    } catch (_) {
      state = false;
    }
  }

  bool _isOnline(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((result) => result != ConnectivityResult.none);
  }
}
