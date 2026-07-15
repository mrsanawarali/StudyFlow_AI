import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/config.dart';
import 'package:untitled/screens/auth/responsive_form_container.dart';
import '../../clippers/top_pattern_clipper.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ------------------------------ REGISTER USER ------------------------------
  Future<void> _registerUser() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if ([username, email, password, confirmPassword].any((e) => e.isEmpty)) {
      _showMessage("All fields are required");
      return;
    }

    if (password != confirmPassword) {
      _showMessage("Passwords do not match");
      return;
    }

    UserCredential? credential;

    try {
      // 1️⃣ Create Firebase user
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(username);
      final firebaseUid = credential.user?.uid;

      // 2️⃣ Send data to backend with one retry and 1s delay
      final url = Uri.parse("${AppConfig.baseUrl}/user-data");
      bool backendSuccess = false;

      for (int attempt = 1; attempt <= 2 && !backendSuccess; attempt++) {
        try {
          final response = await http.post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "firebaseUid": firebaseUid,
              "name": username,
              "email": email,
              "bio": "",
              "profile_pic": ""
            }),
          );

          if (response.statusCode == 201) {
            backendSuccess = true;
            _showMessage("Account created successfully!");
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            final error = jsonDecode(response.body);
            _showMessage("Backend error: ${error['message']}");
          }
        } catch (_) {
          if (attempt == 2) {
            _showMessage("Backend request failed twice. Please try again later.");
          } else {
            // wait 1 second before retrying
            await Future.delayed(const Duration(seconds: 1));
          }
        }
      }

      // Delete Firebase user if backend failed
      if (!backendSuccess) await credential.user?.delete();
    } on FirebaseAuthException catch (e) {
      _showMessage(
        e.code == 'weak-password'
            ? "The password is too weak"
            : e.code == 'email-already-in-use'
            ? "Email already in use"
            : e.message ?? "Something went wrong",
      );
    } catch (e) {
      _showMessage("Unexpected error: $e");
      if (credential?.user != null) await credential!.user!.delete();
    }
  }

  // Snackbar message
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ------------------------------ UI ------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopPattern(),
            const SizedBox(height: 25),
            Text("Create Account",
                style: GoogleFonts.poppins(
                    fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text("Sign up to get started",
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.white70)),
            const SizedBox(height: 30),
            ResponsiveFormContainer(
              children: [
                _buildTextField("Username", _usernameController, prefixIcon: Icons.person),
                const SizedBox(height: 15),
                _buildTextField("Email", _emailController, prefixIcon: Icons.email),
                const SizedBox(height: 15),
                _buildTextField(
                  "Password",
                  _passwordController,
                  obscure: _obscurePassword,
                  prefixIcon: Icons.lock,
                  suffixIcon: _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  onSuffixTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  "Confirm Password",
                  _confirmPasswordController,
                  obscure: _obscureConfirmPassword,
                  prefixIcon: Icons.lock,
                  suffixIcon: _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  onSuffixTap: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                const SizedBox(height: 25),

                // SIGN UP BUTTON → CALL REGISTER FUNCTION
                _buildButton("Sign Up", _registerUser),

                const SizedBox(height: 25),
                _buildOrDivider(),
                const SizedBox(height: 25),
                _buildSocialIcons(),
                const SizedBox(height: 25),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: Text("Already have an account? Login",
                      style: GoogleFonts.poppins(
                          color: const Color(0xFF6C8AE4), fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------ Widgets ------------------------------
  Widget _buildTopPattern() => ClipPath(
    clipper: TopPatternClipper(),
    child: Container(
      height: 220,
      color: const Color(0xFF1B2660),
      child: const Center(
        child: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: Icon(Icons.school, size: 60, color: Color(0xFF0A0F2C)),
        ),
      ),
    ),
  );

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscure = false,
        IconData? prefixIcon,
        IconData? suffixIcon,
        VoidCallback? onSuffixTap}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1A1F3F),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.white70) : null,
        suffixIcon: suffixIcon != null
            ? GestureDetector(onTap: onSuffixTap, child: Icon(suffixIcon, color: Colors.white70))
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E3A7A), width: 2),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) => SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E3A7A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      onPressed: onPressed,
      child: Text(text,
          style: GoogleFonts.poppins(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
    ),
  );

  Widget _buildOrDivider() => Row(
    children: const [
      Expanded(child: Divider(color: Colors.white30, thickness: 1, endIndent: 10)),
      Text("or continue with", style: TextStyle(color: Colors.white60)),
      Expanded(child: Divider(color: Colors.white30, thickness: 1, indent: 10)),
    ],
  );

  Widget _buildSocialIcons() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _socialIcon(Icons.g_mobiledata, Colors.red),
      _socialIcon(Icons.facebook, Colors.blueAccent),
      _socialIcon(Icons.apple, Colors.white),
    ],
  );

  Widget _socialIcon(IconData icon, Color color) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0),
    child: CircleAvatar(
      radius: 22,
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 26),
    ),
  );
}

