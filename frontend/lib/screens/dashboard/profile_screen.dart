// import 'dart:convert';
// import 'dart:io' show File;
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:untitled/config.dart';
// import 'package:untitled/screens/dashboard/user-profile/user-api-service.dart';
// import 'package:untitled/screens/dashboard/user-profile/user-local.dart';
// import 'package:untitled/screens/dashboard/user-profile/hive-user-service.dart';
// import 'package:untitled/screens/dashboard/user-profile/user_sync_manager.dart';
// import '../../clippers/top_pattern_clipper.dart';
// import '../explore/public_semester_screen.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   final String firebaseUid = "testUser001"; // replace with logged-in UID
//   UserLocal? localUser;
//   bool isLoading = true;
//   bool isEditMode = false;
//
//   final ImagePicker _picker = ImagePicker();
//   final TextEditingController _bioController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     loadUser();
//   }
//
//   Future<void> loadUser() async {
//     setState(() => isLoading = true);
//
//     // 1️⃣ Load current user from Hive
//     UserLocal? hiveUser = HiveUserService.getUser(firebaseUid);
//
//     if (hiveUser != null) {
//       localUser = hiveUser;
//     } else {
//       // 2️⃣ Fetch from API if not in Hive
//       final apiData = await UserApiService.getUser(firebaseUid);
//       if (apiData != null) {
//         localUser = UserLocal(
//           firebaseUid: firebaseUid,
//           name: apiData['name'] ?? 'Unknown',
//           bio: apiData['bio'] ?? '',
//           avatarUrl: apiData['profile_pic'] ?? '',
//           visible: apiData['visible'] ?? true,
//           bookmarked: List<String>.from(apiData['bookmarked'] ?? []),
//           isSynced: true,
//         );
//         await HiveUserService.addOrUpdate(localUser!);
//       } else {
//         localUser = UserLocal(
//           firebaseUid: firebaseUid,
//           name: 'Unknown',
//           bio: '',
//           avatarUrl: '',
//           visible: true,
//           bookmarked: [],
//           isSynced: false,
//         );
//       }
//     }
//
//     _bioController.text = localUser!.bio!;
//
//     // 3️⃣ Prefetch bookmarked users
//     for (String uid in localUser!.bookmarked) {
//       await UserSyncManager().prefetchUser(uid);
//     }
//
//     setState(() => isLoading = false);
//
//     // 4️⃣ Sync current user in background
//     await UserSyncManager().syncCurrentUser(firebaseUid);
//     UserLocal? synced = HiveUserService.getUser(firebaseUid);
//     if (synced != null) {
//       localUser = synced;
//       _bioController.text = localUser!.bio;
//       setState(() {});
//     }
//   }
//
//   Future<void> updateBio(String newBio) async {
//     localUser!.bio = newBio;
//     localUser!.isSynced = false;
//     await HiveUserService.addOrUpdate(localUser!);
//     setState(() {});
//
//     await UserSyncManager().syncCurrentUser(firebaseUid);
//   }
//
//   Future<void> toggleVisibility(bool val) async {
//     localUser!.visible = val;
//     localUser!.isSynced = false;
//     await HiveUserService.addOrUpdate(localUser!);
//     setState(() {});
//
//     await UserSyncManager().syncCurrentUser(firebaseUid);
//   }
//
//   Future<void> _editAvatar() async {
//     final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
//     if (img == null) return;
//
//     final request = http.MultipartRequest(
//       "POST",
//       Uri.parse("${AppConfig.baseUrl}/upload"),
//     );
//     request.files.add(await http.MultipartFile.fromPath("file", img.path));
//
//     final res = await request.send();
//     final body = await res.stream.bytesToString();
//     final uploaded = json.decode(body);
//
//     localUser!.avatarUrl = uploaded["filePath"];
//     localUser!.isSynced = false;
//     await HiveUserService.addOrUpdate(localUser!);
//     setState(() {});
//
//     await UserSyncManager().syncCurrentUser(firebaseUid);
//   }
//
//   Future<void> removeBookmarkLocal(int index) async {
//     final removedUid = localUser!.bookmarked[index];
//
//     // Update Hive immediately
//     localUser!.bookmarked.removeAt(index);
//     localUser!.isSynced = false;
//     await HiveUserService.addOrUpdate(localUser!);
//     setState(() {});
//
//     try {
//       // Push the updated bookmark array to server directly
//       final ok = await UserApiService.removeBookmark(localUser!.firebaseUid, removedUid);
//       localUser!.isSynced = ok;
//       await HiveUserService.addOrUpdate(localUser!);
//     } catch (e) {
//       debugPrint("Failed to sync unbookmark: $e");
//     }
//   }
//
//
//   void _editBio() {
//     final accent = Colors.deepPurpleAccent;
//     _bioController.text = localUser!.bio;
//
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.transparent,
//         insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             Container(
//               padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF1E2340),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: _bioController,
//                     maxLines: 3,
//                     style: const TextStyle(color: Colors.white),
//                     decoration: InputDecoration(
//                       hintText: 'Enter your bio',
//                       hintStyle: const TextStyle(color: Colors.white54),
//                       filled: true,
//                       fillColor: const Color(0xFF2A2F4F),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           icon: const Icon(Icons.close, color: Colors.white70),
//                           label: const Text('Cancel', style: TextStyle(color: Colors.white70)),
//                           style: OutlinedButton.styleFrom(
//                             side: BorderSide(color: accent),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                           ),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           icon: const Icon(Icons.save, color: Colors.white),
//                           label: const Text('Save', style: TextStyle(color: Colors.white)),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: accent,
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                           ),
//                           onPressed: () {
//                             updateBio(_bioController.text);
//                             Navigator.pop(context);
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Positioned(
//               top: -20,
//               left: 0,
//               right: 0,
//               child: ClipPath(
//                 clipper: TopPatternClipper(),
//                 child: Container(
//                   height: 140,
//                   decoration: BoxDecoration(
//                     color: accent,
//                     borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
//                   ),
//                   child: const Center(
//                     child: Text(
//                       'Edit Bio',
//                       style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading || localUser == null) {
//       return const Scaffold(
//         backgroundColor: Color(0xFF0A0F2C),
//         body: Center(child: CircularProgressIndicator(color: Colors.grey)),
//       );
//     }
//
//     final accent = Colors.deepPurpleAccent;
//
//     ImageProvider avatarProvider;
//     if (localUser!.avatarUrl.startsWith('http')) {
//       avatarProvider = NetworkImage(localUser!.avatarUrl);
//     } else if (kIsWeb) {
//       avatarProvider = const NetworkImage('https://i.pravatar.cc/300');
//     } else if (localUser!.avatarUrl.isNotEmpty) {
//       avatarProvider = FileImage(File(localUser!.avatarUrl));
//     } else {
//       avatarProvider = const AssetImage("assets/images/avatar1.png");
//     }
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0F2C),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.grey))
//           : SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Avatar + Edit Button
//             Stack(
//               alignment: Alignment.bottomRight,
//               children: [
//                 CircleAvatar(radius: 70, backgroundImage: avatarProvider),
//                 Container(
//                   decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
//                   child: IconButton(
//                     icon: const Icon(Icons.edit, color: Colors.white, size: 20),
//                     onPressed: _editAvatar,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Text(localUser!.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
//             const SizedBox(height: 16),
//
//             // Bio
//             GestureDetector(
//               onTap: _editBio,
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1E2340),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(child: Text(localUser!.bio.isEmpty ? "No bio added" : localUser!.bio, style: const TextStyle(fontSize: 16, color: Colors.white70))),
//                     const SizedBox(width: 8),
//                     Icon(Icons.edit, color: accent),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             // Visibility toggle
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(color: const Color(0xFF1E2340), borderRadius: BorderRadius.circular(16)),
//               child: Row(
//                 children: [
//                   const Icon(Icons.visibility, color: Colors.deepPurpleAccent),
//                   const SizedBox(width: 12),
//                   const Expanded(child: Text('Make profile visible to others', style: TextStyle(color: Colors.white70, fontSize: 16))),
//                   Switch(value: localUser!.visible, activeColor: accent, onChanged: toggleVisibility),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 28),
//
//             // Edit mode toggle for bookmarks
//             Row(
//               children: [
//                 const Icon(Icons.bookmark, color: Colors.deepPurpleAccent, size: 24),
//                 const SizedBox(width: 8),
//                 const Text("Bookmarked Profiles", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
//                 const Spacer(),
//                 TextButton(onPressed: () => setState(() => isEditMode = !isEditMode), child: Text(isEditMode ? "Done" : "Edit", style: TextStyle(color: accent))),
//               ],
//             ),
//             const SizedBox(height: 12),
//
//             // Bookmarked Profiles
//             SizedBox(
//               height: 120,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: localUser!.bookmarked.length,
//                 itemBuilder: (context, index) {
//                   final userId = localUser!.bookmarked[index];
//
//                   return FutureBuilder<UserLocal?>(
//                     future: UserSyncManager().prefetchUser(userId),
//                     builder: (context, snapshot) {
//                       String userName = userId;
//                       String userAvatar = "assets/images/avatar1.png";
//                       UserLocal? user = snapshot.data;
//
//                       if (user != null) {
//                         userName = user.name;
//                         if (user.avatarUrl.isNotEmpty) userAvatar = user.avatarUrl;
//                       }
//
//                       return Stack(
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               if (user != null) {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => PublicSemesterScreen(
//                                       username: userName,
//                                       avatarUrl: userAvatar,
//                                       firebaseUid: userId,
//                                       bio: user.bio,
//                                     ),
//                                   ),
//                                 );
//                               }
//                             },
//                             child: Container(
//                               width: 110,
//                               margin: const EdgeInsets.only(right: 12),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(16),
//                                 boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 3))],
//                               ),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   CircleAvatar(backgroundImage: NetworkImage(userAvatar), radius: 28),
//                                   const SizedBox(height: 8),
//                                   Text(userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           if (isEditMode)
//                             Positioned(
//                               top: 4,
//                               right: 4,
//                               child: GestureDetector(
//                                 onTap: () => removeBookmarkLocal(index),
//                                 child: Container(
//                                   decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
//                                   padding: const EdgeInsets.all(4),
//                                   child: const Icon(Icons.close, size: 18, color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:untitled/config.dart';
import 'package:untitled/screens/dashboard/user-profile/user-api-service.dart';
import 'package:untitled/screens/dashboard/user-profile/user-local.dart';
import 'package:untitled/screens/dashboard/user-profile/hive-user-service.dart';
import 'package:untitled/screens/dashboard/user-profile/user_sync_manager.dart';
import '../../clippers/top_pattern_clipper.dart';
import '../explore/public_semester_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final String firebaseUid ; // replace with logged-in UID
  UserLocal? localUser;
  bool isLoading = true;
  bool isEditMode = false;
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      firebaseUid = user.uid;
      loadUser();
    }
    loadUser();

  }

  Future<void> loadUser() async {
    setState(() => isLoading = true);

    // 1️⃣ Load from Hive
    UserLocal? hiveUser = HiveUserService.getUser(firebaseUid);
    if (hiveUser != null) {
      localUser = hiveUser;
    } else {
      // 2️⃣ Fetch from API if not in Hive
      try {
        final apiData = await UserApiService.getUser(firebaseUid);
        if (apiData != null) {
          localUser = UserLocal(
            firebaseUid: firebaseUid,
            name: apiData['name'] ?? 'Unknown',
            bio: apiData['bio'] ?? '',
            avatarUrl: apiData['profile_pic'] ?? '',
            visible: apiData['visible'] ?? true,
            bookmarked: List<String>.from(apiData['bookmarked'] ?? []),
            isSynced: true,
          );
          await HiveUserService.addOrUpdate(localUser!);
        } else {
          localUser = _defaultUser();
        }
      } catch (e) {
        debugPrint("Failed to fetch user from API: $e");
        localUser = _defaultUser();
      }
    }

    _bioController.text = localUser!.bio!;

    // 3️⃣ Prefetch bookmarked users
    for (String uid in localUser!.bookmarked) {
      await UserSyncManager().prefetchUser(uid);
    }

    setState(() => isLoading = false);

    // 4️⃣ Sync current user in background
    await UserSyncManager().syncCurrentUser(firebaseUid);
    final synced = HiveUserService.getUser(firebaseUid);
    if (synced != null) {
      localUser = synced;
      _bioController.text = localUser!.bio;
      setState(() {});
    }
  }

  UserLocal _defaultUser() {
    return UserLocal(
      firebaseUid: firebaseUid,
      name: 'Unknown',
      bio: '',
      avatarUrl: '',
      visible: true,
      bookmarked: [],
      isSynced: false,
    );
  }

  Future<void> updateBio(String newBio) async {
    localUser!.bio = newBio;
    localUser!.isSynced = false;
    await HiveUserService.addOrUpdate(localUser!);
    setState(() {});
    await UserSyncManager().syncCurrentUser(firebaseUid);
  }

  Future<void> toggleVisibility(bool val) async {
    localUser!.visible = val;
    localUser!.isSynced = false;
    await HiveUserService.addOrUpdate(localUser!);
    setState(() {});
    await UserSyncManager().syncCurrentUser(firebaseUid);
  }

  Future<void> removeBookmarkLocal(int index) async {
    final removedUid = localUser!.bookmarked[index];
    localUser!.bookmarked.removeAt(index);
    localUser!.isSynced = false;
    await HiveUserService.addOrUpdate(localUser!);
    setState(() {});

    try {
      final ok = await UserApiService.removeBookmark(localUser!.firebaseUid, removedUid);
      localUser!.isSynced = ok;
      await HiveUserService.addOrUpdate(localUser!);
    } catch (e) {
      debugPrint("Failed to sync unbookmark: $e");
    }
  }

  void _editBio() {
    final accent = Colors.deepPurpleAccent;
    _bioController.text = localUser!.bio;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2340),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _bioController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your bio',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF2A2F4F),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          label: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: accent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text('Save', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            updateBio(_bioController.text);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -20,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: TopPatternClipper(),
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  child: const Center(
                    child: Text(
                      'Edit Bio',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Avatar helper ----------------
  Widget buildAvatar(String name, {double radius = 70, Color? backgroundColor, double? textSize}) {
    String initials = "";
    final parts = name.trim().split(" ");
    if (parts.length == 1) {
      initials = parts[0].isNotEmpty ? parts[0][0].toUpperCase() : "U";
    } else if (parts.length >= 2) {
      initials = (parts[0][0] + parts[1][0]).toUpperCase();
    } else {
      initials = "U";
    }

    final bgColor = backgroundColor ?? Colors.white;
    final fontClr = backgroundColor != null ? Colors.white : const Color(0xFF1B2660);
    final fSize = textSize ?? (radius / 1.75);

    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: Text(
        initials,
        style: TextStyle(
          color: fontClr,
          fontSize: fSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || localUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0F2C),
        body: Center(child: CircularProgressIndicator(color: Colors.grey)),
      );
    }

    final accent = Colors.deepPurpleAccent;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Main Avatar
            buildAvatar(localUser!.name, radius: 70),
            const SizedBox(height: 20),
            Text(
              localUser!.name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Bio
            GestureDetector(
              onTap: _editBio,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2340),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        localUser!.bio.isEmpty ? "No bio added" : localUser!.bio,
                        style: const TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.edit, color: accent),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Visibility toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: const Color(0xFF1E2340), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.visibility, color: Colors.deepPurpleAccent),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Make profile visible to others',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                  Switch(value: localUser!.visible, activeColor: accent, onChanged: toggleVisibility),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Bookmarks header
            Row(
              children: [
                const Icon(Icons.bookmark, color: Colors.deepPurpleAccent, size: 24),
                const SizedBox(width: 8),
                const Text(
                  "Bookmarked Profiles",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => isEditMode = !isEditMode),
                  child: Text(isEditMode ? "Done" : "Edit", style: TextStyle(color: accent)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bookmarked Profiles
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: localUser!.bookmarked.length,
                itemBuilder: (context, index) {
                  final userId = localUser!.bookmarked[index];

                  return FutureBuilder<UserLocal?>(
                    future: UserSyncManager().prefetchUser(userId),
                    builder: (context, snapshot) {
                      String userName = userId;
                      UserLocal? user = snapshot.data;

                      if (user != null) userName = user.name;

                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (user != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PublicSemesterScreen(
                                      username: userName,
                                      firebaseUid: userId,
                                      bio: user.bio,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: 110,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 3))
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  buildAvatar(
                                    userName,
                                    radius: 28,
                                    backgroundColor: const Color(0xFF1E2340),
                                    textSize: 20,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    userName,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isEditMode)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => removeBookmarkLocal(index),
                                child: Container(
                                  decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.close, size: 18, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
