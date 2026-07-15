
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/screens/auth/responsive_form_container.dart';
import '../../clippers/top_pattern_clipper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // If successful → Navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String msg = "";

      if (e.code == 'user-not-found') {
        msg = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        msg = "Wrong password. Try again.";
      } else {
        msg = e.message ?? "Login failed!";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopPattern(),
            const SizedBox(height: 25),
            Text(
              "Learning One",
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Login to your account",
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 30),
            ResponsiveFormContainer(
              children: [
                _buildTextField(
                  "Email",
                  _usernameController,
                  prefixIcon: Icons.email,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  "Password",
                  _passwordController,
                  obscure: _obscurePassword,
                  prefixIcon: Icons.lock,
                  suffixIcon:
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  onSuffixTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                const SizedBox(height: 25),

                /// LOGIN BUTTON
                _buildButton(
                  _isLoading ? "Loading..." : "Login",
                  _isLoading ? null : _loginUser,
                ),

                const SizedBox(height: 25),
                _buildOrDivider(),
                const SizedBox(height: 25),
                _buildSocialIcons(),
                const SizedBox(height: 25),
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/signup'),
                  child: Text(
                    "Don't have an account? Sign up",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF6C8AE4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPattern() => ClipPath(
    clipper: TopPatternClipper(),
    child: Container(
      height: 220,
      color: const Color(0xFF1B2660),
      child: const Center(
        child: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: Icon(Icons.school,
              size: 60, color: Color(0xFF0A0F2C)),
        ),
      ),
    ),
  );

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscure = false,
        IconData? prefixIcon,
        IconData? suffixIcon,
        VoidCallback? onSuffixTap}) =>
      TextFormField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1A1F3F),
          prefixIcon:
          prefixIcon != null ? Icon(prefixIcon, color: Colors.white70) : null,
          suffixIcon: suffixIcon != null
              ? GestureDetector(
            onTap: onSuffixTap,
            child: Icon(suffixIcon, color: Colors.white70),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            const BorderSide(color: Color(0xFF2E3A7A), width: 2),
          ),
        ),
      );

  Widget _buildButton(String text, VoidCallback? onPressed) => SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E3A7A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  Widget _buildOrDivider() => Row(
    children: const [
      Expanded(
          child:
          Divider(color: Colors.white30, thickness: 1, endIndent: 10)),
      Text("or continue with", style: TextStyle(color: Colors.white60)),
      Expanded(
          child:
          Divider(color: Colors.white30, thickness: 1, indent: 10)),
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
