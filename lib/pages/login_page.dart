import 'package:attendance_system/pages/navigation_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String errorMessage = "";
  bool _isLoading = false; // ADDED: Loading state

  final Color darkBlue = const Color(0xFF152874);

  // UPDATED: Added async and loading state
  Future<void> _validateAndLogin() async {
    setState(() {
      errorMessage = "";
      _isLoading = true;
    });

    // Simulate network delay (remove in production or replace with actual API call)
    await Future.delayed(const Duration(seconds: 1));

    if (_emailController.text.trim() == "user@gmail.com" &&
        _passwordController.text == "user123") {
      setState(() {
        _isLoading = false; // Stop loading before navigation
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigationPage()),
      );
    } else {
      setState(() {
        errorMessage = "Invalid email or password!";
        _isLoading = false; // Stop loading on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.groups, size: 60, color: darkBlue),
                const SizedBox(height: 40),
                // Email field
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _emailController,
                    enabled: !_isLoading, // Disable when loading
                    decoration: InputDecoration(
                      hintText: "Email/Id",
                      filled: true,
                      fillColor: darkBlue,
                      hintStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                // Password field
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _passwordController,
                    enabled: !_isLoading, // Disable when loading
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      filled: true,
                      fillColor: darkBlue,
                      hintStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                // Error message display
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                // Login button with loading state
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF074DA9),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(100, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _validateAndLogin, // Disable when loading
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text("Login", style: TextStyle(fontSize: 16)),
                ),
                // Demo credentials info
                const SizedBox(height: 20),
                Text(
                  "Demo credentials:\nuser@gmail.com / user123",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
