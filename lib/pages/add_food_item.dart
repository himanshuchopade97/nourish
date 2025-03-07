import 'package:flutter/material.dart';
import 'package:nourish/services/food_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFoodItem extends StatefulWidget {
  @override
  _AddFoodItemState createState() => _AddFoodItemState();
}

class _AddFoodItemState extends State<AddFoodItem>
    with SingleTickerProviderStateMixin {
  final TextEditingController _foodController = TextEditingController();
  Map<String, dynamic>? nutritionData;
  bool isLoading = false;
  bool isSaving = false;
  String message = "";

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  void analyzeFood() async {
    if (_foodController.text.trim().isEmpty) {
      setState(() {
        message = "❌ Please enter a food item!";
      });
      return;
    }

    setState(() {
      isLoading = true;
      message = "";
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
      _controller.forward(from: 0); // Animate when data appears
    } catch (e) {
      print("❌ Exception: $e");
      setState(() {
        message = "❌ Something went wrong!";
        isLoading = false;
      });
    }
  }

  Future<void> saveFoodData() async {
    if (nutritionData == null) return;
    setState(() => isSaving = true);

    try {
      bool success = await FoodService.addFoodToDatabase(
        foodName: _foodController.text,
        proteinG: nutritionData!['protein_g']?.toInt() ?? 0,
        carbG: nutritionData!['carb_g']?.toInt() ?? 0,
        fatG: nutritionData!['fat_g']?.toInt() ?? 0,
        fibreG: nutritionData!['fibre_g']?.toInt() ?? 0,
        energyKcal: nutritionData!['energy_kcal']?.toInt() ?? 0,
        glycemicIndex: nutritionData!['glycemic_index']?.toInt() ?? 0,
        userId: await _getUserId(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "✅ Food saved to database!" : "❌ Failed to save food."),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme background
      appBar: AppBar(
        title: const Text("Food Nutrition Analyzer", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black, // Green theme for app bar
         iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _foodController,
              style: TextStyle(color: Colors.white), // White text
              decoration: InputDecoration(
                labelText: "Enter food name",
                labelStyle: TextStyle(color: Colors.green),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.green[900]?.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: analyzeFood,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Analyze Food", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            if (nutritionData != null) ...[
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("🔹 Calories: ${nutritionData!['energy_kcal']} kcal",
                        style: TextStyle(color: Colors.green, fontSize: 18)),
                    Text("🔹 Carbs: ${nutritionData!['carb_g']} g",
                        style: TextStyle(color: Colors.green, fontSize: 18)),
                    Text("🔹 Protein: ${nutritionData!['protein_g']} g",
                        style: TextStyle(color: Colors.green, fontSize: 18)),
                    Text("🔹 Fat: ${nutritionData!['fat_g']} g",
                        style: TextStyle(color: Colors.green, fontSize: 18)),
                    Text("🔹 Fiber: ${nutritionData!['fibre_g']} g",
                        style: TextStyle(color: Colors.green, fontSize: 18)),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: isSaving ? null : saveFoodData,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSaving ? Colors.grey : Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Save to Database", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: message.startsWith("❌") ? Colors.red : Colors.green,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
