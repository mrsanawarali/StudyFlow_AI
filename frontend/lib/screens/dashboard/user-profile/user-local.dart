import 'package:hive/hive.dart';

part 'user-local.g.dart';

@HiveType(typeId: 10)
class UserLocal extends HiveObject {
  @HiveField(0)
  String firebaseUid;

  @HiveField(1)
  String name;

  @HiveField(2)
  String bio;

  @HiveField(3)
  String avatarUrl;

  @HiveField(4)
  bool visible;

  @HiveField(5)
  List<String> bookmarked;

  @HiveField(6)
  bool isSynced;

  UserLocal({
    required this.firebaseUid,
    this.name = "",
    this.bio = "",
    this.avatarUrl = "",
    this.visible = true,
    List<String>? bookmarked,
    this.isSynced = true,
  }) : bookmarked = bookmarked ?? [];
}
