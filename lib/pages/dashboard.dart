import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  String username = "Loading...";
  String userId = '';
  List<String> selectedFoodItems = [];

  @override
  void initState() {
    super.initState();
    _getUsername();
    _getSelectedFoodItems(); // Fetch food data on page load
  }

  Future<String> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('_id', userId);
    setState(() {
      username = prefs.getString('username') ?? "User";
      
    });
    return username;
  }

    Future<void> _getSelectedFoodItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedFoodItems = prefs.getStringList('selected_food') ?? [];
    });
    _fetchFoodData(); // Fetch only user-entered food data
  }

   Future<void> _fetchFoodData() async {
    if (selectedFoodItems.isEmpty) return; // If no food is selected, do nothing

    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.8:5000/api/auth/food"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"food_items": selectedFoodItems}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          calories = data.fold<int>(0, (sum, item) => sum + (item["energy_kcal"] as num).toInt());
          protein = data.fold<double>(0, (sum, item) => sum + (item["protein_g"] as num).toDouble());
          carbs = data.fold<double>(0, (sum, item) => sum + (item["carb_g"] as num).toDouble());
          fat = data.fold<double>(0, (sum, item) => sum + (item["fat_g"] as num).toDouble());
          fiber = data.fold<double>(0, (sum, item) => sum + (item["fibre_g"] as num).toDouble());
        });
      } else {
        print("Error fetching food data: ${response.body}");
      }
    } catch (e) {
      print("Network Error: $e");
    }
  }


  Widget _buildCard(
      {required IconData icon,
      required String title,
      required String buttonText}) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // Handle button action
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                alignment: Alignment.center),
            child: Text(
              buttonText,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
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
              decoration: BoxDecoration(color: Colors.green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.account_circle, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "Welcome, $username",
                    style: TextStyle(
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
              },
            ),
            _buildDrawerItem(
              icon: Icons.home_outlined,
              title: 'Home',
              onTap: () async {
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.recommend_outlined,
              title: 'Recommendations',
              onTap: () {
                Navigator.pushNamed(context, '/recommendations');
              },
            ),
            _buildDrawerItem(
              icon: Icons.favorite_outline,
              title: 'Track Vitals',
              onTap: () {
                Navigator.pushNamed(context, '/vitals');
              },
            ),
            _buildDrawerItem(
              icon: Icons.star_outline,
              title: 'Explore Premium',
              onTap: () {},
            ),
            const Divider(color: Colors.white),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                Navigator.pushReplacementNamed(context, '/landing');
              },
            ),
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
      body: SafeArea(
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
                      child: ElevatedButton(
                        onPressed: () async{
                           Navigator.pushNamed(context, '/addfooditem');
                          
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("Add Food Item"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics:  AlwaysScrollableScrollPhysics(),
                        children: [
                          _buildCard(
                            icon: Icons.bloodtype_outlined,
                            title: "Sugar Levels",
                            buttonText: "Add new Reading",
                          ),
                          _buildCard(
                            icon: Icons.monitor_weight_outlined,
                            title: "Body Weight",
                            buttonText: "Add new Reading",
                          ),
                          _buildCard(
                            icon: Icons.visibility_outlined,
                            title: "Recommendations",
                            buttonText: "Review",
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nutrient,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                color: Colors.green,
                backgroundColor: Colors.grey[800],
              ),
            ),
          ),
          Text(
            "${(value * 100).toInt()}%",
            style: const TextStyle(color: Colors.white),
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
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
