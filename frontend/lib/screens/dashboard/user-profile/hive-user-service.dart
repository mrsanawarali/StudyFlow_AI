import 'package:hive/hive.dart';
import 'package:untitled/screens/dashboard/user-profile/user-local.dart';
import 'hive-user-helper.dart';



class HiveUserService {
  static Box<UserLocal> get _box => HiveUserHelper.getUserBox();


  static Box<UserLocal> getUserBox() => _box;

  static Future<void> addOrUpdate(UserLocal user) async {
    await _box.put(user.firebaseUid, user);
  }

  static UserLocal? getUser(String firebaseUid) {
    return _box.get(firebaseUid);
  }

  static Future<void> delete(String firebaseUid) async {
    await _box.delete(firebaseUid);
  }

  static Future<void> clear() async {
    await _box.clear();
  }

  static void printAll() {
    print("------ USERS (HIVE) ------");
    for (var u in _box.values) {
      print(
          "UID: ${u.firebaseUid} | Name: ${u.name} | Synced: ${u.isSynced} | Bio: ${u.bio} | Visible: ${u.visible} |Bookmarked: ${u.bookmarked}"
      );
    }
    print("---------------------------");
  }
}
