import 'package:flutter/material.dart';
import 'package:nourish/services/food_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFoodItem extends StatefulWidget {
  @override
  _AddFoodItemState createState() => _AddFoodItemState();
}

class _AddFoodItemState extends State<AddFoodItem> {
  final TextEditingController _foodController = TextEditingController();
  Map<String, dynamic>? nutritionData;
  bool isLoading = false;
  bool isSaving = false;
  String message = "";

  // ✅ Analyze Food API Call
  void analyzeFood() async {
    if (_foodController.text.trim().isEmpty) {
      setState(() {
        message = "❌ Please enter a food item!";
      });
      return;
    }

    setState(() {
      isLoading = true;
      message = ""; // Clear previous messages
    });

    try {
      print("📡 Sending food analysis request for: ${_foodController.text}");
      final data = await FoodService.analyzeFood(_foodController.text);

      if (data == null) {
        print("❌ No nutrition data received!");
        setState(() {
          message = "❌ Failed to fetch nutrition data.";
          isLoading = false;
        });
        return;
      }

      print("✅ Nutrition data received: $data");
      setState(() {
        nutritionData = data;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Exception: $e");
      setState(() {
        message = "❌ Something went wrong!";
        isLoading = false;
      });
    }
  }

  // ✅ Save Food Data to Database
 Future<void> saveFoodData() async {
  if (nutritionData == null) return;

  setState(() => isSaving = true);
    Future<String?> _getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('_id');  // ✅ Retrieve _id from SharedPreferences
}


  bool success = await FoodService.addFoodToDatabase(
    foodName: _foodController.text,
    proteinG: nutritionData!['protein_g']?.toDouble() ?? 0.0,
    carbG: nutritionData!['carb_g']?.toDouble() ?? 0.0,
    fatG: nutritionData!['fat_g']?.toDouble() ?? 0.0,
    fibreG: nutritionData!['fibre_g']?.toDouble() ?? 0.0,
    energyKcal: nutritionData!['energy_kcal']?.toDouble() ?? 0.0,
    glycemicIndex: nutritionData!['glycemic_index']?.toInt() ?? 0,  // ✅ Added glycemic index
    // userId: await _getUserId() // ✅ Set user ID dynamically if needed
  );

  setState(() {
    isSaving = false;
    message = success ? "✅ Food saved to database!" : "❌ Failed to save food.";
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Food Nutrition Analyzer")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _foodController,
              decoration: InputDecoration(labelText: "Enter food name"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: analyzeFood,
              child: Text("Analyze Food"),
            ),
            if (isLoading) CircularProgressIndicator(),
            if (nutritionData != null) ...[
              Text("Calories: ${nutritionData!['energy_kcal']} kcal"),
              Text("Carbs: ${nutritionData!['carb_g']} g"),
              Text("Protein: ${nutritionData!['protein_g']} g"),
              Text("Fat: ${nutritionData!['fat_g']} g"),
              Text("Fiber: ${nutritionData!['fibre_g']} g"),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: isSaving ? null : saveFoodData,
                child: isSaving ? CircularProgressIndicator() : Text("Save to Database"),
              ),
              if (message.isNotEmpty) Text(message, style: TextStyle(color: Colors.green)),
            ],
          ],
        ),
      ),
    );
  }
}
