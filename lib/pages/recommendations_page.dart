import 'package:flutter/material.dart';

class RecommendationsPage extends StatefulWidget {
  @override
  _RecommendationsPageState createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  String selectedFood = "Food Name";
  double protein = 0.0, fats = 0.0, carbs = 0.0, fiber = 0.0;
  int quantity = 1;

  final Map<String, Map<String, double>> foodData = {
    "Avocado": {"Protein": 2.0, "Fats": 15.0, "Carbs": 9.0, "Fiber": 7.0},
    "Strawberries": {"Protein": 0.8, "Fats": 0.3, "Carbs": 7.7, "Fiber": 2.0},
    "Chicken Breast": {"Protein": 31.0, "Fats": 3.6, "Carbs": 0.0, "Fiber": 0.0},
    "Almonds": {"Protein": 21.0, "Fats": 49.0, "Carbs": 22.0, "Fiber": 12.0},
    "Whole Grain Bread": {"Protein": 4.0, "Fats": 1.0, "Carbs": 13.0, "Fiber": 2.0},
    "Salmon": {"Protein": 25.0, "Fats": 13.0, "Carbs": 0.0, "Fiber": 0.0},
  };

  void updateFood(String food) {
    setState(() {
      selectedFood = food;
      protein = foodData[food]?["Protein"] ?? 0.0;
      fats = foodData[food]?["Fats"] ?? 0.0;
      carbs = foodData[food]?["Carbs"] ?? 0.0;
      fiber = foodData[food]?["Fiber"] ?? 0.0;
    });
  }

  void updateQuantity(int change) {
    setState(() {
      quantity = (quantity + change).clamp(1, 10);
    });
  }

  void addCustomFood() {
    String foodName = "";
    double proteinVal = 0.0, fatsVal = 0.0, carbsVal = 0.0, fiberVal = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Custom Food"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Food Name"),
                onChanged: (value) => foodName = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Protein (g)"),
                keyboardType: TextInputType.number,
                onChanged: (value) => proteinVal = double.tryParse(value) ?? 0.0,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Fats (g)"),
                keyboardType: TextInputType.number,
                onChanged: (value) => fatsVal = double.tryParse(value) ?? 0.0,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Carbs (g)"),
                keyboardType: TextInputType.number,
                onChanged: (value) => carbsVal = double.tryParse(value) ?? 0.0,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Fiber (g)"),
                keyboardType: TextInputType.number,
                onChanged: (value) => fiberVal = double.tryParse(value) ?? 0.0,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (foodName.isNotEmpty) {
                  setState(() {
                    foodData[foodName] = {
                      "Protein": proteinVal,
                      "Fats": fatsVal,
                      "Carbs": carbsVal,
                      "Fiber": fiberVal,
                    };
                  });
                  Navigator.pop(context);
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Add Food Item", style: TextStyle(color: Colors.grey[100]),),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              color: Colors.grey[900],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      selectedFood,
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, color: Colors.white),
                          onPressed: () => updateQuantity(-1),
                        ),
                        Text(
                          "$quantity",
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.white),
                          onPressed: () => updateQuantity(1),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text("100g", style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNutritionCard("Protein", protein),
                        _buildNutritionCard("Fats", fats),
                        _buildNutritionCard("Carbs", carbs),
                        _buildNutritionCard("Fiber", fiber),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text("Get More Recommendations", style: TextStyle(color: Colors.grey[200],fontSize: 16),),
            ),
            SizedBox(height: 20),
            Text(
              "Suggested Foods",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: foodData.keys.map((food) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                  ),
                  onPressed: () => updateFood(food),
                  child: Text(food, style: TextStyle(color: Colors.white, fontSize: 15)),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Card(
              color: Colors.grey[900],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Did You Know?\nEating fiber-rich foods like oats and lentils can help maintain healthy digestion and keep you full for longer!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addCustomFood,
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.grey[100],),
      ),
    );
  }

  Widget _buildNutritionCard(String title, double value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        SizedBox(height: 5),
        Text(
          "$value g",
          style: TextStyle(color: Colors.green, fontSize: 16),
        ),
      ],
    );
  }
}
