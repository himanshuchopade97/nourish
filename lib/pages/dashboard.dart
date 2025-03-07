import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:animate_do/animate_do.dart'; // Import animate_do

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int calories = 0;
  double protein = 0.0;
  double carbs = 0.0;
  double fat = 0.0;
  double fiber = 0.0;
  String username = "";
  bool _isLoading = true;
  String userId = '';
  List<String> selectedFoodItems = [];

  @override
  void initState() {
    super.initState();
    _getUsername();
    _fetchFoodData(); // Fetch food data on page load
  }

  Future<String> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
    setState(() {
      username = prefs.getString('username') ?? "User";
    });
    return username;
  }

  Future<void> _fetchFoodData() async {
    setState(() {
      _isLoading = true; // Set loading to true
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? token = prefs.getString('token');

    if (userId == null || userId.isEmpty || token == null || token.isEmpty) {
      setState(() {
        _isLoading = false; // Set loading to false
      });
      return;
    }
    try {
      final response = await http.get(
        Uri.parse("https://nourish-backend-enzv.onrender.com/api/food/get-food?userId=$userId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          calories = data.fold<int>(
              0, (sum, item) => sum + (item["energy_kcal"] as num).toInt());
          protein = data.fold<double>(
              0, (sum, item) => sum + (item["protein_g"] as num).toDouble());
          carbs = data.fold<double>(
              0, (sum, item) => sum + (item["carb_g"] as num).toDouble());
          fat = data.fold<double>(
              0, (sum, item) => sum + (item["fat_g"] as num).toDouble());
          fiber = data.fold<double>(
              0, (sum, item) => sum + (item["fibre_g"] as num).toDouble());
          _isLoading = false; // Set loading to false
        });
      } else {
        print("Error fetching food data: ${response.body}");
        setState(() {
          _isLoading = false; // Set loading to false
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load food data: ${response.body}')),
        );
      }
    } catch (e) {
      print("Network Error: $e");
      setState(() {
        _isLoading = false; // Set loading to false
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please try again.')),
      );
    }
  }

  Widget _buildCard(
      {required IconData icon,
      required String title,
      required String buttonText}) {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.2),
              spreadRadius: 8,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.green, size: 40),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 36, // Fixed height for buttons
              child: ElevatedButton(
                onPressed: () {
                  // Handle button action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    buttonText,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.account_circle, size: 60, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    "Welcome, $username",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Dashboard Menu',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
                icon: Icons.person,
                title: 'Profile',
                onTap: () async {
                  Navigator.pushNamed(context, '/profile');
                }),
            _buildDrawerItem(
                icon: Icons.home_outlined,
                title: 'Home',
                onTap: () async {
                  Navigator.pop(context);
                }),
            _buildDrawerItem(
                icon: Icons.recommend_outlined,
                title: 'Recommendations',
                onTap: () {
                  Navigator.pushNamed(context, '/recommendations');
                }),
            _buildDrawerItem(
                icon: Icons.favorite_outline,
                title: 'Track Vitals',
                onTap: () {
                  Navigator.pushNamed(context, '/vitals');
                }),
            _buildDrawerItem(
                icon: Icons.star_outline,
                title: 'Explore Premium',
                onTap: () {
                  Navigator.pushNamed(context, '/premium');
                }),
            const Divider(color: Colors.white),
            _buildDrawerItem(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.remove('token');
                  await prefs.remove('username');
                  await prefs.remove('_id');
                  Navigator.pushReplacementNamed(context, '/landing');
                }),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.green,
            ))
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 150,
                                    height: 150,
                                    child: CircularProgressIndicator(
                                      value: (calories / 3000).clamp(0.0, 1.0),
                                      strokeWidth: 10,
                                      backgroundColor: Colors.grey.shade800,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    "$calories\nCalories",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Column(
                            children: [
                              _buildNutrientRow("Protein", protein / 100),
                              _buildNutrientRow("Fiber", fiber / 100),
                              _buildNutrientRow("Carbs", carbs / 100),
                              _buildNutrientRow("Fats", fat / 100),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: Colors.green, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.2),
                                    spreadRadius: 7,
                                    blurRadius: 8,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.pushNamed(context, '/addfooditem');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text("Add Food Item",
                                    style: TextStyle(fontSize: 16)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildCard(
                                  icon: Icons.bloodtype_outlined,
                                  title: "Sugar Levels",
                                  buttonText: "Add Reading",
                                ),
                                _buildCard(
                                  icon: Icons.monitor_weight_outlined,
                                  title: "Body Weight",
                                  buttonText: "Add Reading",
                                ),
                                _buildCard(
                                  icon: Icons.visibility_outlined,
                                  title: "Recommendations",
                                  buttonText: "Review",
                                ),
                                _buildCard(
                                  icon: Icons.support_agent,
                                  title: "ChatBot",
                                  buttonText: "Coming Soon",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNutrientRow(String nutrient, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nutrient,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                color: Colors.green,
                backgroundColor: Colors.grey[800],
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Text(
            "${(value * 100).toInt()}%",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}