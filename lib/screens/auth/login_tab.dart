import 'package:elure_app/screens/home_screen.dart';
import 'package:flutter/material.dart';

class LoginTab extends StatefulWidget {
  const LoginTab({super.key});

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  // Global key that uniquely identifies the Form widget and allows validation.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for text input fields to retrieve their values.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State variable to manage the visibility of the password.
  bool _isPasswordVisible = false;
  // State variable for the "Remember me" checkbox.
  bool _rememberMe = false;

  // Define the primary pink color for consistency.
  static const Color primaryPink = Color(0xFFE91E63);

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, // Assign the GlobalKey to the Form
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align elements to the start (left)
        children: <Widget>[
          // "Email or phone" label
          const Text(
            'Email or phone',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          // Email/Phone input field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress, // Suggests email keyboard
            decoration: InputDecoration(
              hintText: 'johndoe@gmail.com', // Placeholder text
              filled: true,
              fillColor:
                  Colors.grey[100], // Light grey background for the input field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15), // Rounded corners
                borderSide: BorderSide.none, // No border line
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email or phone';
              }
              // Basic email validation regex
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value) &&
                  !RegExp(r'^[0-9]+$').hasMatch(value)) {
                return 'Please enter a valid email or phone number';
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
            obscureText: !_isPasswordVisible, // Toggles password visibility
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
                      : Icons
                            .visibility_off, // Icon changes based on visibility
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible =
                        !_isPasswordVisible; // Toggle password visibility
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters long';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          // "Remember me" checkbox and "Forgot Password?" link
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Space out elements
            children: <Widget>[
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _rememberMe =
                            newValue ?? false; // Update remember me state
                      });
                    },
                    activeColor: primaryPink, // Color when checkbox is checked
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        5,
                      ), // Slightly rounded checkbox corners
                    ),
                  ),
                  const Text('Remember me'),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Handle forgot password logic
                  print('Forgot Password?');
                },
                child: Text(
                  'Forgot Password ?',
                  style: TextStyle(
                    color: primaryPink, // Pink color for the link
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // "Log in" button
          SizedBox(
            width: double.infinity, // Full width button
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In a real app, you'd send data to a server.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                  print('Login attempt:');
                  print('Email: ${_emailController.text}');
                  print('Password: ${_passwordController.text}');
                  print('Remember Me: $_rememberMe');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                } else {
                  print('Login form validation failed.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPink, // Pink button background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    30,
                  ), // Highly rounded corners
                ),
              ),
              child: const Text(
                'Log in',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Divider with "or sign up with" text
          Row(
            children: <Widget>[
              const Expanded(child: Divider()), // Left divider line
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'or sign up with',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              const Expanded(child: Divider()), // Right divider line
            ],
          ),
          const SizedBox(height: 20),

          // Social login buttons (Apple, Google, Facebook)
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center the social icons
            children: <Widget>[
              _socialButton(Icons.apple), // Apple icon
              const SizedBox(width: 20),
              _socialButton(
                Icons.g_mobiledata,
              ), // Google icon (using g_mobiledata as a placeholder for Google's G, replace with actual SVG/Image if possible)
              const SizedBox(width: 20),
              _socialButton(Icons.facebook), // Facebook icon
            ],
          ),
          const SizedBox(height: 30),

          // "OR Continue as a guest" text link
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
                        color: primaryPink, // Pink for "guest"
                        fontWeight: FontWeight.bold,
                        decoration:
                            TextDecoration.underline, // Underline for link
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to create consistent social media buttons
  Widget _socialButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100], // Light grey background
        shape: BoxShape.circle, // Circular shape
        border: Border.all(color: Colors.grey[300]!), // Light grey border
      ),
      child: Icon(
        icon,
        size: 30,
        color: Colors.black, // Icon color
      ),
    );
  }
}
