import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nourish/pages/dashboard.dart';

Future<void> loginUser(BuildContext context, String email, String password) async {
  final url = Uri.parse('http://10.24.67.143:5000/api/auth/login'); // Update with your login API URL

  final data = {
    'email': email,  // Send email
    'password': password,  // Send password
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      // Login successful, navigate to dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // Handle error (incorrect credentials or other issues)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed! ${response.body}')),
      );
    }
  } catch (e) {
    // Handle network error
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Network error! Please try again later.')),
    );
  }
}
