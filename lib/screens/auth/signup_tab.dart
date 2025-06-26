import 'package:elure_app/models/api_models.dart';
import 'package:elure_app/screens/main_navigation_screen.dart';
import 'package:elure_app/services/api_service.dart';
import 'package:flutter/material.dart';

class SignUpTab extends StatefulWidget {
  const SignUpTab({super.key});

  @override
  State<SignUpTab> createState() => _SignUpTabState();
}

class _SignUpTabState extends State<SignUpTab> {
  // Global key that uniquely identifies the Form widget and allows validation.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for text input fields.
  final TextEditingController _nameController = TextEditingController();
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to handle sign up logic
  Future<void> _handleSignUp() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signing up...')));

      try {
        final AuthResponse response = await _apiService.registerUser(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));

        // Navigate to home screen on successful registration
        // Use pushReplacement to prevent going back to login/signup from home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      } on ErrorResponse catch (e) {
        // Handle API specific errors (e.g., validation errors, email already registered)
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
        print('Sign Up Error: $errorMessage');
      } catch (e) {
        // Handle other unexpected errors (e.g., network issues)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
          ),
        );
        print('Unexpected Sign Up Error: $e');
      }
    } else {
      print('Sign Up form validation failed.');
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
            // "Name" label
            const Text(
              'Name',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            // Name input field
            TextFormField(
              controller: _nameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'John Doe',
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
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

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
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters long';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),

            // "Sign Up" button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _handleSignUp, // Call the sign up handler
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Social login options (optional, mirroring login_tab but can be removed if not needed for sign up)
            Row(
              children: <Widget>[
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'or sign up with',
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
