// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:untitled/screens/explore/public-subject-screen.dart';
// import 'package:untitled/config.dart';
// class PublicSemesterScreen extends StatefulWidget {
//   final String username;
//   final String? avatarUrl;
//   final String firebaseUid;
//   final String bio;
//
//   const PublicSemesterScreen({
//     super.key,
//     required this.username,
//     this.avatarUrl,
//     required this.firebaseUid,
//     this.bio = "",
//   });
//
//   @override
//   State<PublicSemesterScreen> createState() => _PublicSemesterScreenState();
// }
//
// class _PublicSemesterScreenState extends State<PublicSemesterScreen> {
//   bool isBookmarked = false; // initial value will be fetched from API
//   bool isLoading = true;
//   List<Map<String, dynamic>> semesters = [];
//
//   static const String API_BASE = AppConfig.baseUrl;
//   final String currentUserId = "testUser001"; // replace with logged-in user's UID
//
//   @override
//   void initState() {
//     super.initState();
//     fetchSemesters();
//     fetchBookmarkStatus();
//   }
//
//   Future<void> fetchSemesters() async {
//     setState(() => isLoading = true);
//     try {
//       final url = Uri.parse("$API_BASE/semesters/${widget.firebaseUid}");
//       final res = await http.get(url);
//
//       if (res.statusCode == 200) {
//         final List data = json.decode(res.body);
//         setState(() {
//           semesters = data.map<Map<String, dynamic>>((e) {
//             final id = e['id']?.toString() ?? e['_id']?.toString() ?? UniqueKey().toString();
//             final title = e['title']?.toString() ?? 'Untitled Semester';
//             return {'id': id, 'title': title};
//           }).toList();
//           isLoading = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//       print("Error fetching semesters: $e");
//     }
//   }
//
//   // Fetch whether the current user has bookmarked this profile
//   Future<void> fetchBookmarkStatus() async {
//     try {
//       final url = Uri.parse("$API_BASE/user-data/$currentUserId");
//       final res = await http.get(url);
//
//       if (res.statusCode == 200) {
//         final user = json.decode(res.body);
//         final List bookmarks = user['bookmarked'] ?? [];
//         setState(() {
//           isBookmarked = bookmarks.contains(widget.firebaseUid);
//         });
//       }
//     } catch (e) {
//       print("Error fetching bookmark status: $e");
//     }
//   }
//
//   Future<void> toggleBookmark() async {
//     try {
//       if (isBookmarked) {
//         // Remove bookmark using DELETE
//         final url = Uri.parse("$API_BASE/user-data/$currentUserId/bookmark/${widget.firebaseUid}");
//         final res = await http.delete(url);
//
//         if (res.statusCode == 200) {
//           setState(() => isBookmarked = false);
//         } else {
//           print("Failed to remove bookmark: ${res.body}");
//         }
//       } else {
//         // Add bookmark using POST
//         final url = Uri.parse("$API_BASE/user-data/$currentUserId/bookmark");
//         final res = await http.post(
//           url,
//           headers: {"Content-Type": "application/json"},
//           body: json.encode({"itemId": widget.firebaseUid}),
//         );
//
//         if (res.statusCode == 200) {
//           setState(() => isBookmarked = true);
//         } else {
//           print("Failed to add bookmark: ${res.body}");
//         }
//       }
//     } catch (e) {
//       print("Error toggling bookmark: $e");
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final accent = Colors.deepPurpleAccent;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0F2C),
//       appBar: AppBar(
//         foregroundColor: Colors.white,
//         backgroundColor: const Color(0xFF1B2660),
//         centerTitle: true,
//         title: Text("${widget.username}’s Profile"),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.white))
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Avatar + username + bookmark
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 40,
//                       backgroundImage: widget.avatarUrl != null
//                           ? NetworkImage(widget.avatarUrl!)
//                           : const AssetImage('assets/images/avatar_placeholder.png') as ImageProvider,
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Text(
//                         widget.username,
//                         style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Positioned(
//                   top: -4,
//                   left: 70,
//                   child: GestureDetector(
//                     onTap: toggleBookmark,
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 300),
//                       padding: const EdgeInsets.all(4),
//                       decoration: BoxDecoration(
//                         color: isBookmarked ? accent : Colors.transparent,
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.white70, width: 2),
//                       ),
//                       child: Icon(
//                         isBookmarked ? Icons.bookmark : Icons.bookmark_border,
//                         color: Colors.white,
//                         size: 22,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//
//             // Bio
//             if (widget.bio.isNotEmpty)
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1E2340),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Text(
//                   widget.bio,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     color: Colors.white70,
//                   ),
//                 ),
//               ),
//
//             const SizedBox(height: 50),
//
//             const Text(
//               "Semesters",
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 30),
//
//             // Semester cards
//             semesters.isEmpty
//                 ? const Center(
//               child: Text(
//                 "No semesters available",
//                 style: TextStyle(color: Colors.white70),
//               ),
//             )
//                 : GridView.builder(
//               physics: const NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//                 maxCrossAxisExtent: 220,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 childAspectRatio: 4 / 3,
//               ),
//               itemCount: semesters.length,
//               itemBuilder: (context, index) {
//                 final semester = semesters[index];
//                 final semesterTitle = semester['title'] ?? 'Untitled Semester';
//                 final semesterId = semester['id'] ?? '';
//
//                 if (semesterId.isEmpty) return const SizedBox();
//
//                 return GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => PublicSubjectScreen(
//                           semesterTitle: semesterTitle,
//                           semesterId: semesterId,
//                         ),
//                       ),
//                     );
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.15),
//                           blurRadius: 6,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: Text(
//                         semesterTitle,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//


import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/screens/explore/public-subject-screen.dart';
import 'package:untitled/config.dart';

class PublicSemesterScreen extends StatefulWidget {
  final String username;
  final String? avatarUrl;
  final String firebaseUid;
  final String bio;

  const PublicSemesterScreen({
    super.key,
    required this.username,
    this.avatarUrl,
    required this.firebaseUid,
    this.bio = "",
  });

  @override
  State<PublicSemesterScreen> createState() => _PublicSemesterScreenState();
}

class _PublicSemesterScreenState extends State<PublicSemesterScreen> {
  bool isBookmarked = false;
  bool isLoading = true;
  List<Map<String, dynamic>> semesters = [];

  final String currentUserId=FirebaseAuth.instance.currentUser!.uid; // Replace with actual logged-in UID

  @override
  void initState() {
    super.initState();
    fetchSemesters();
    fetchBookmarkStatus();
  }

  // ---------------- Avatar helper ----------------
  Widget buildAvatar(String name,
      {double radius = 40, Color? backgroundColor, double? textSize}) {
    String initials = "";
    final parts = name.trim().split(" ");
    if (parts.length == 1) {
      initials = parts[0].isNotEmpty ? parts[0][0].toUpperCase() : "U";
    } else if (parts.length >= 2) {
      initials = (parts[0][0] + parts[1][0]).toUpperCase();
    } else {
      initials = "U";
    }

    final bgColor = backgroundColor ?? const Color(0xFF1B2660);
    final fSize = textSize ?? (radius / 1.75);

    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: fSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ---------------- API calls ----------------
  Future<void> fetchSemesters() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse("${AppConfig.baseUrl}/semesters/${widget.firebaseUid}");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        setState(() {
          semesters = data.map<Map<String, dynamic>>((e) {
            final id = e['id']?.toString() ?? e['_id']?.toString() ?? UniqueKey().toString();
            final title = e['title']?.toString() ?? 'Untitled Semester';
            return {'id': id, 'title': title};
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching semesters: $e");
    }
  }

  Future<void> fetchBookmarkStatus() async {
    try {
      final url = Uri.parse("${AppConfig.baseUrl}/user-data/$currentUserId");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final user = json.decode(res.body);
        final List bookmarks = user['bookmarked'] ?? [];
        setState(() {
          isBookmarked = bookmarks.contains(widget.firebaseUid);
        });
      }
    } catch (e) {
      print("Error fetching bookmark status: $e");
    }
  }

  Future<void> toggleBookmark() async {
    try {
      if (isBookmarked) {
        // Remove bookmark on server
        final url = Uri.parse("${AppConfig.baseUrl}/user-data/$currentUserId/bookmark/${widget.firebaseUid}");
        final res = await http.delete(url);
        if (res.statusCode == 200) {
          setState(() => isBookmarked = false);
          // Update Hive
          final box = await Hive.box('userBox');
          final bookmarks = box.get('bookmarked', defaultValue: <String>[]) as List<String>;
          bookmarks.remove(widget.firebaseUid);
          await box.put('bookmarked', bookmarks);
        } else {
          print("Failed to remove bookmark: ${res.body}");
        }
      } else {
        // Add bookmark on server
        final url = Uri.parse("${AppConfig.baseUrl}/user-data/$currentUserId/bookmark");
        final res = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({"itemId": widget.firebaseUid}),
        );
        if (res.statusCode == 200) {
          setState(() => isBookmarked = true);
          // Update Hive
          final box = await Hive.openBox('userBox');
          final bookmarks = box.get('bookmarked', defaultValue: <String>[]) as List<String>;
          bookmarks.add(widget.firebaseUid);
          await box.put('bookmarked', bookmarks);
        } else {
          print("Failed to add bookmark: ${res.body}");
        }
      }
    } catch (e) {
      print("Error toggling bookmark: $e");
    }
  }


  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final accent = Colors.deepPurpleAccent;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF1B2660),
        centerTitle: true,
        title: Text("${widget.username}’s Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + username + bookmark
            Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  children: [
                    widget.avatarUrl != null
                        ? CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(widget.avatarUrl!),
                    )
                        : buildAvatar(widget.username, radius: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.username,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: -4,
                  left: 70,
                  child: GestureDetector(
                    onTap: toggleBookmark,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isBookmarked ? accent : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white70, width: 2),
                      ),
                      child: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bio
            if (widget.bio.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2340),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.bio,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ),

            const SizedBox(height: 50),
            const Text(
              "Semesters",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),

            // Semester cards
            semesters.isEmpty
                ? const Center(
              child: Text(
                "No semesters available",
                style: TextStyle(color: Colors.white70),
              ),
            )
                : GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 4 / 3,
              ),
              itemCount: semesters.length,
              itemBuilder: (context, index) {
                final semester = semesters[index];
                final semesterTitle = semester['title'] ?? 'Untitled Semester';
                final semesterId = semester['id'] ?? '';
                if (semesterId.isEmpty) return const SizedBox();

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PublicSubjectScreen(
                          semesterTitle: semesterTitle,
                          semesterId: semesterId,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        semesterTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
