import 'package:flutter/material.dart';
import 'package:nourish/models/login_user.dart'; // Make sure you have the appropriate model for login
import 'package:nourish/pages/dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isNotARobot = false;

  // Controllers for email and password fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/apple.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay
          Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'L O G I N',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 135,
                    ),

                    // Email Field
                    TextField(
                      controller: _emailController,  // Use controller for email field
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.white),
                        hintText: 'Email',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    TextField(
                      controller: _passwordController,  // Use controller for password field
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.white),
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 20),

                    // // "Not a robot" Checkbox
                    // Row(
                    //   children: [
                    //     Checkbox(
                    //       value: isNotARobot,
                    //       onChanged: (bool? value) {
                    //         setState(() {
                    //           isNotARobot = value ?? false;
                    //         });
                    //       },
                    //       activeColor: Colors.red,
                    //     ),
                    //     const Text(
                    //       'Not a robot',
                    //       style: TextStyle(color: Colors.white),
                    //     ),
                    //   ],
                    // ),

                    const SizedBox(height: 20),

                    // Submit Button
                    ElevatedButton(
                      onPressed: () {
                        // Call the login function with email and password
                        loginUser(
                          context,
                          _emailController.text,  // Get email from controller
                          _passwordController.text,  // Get password from controller
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: const Text('Submit'),
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
}
