import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nourish/pages/loginpage.dart'; // Ensure correct import

Future<void> registerUser(BuildContext context, String firstName, String lastName, String email, String contact, String username, String password) async {
  final url = Uri.parse('http://192.168.1.8:5000/api/auth/register'); // Update with your registration API URL

  final data = {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'contact': contact,
    'username': username,
    'password': password,
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      // Registration successful, navigate to login page or dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User registered successfully!')),
      );
      Navigator.pushReplacementNamed(context, '/dashboard'); // Or '/login' if you want to navigate to login first
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
      const SnackBar(content: Text('Network error! Please try again later.')),
    );
  }
}