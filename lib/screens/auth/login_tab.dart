import 'package:elure_app/models/api_models.dart';
import 'package:elure_app/screens/home_screen.dart';
import 'package:elure_app/services/api_service.dart';
import 'package:flutter/material.dart';

class LoginTab extends StatefulWidget {
  const LoginTab({super.key});

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  // Global key that uniquely identifies the Form widget and allows validation.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for text input fields.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State variable to manage the visibility of the password.
  bool _isPasswordVisible = false;

  // Instance of ApiService to make API calls
  final ApiService _apiService = ApiService();

  // Define the primary pink color for consistency.
  static const Color primaryPink = Color(0xFFE91E63);

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to handle login logic
  Future<void> _handleLogin() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logging in...')));

      try {
        final AuthResponse response = await _apiService.loginUser(
          _emailController.text,
          _passwordController.text,
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));

        // Navigate to home screen on successful login
        // Use pushReplacement to prevent going back to login/signup from home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } on ErrorResponse catch (e) {
        // Handle API specific errors (e.g., validation errors, unauthorized)
        String errorMessage = e.message;
        if (e.errors != null) {
          // Concatenate specific field errors if they exist
          if (e.errors!.email != null) {
            errorMessage += '\nEmail: ${e.errors!.email!.join(', ')}';
          }
          if (e.errors!.password != null) {
            errorMessage += '\nPassword: ${e.errors!.password!.join(', ')}';
          }
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
        print('Login Error: $errorMessage');
      } catch (e) {
        // Handle other unexpected errors (e.g., network issues)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
          ),
        );
        print('Unexpected Login Error: $e');
      }
    } else {
      print('Login form validation failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, // Assign the GlobalKey to the Form
      child: SingleChildScrollView(
        // Added SingleChildScrollView to prevent overflow
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align elements to the start (left)
          children: <Widget>[
            // "Email" label
            const Text(
              'Email',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            // Email input field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'johndoe@example.com',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // "Password" label
            const Text(
              'Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            // Password input field
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: '********',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),

            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  print('Forgot Password tapped');
                  // Implement navigation to forgot password screen
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: primaryPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // "Login" button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _handleLogin, // Call the login handler
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Social login options
            Row(
              children: <Widget>[
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'or login with',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _socialButton(Icons.apple),
                const SizedBox(width: 20),
                _socialButton(Icons.g_mobiledata), // Placeholder for Google's G
                const SizedBox(width: 20),
                _socialButton(Icons.facebook),
              ],
            ),
            const SizedBox(height: 30),

            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  // Handle continue as guest logic
                  print('Continue as a guest');
                },
                child: RichText(
                  text: TextSpan(
                    text: 'OR Continue as a ',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    children: const [
                      TextSpan(
                        text: 'guest',
                        style: TextStyle(
                          color: primaryPink,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for social buttons
  Widget _socialButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Icon(icon, size: 30, color: Colors.black),
    );
  }
}
