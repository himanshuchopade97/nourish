import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
    const ProfilePage({super.key});

    @override
    _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
    Map<String, dynamic> _userData = {};
    bool _isLoading = true;
    bool _isEditing = false;

    final TextEditingController _firstNameController = TextEditingController();
    final TextEditingController _lastNameController = TextEditingController();
    final TextEditingController _contactController = TextEditingController();

    @override
    void initState() {
        super.initState();
        _fetchProfileData();
    }

    @override
    void dispose() {
        _firstNameController.dispose();
        _lastNameController.dispose();
        _contactController.dispose();
        super.dispose();
    }

    Future<void> _fetchProfileData() async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        if (token == null) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please log in to view your profile.')),
            );
            Navigator.pushReplacementNamed(context, '/login');
            return;
        }

        final url = Uri.parse('http://10.0.2.2:5000/api/users/profile'); // Adjust URL if needed

        try {
            final response = await http.get(
                url,
                headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                },
            );

            if (response.statusCode == 200) {
                setState(() {
                    _userData = json.decode(response.body);
                    _isLoading = false;
                    _firstNameController.text = _userData['firstName'] ?? '';
                    _lastNameController.text = _userData['lastName'] ?? '';
                    _contactController.text = _userData['contact'] ?? '';
                });
            } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to load profile: ${response.body}')),
                );
                setState(() {
                    _isLoading = false;
                });
            }
        } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Network error. Please try again.')),
            );
            setState(() {
                _isLoading = false;
            });
        }
    }

    Future<void> _updateProfileData() async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        if (token == null) {
            return;
        }

        final url = Uri.parse('http://10.0.2.2:5000/api/users/profile'); // Adjust URL if needed

        try {
            final response = await http.put(
                url,
                headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                },
                body: json.encode({
                    'firstname': _firstNameController.text,
                    'lastname': _lastNameController.text,
                    'contact': _contactController.text,
                }),
            );

            if (response.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully!')),
                );
                setState(() {
                    _isEditing = false;
                    _fetchProfileData();
                });
            } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update profile: ${response.body}')),
                );
            }
        } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Network error. Please try again.')),
            );
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Profile'),
                actions: [
                    IconButton(
                        icon: Icon(_isEditing ? Icons.save : Icons.edit),
                        onPressed: () {
                            if (_isEditing) {
                                _updateProfileData();
                            }
                            setState(() {
                                _isEditing = !_isEditing;
                            });
                        },
                    ),
                ],
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _userData.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    _buildProfileItem('First Name', _firstNameController),
                                    _buildProfileItem('Last Name', _lastNameController),
                                    _buildProfileItem('Contact', _contactController),
                                ],
                            )
                            : const Center(child: Text('Profile data not available.')),
                    ),
                ),
        );
    }

    Widget _buildProfileItem(String label, TextEditingController controller) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (_isEditing)
                        TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                                hintText: 'Enter $label',
                            ),
                        )
                    else
                        Text(controller.text),
                    const Divider(),
                ],
            ),
        );
    }
}