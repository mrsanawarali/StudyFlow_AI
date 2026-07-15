import 'package:hive_flutter/hive_flutter.dart';

/// Placeholder for type-safe Hive box access.
/// Full implementation deferred — existing HiveHelper classes remain the
/// authoritative setup during Phase 1.
///
/// Phase 2: Replace individual HiveHelper calls with BoxManager.
class BoxManager {
  BoxManager._();

  /// Returns an open Hive box by [name].
  /// Throws [HiveError] if the box has not been opened yet.
  static Box<T> getBox<T>(String name) {
    return Hive.box<T>(name);
  }

  /// Returns true if the box with [name] is currently open.
  static bool isOpen(String name) => Hive.isBoxOpen(name);
}
