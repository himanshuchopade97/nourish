import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int calories = 1800;

  Widget _buildCard(
      {required IconData icon,
      required String title,
      required String buttonText}) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome!',
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
              icon: Icons.home_outlined,
              title: 'Home',
              onTap: ()async {
                // Navigate to Home
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.recommend_outlined,
              title: 'Recommendations',
              onTap: () {
                // Navigate to Recommendations
                Navigator.pushNamed(context, '/recommendations');
              },
            ),
            _buildDrawerItem(
              icon: Icons.favorite_outline,
              title: 'Track Vitals',
              onTap: () {
                // Navigate to Track Vitals
                Navigator.pushNamed(context, '/vitals');
                
              },
            ),
            _buildDrawerItem(
              icon: Icons.star_outline,
              title: 'Explore Premium',
              onTap: () {
                // Navigate to Explore Premium
              },
            ),
            const Divider(color: Colors.white),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                // Handle logout logic (e.g., clear session, navigate to login)
                Navigator.pushReplacementNamed(context, '/landing'); // Adjust route as needed
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
                    // Circular Progress Indicator
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
                                value: calories / 3000,
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

                    // Nutritional Bars
                    Column(
                      children: [
                        _buildNutrientRow("Protein", 0.7),
                        _buildNutrientRow("Fiber", 0.5),
                        _buildNutrientRow("Carbs", 0.8),
                        _buildNutrientRow("Fats", 0.3),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Add Food Item Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle Add Food Item action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("Add Food Item"),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Grid Cards
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
                value: value,
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
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }
}
