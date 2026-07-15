import 'package:hive/hive.dart';
import 'package:untitled/screens/dashboard/user-profile/user-local.dart';


class HiveUserHelper {
  static const String userBoxName = 'userBox';

  static Future<void> init() async {
    Hive.registerAdapter(UserLocalAdapter());
    await Hive.openBox<UserLocal>(userBoxName);
  }

  static Box<UserLocal> getUserBox() => Hive.box<UserLocal>(userBoxName);
}
