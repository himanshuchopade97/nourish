import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nourish/pages/loginpage.dart';

Future<void> registerUser(BuildContext context, String name, String email, String password) async {
  final url = Uri.parse('http://192.168.1.9:5000/api/auth/register'); // Update with your registration API URL

  final data = {
    'name': name,
    'email': email,
    'password': password,
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      // Registration successful, navigate to login page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User registered successfully!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed! ${response.body}')),
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
