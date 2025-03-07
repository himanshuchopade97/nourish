import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nourish/pages/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> loginUser(BuildContext context, String username, String password) async {
  final url = Uri.parse('http://10.0.2.2:5000/api/auth/login'); // Update with your login API URL

  final data = {
    'username': username, // Send username
    'password': password, // Send password
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      // Login successful, navigate to dashboard
      final responseData = json.decode(response.body);
      final token = responseData['token'];
      final userId = responseData['user']['id'];
      final storedUsername = responseData['user']['username']; // Extract username

      // Store token, userId, and username in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userId', userId);
      await prefs.setString('username', storedUsername); // Store username

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
      const SnackBar(content: Text('Network error! Please try again later.')),
    );
  }
}