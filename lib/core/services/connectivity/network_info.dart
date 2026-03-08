import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';

abstract interface class INetworkInfo {
  Future<bool> get isConnected;
}

final networkInfoProvider = Provider<INetworkInfo>((ref) {
  return NetworkInfo(Connectivity());
});

final connectivityStatusProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  final initial = await connectivity.checkConnectivity();
  yield !initial.contains(ConnectivityResult.none);

  await for (final result in connectivity.onConnectivityChanged) {
    yield !result.contains(ConnectivityResult.none);
  }
});

class NetworkInfo implements INetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    if (!result.contains(ConnectivityResult.none)) {
      return true;
    }

    // On some Android devices, connectivity can briefly report `none`
    // after Wi-Fi toggles. Probe the configured backend directly before
    // deciding we are truly offline.
    return _canReachConfiguredBackend();
  }

  Future<bool> _canReachConfiguredBackend() async {
    try {
      final uri = Uri.parse(ApiEndpoints.serverBaseUrl);
      if (uri.host.isEmpty || uri.port <= 0) {
        return false;
      }

      final socket = await Socket.connect(
        uri.host,
        uri.port,
        timeout: const Duration(seconds: 2),
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}
