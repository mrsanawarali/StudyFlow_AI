// import 'package:flutter/material.dart';
// import 'dart:async'; // <-- Needed for Timer
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:untitled/screens/explore/public_semester_screen.dart';
// import 'package:untitled/config.dart';
//
// class ExploreScreen extends StatefulWidget {
//   const ExploreScreen({super.key});
//
//   @override
//   State<ExploreScreen> createState() => _ExploreScreenState();
// }
//
// class _ExploreScreenState extends State<ExploreScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _debounce; // <-- debounce timer
//
//   List<dynamic> users = [];
//   bool isLoading = false;
//
//   Future<void> searchUsers(String query) async {
//     if (query.isEmpty) {
//       setState(() => users = []);
//       return;
//     }
//
//     setState(() => isLoading = true);
//
//     try {
//       final url = Uri.parse("${AppConfig.baseUrl}/users?search=$query");
//       final res = await http.get(url);
//
//       if (res.statusCode == 200) {
//         setState(() {
//           users = json.decode(res.body);
//         });
//       }
//     } catch (e) {
//       print("Search error: $e");
//     }
//
//     setState(() => isLoading = false);
//   }
//
//   @override
//   void dispose() {
//     _debounce?.cancel(); // <-- cancel timer when disposing
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final accent = Colors.deepPurpleAccent;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0F2C),
//       appBar: AppBar(
//         title: const Text(
//           'Explore Users',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//         ),
//         backgroundColor: const Color(0xFF2D3770),
//         centerTitle: true,
//         elevation: 2,
//         automaticallyImplyLeading: false,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Search field with debounce
//             TextField(
//               controller: _searchController,
//               onChanged: (value) {
//                 // Cancel previous timer if still active
//                 if (_debounce?.isActive ?? false) _debounce!.cancel();
//
//                 // Start new timer
//                 _debounce = Timer(const Duration(milliseconds: 500), () {
//                   searchUsers(value);
//                 });
//               },
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 hintText: 'Search by email or name...',
//                 hintStyle: const TextStyle(color: Colors.white54),
//                 filled: true,
//                 fillColor: const Color(0xFF1E2340),
//                 prefixIcon: Icon(Icons.search, color: accent),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             Expanded(
//               child: isLoading
//                   ? const Center(
//                 child: CircularProgressIndicator(color: Colors.white),
//               )
//                   : users.isEmpty
//                   ? const Center(
//                 child: Text(
//                   "No users found",
//                   style: TextStyle(color: Colors.white54),
//                 ),
//               )
//                   : ListView.builder(
//                 itemCount: users.length,
//                 itemBuilder: (context, index) {
//                   final user = users[index];
//
//                   return Container(
//                     margin: const EdgeInsets.only(bottom: 12),
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 8, horizontal: 12),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF1E2340),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         backgroundImage: user["profile_pic"] != null
//                             ? NetworkImage(user["profile_pic"])
//                             : const AssetImage(
//                             "assets/images/avatar_placeholder.png")
//                         as ImageProvider,
//                       ),
//                       title: Text(
//                         user["name"],
//                         style: const TextStyle(
//                             color: Colors.white, fontSize: 18),
//                       ),
//                       subtitle: user["email"] != null
//                           ? Text(
//                         user["email"],
//                         style: const TextStyle(
//                             color: Colors.white54),
//                       )
//                           : null,
//                       trailing: Icon(Icons.arrow_forward_ios,
//                           color: accent, size: 18),
//                       onTap: () {
//                         final firebaseUid = user["firebaseUid"];
//
//                         if (firebaseUid != null && firebaseUid.isNotEmpty) {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => PublicSemesterScreen(
//                                 username: user["name"] ?? "No Name",
//                                 avatarUrl: user["profile_pic"],
//                                 bio: user["bio"] ?? "",
//                                 firebaseUid: firebaseUid,
//                               ),
//                             ),
//                           );
//                         } else {
//                           // Optional: show a small message instead of crashing
//                           ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text("User data incomplete, cannot open profile"))
//                           );
//                         }
//                       },
//
//
//
//                     ),
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


import 'package:flutter/material.dart';
import 'dart:async'; // For Timer
import 'dart:convert';
import 'package:untitled/screens/explore/public_semester_screen.dart';
import 'package:http/http.dart' as http;
import '../../config.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce; // Debounce timer

  List<dynamic> users = [];
  bool isLoading = false;

  // ---------------- Avatar helper ----------------
  Widget buildAvatar(String name, {double radius = 40, Color? backgroundColor, double? textSize}) {
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

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => users = []);
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse("${AppConfig.baseUrl}/users?search=$query");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        setState(() {
          users = json.decode(res.body);
        });
      } else {
        setState(() => users = []);
      }
    } catch (e) {
      debugPrint("Search error: $e");
      setState(() => users = []);
    }

    setState(() => isLoading = false);
  }


  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Colors.deepPurpleAccent;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        title: const Text(
          'Explore Users',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2D3770),
        centerTitle: true,
        elevation: 2,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search field with debounce
            TextField(
              controller: _searchController,
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  searchUsers(value);
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1E2340),
                prefixIcon: Icon(Icons.search, color: accent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : users.isEmpty
                  ? const Center(
                child: Text(
                  "No users found",
                  style: TextStyle(color: Colors.white54),
                ),
              )
                  : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2340),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: buildAvatar(
                        user["name"] ?? "Unknown",
                        radius: 24,
                        backgroundColor: const Color(0xFF1B2660),
                        textSize: 16,
                      ),
                      title: Text(
                        user["name"],
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      subtitle: user["email"] != null
                          ? Text(user["email"], style: const TextStyle(color: Colors.white54))
                          : null,
                      trailing: Icon(Icons.arrow_forward_ios, color: accent, size: 18),
                      onTap: () {
                        final firebaseUid = user["firebaseUid"];
                        if (firebaseUid != null && firebaseUid.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PublicSemesterScreen(
                                username: user["name"] ?? "No Name",
                                bio: user["bio"] ?? "",
                                firebaseUid: firebaseUid,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("User data incomplete, cannot open profile")),
                          );
                        }
                      },
                    ),
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

