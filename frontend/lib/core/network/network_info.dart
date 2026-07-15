/// Abstraction for checking network connectivity.
abstract class NetworkInfo {
  /// Returns [true] if the device has an active internet connection.
  Future<bool> get isConnected;
}

/// Stub implementation — full implementation deferred to Phase 2.
/// Returns [true] by default so existing sync code is not affected.
class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl();

  @override
  Future<bool> get isConnected async => true;
}
