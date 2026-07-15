import 'package:flutter/foundation.dart';
import 'user-local.dart';
import 'user-api-service.dart';
import 'hive-user-service.dart';

class UserSyncManager {
  bool _isSyncing = false;

  static final Map<String, UserLocal> _userCache = {};

  UserSyncManager();

  /// Sync a single user
  Future<void> syncUser(UserLocal localUser) async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      if (!localUser.isSynced) {
        // Push local changes
        final success = await UserApiService.updateUser(localUser.firebaseUid, {
          "name": localUser.name,
          "bio": localUser.bio,
          "profile_pic": localUser.avatarUrl,
          "visible": localUser.visible,
          "bookmarked": localUser.bookmarked, // updated array
        });

        localUser.isSynced = success;
        await HiveUserService.addOrUpdate(localUser);
      } else {
        // Pull server updates
        final serverData = await UserApiService.getUser(localUser.firebaseUid);
        if (serverData != null) {
          localUser
            ..name = serverData["name"] ?? localUser.name
            ..bio = serverData["bio"] ?? localUser.bio
            ..avatarUrl = serverData["profile_pic"] ?? localUser.avatarUrl
            ..visible = serverData["visible"] ?? localUser.visible
            ..bookmarked = List<String>.from(serverData["bookmarked"] ?? localUser.bookmarked)
            ..isSynced = true;

          await HiveUserService.addOrUpdate(localUser);
        }
      }

      debugPrint("✅ User synced: ${localUser.firebaseUid}");
      _userCache[localUser.firebaseUid] = localUser;
    } catch (e) {
      debugPrint("❌ Failed to sync user ${localUser.firebaseUid}: $e");
      localUser.isSynced = false;
      await HiveUserService.addOrUpdate(localUser);
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync all Hive users
  Future<void> syncAll() async {
    for (var user in HiveUserService.getUserBox().values) {
      await syncUser(user);
    }
  }

  /// Sync specific user
  Future<void> syncCurrentUser(String firebaseUid) async {
    final localUser = HiveUserService.getUser(firebaseUid);
    if (localUser != null) {
      await syncUser(localUser);
    }
  }

  /// Prefetch a user (caching)
  Future<UserLocal?> prefetchUser(String uid) async {
    if (_userCache.containsKey(uid)) return _userCache[uid];

    final hiveUser = HiveUserService.getUser(uid);
    if (hiveUser != null) {
      _userCache[uid] = hiveUser;
      return hiveUser;
    }

    final apiData = await UserApiService.getUser(uid);
    if (apiData != null) {
      final user = UserLocal(
        firebaseUid: uid,
        name: apiData["name"] ?? "Unknown",
        bio: apiData["bio"] ?? "",
        avatarUrl: apiData["profile_pic"] ?? "",
        visible: apiData["visible"] ?? true,
        bookmarked: List<String>.from(apiData["bookmarked"] ?? []),
        isSynced: true,
      );
      await HiveUserService.addOrUpdate(user);
      _userCache[uid] = user;
      return user;
    }

    return null;
  }
}
