import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for checking network connectivity.
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({required Connectivity connectivity})
      : _connectivity = connectivity;

  /// Check if the device is connected to the internet.
  Future<bool> isConnected() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    // If any result is not 'none', then we're connected
    return connectivityResults.any((result) => result != ConnectivityResult.none);
  }

  /// Stream of connectivity changes.
  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map((List<ConnectivityResult> results) {
        // Return the first result, or ConnectivityResult.none if the list is empty
        return results.isNotEmpty ? results.first : ConnectivityResult.none;
      });

  /// Check if the device is connected to a mobile network.
  Future<bool> isMobile() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    return connectivityResults.contains(ConnectivityResult.mobile);
  }

  /// Check if the device is connected to a WiFi network.
  Future<bool> isWifi() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    return connectivityResults.contains(ConnectivityResult.wifi);
  }
}
