import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FoodService {
  static const String baseUrl = "https://api.together.xyz/v1/chat/completions";
  static const String apiKey =
      "bb8315f0403a1dc870b93a1cb678a2d9a12fcda4e7b82d02442207314b48a9bc";

  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('_id'); // ✅ Retrieve _id from SharedPreferences
  }

  static const String mongoDbApiUrl = "http://10.0.2.2:5000/api/food/add-food";

  // ✅ Fetch JWT token from SharedPreferences
  static Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      print("❌ No auth token found in SharedPreferences!");
    } else {
      print("✅ Retrieved auth token: $token");
    }

    return token;
  }

  // ✅ Analyze food using AI (Now includes Glycemic Index)
  static Future<Map<String, dynamic>?> analyzeFood(String food) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "meta-llama/Llama-3.3-70B-Instruct-Turbo",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a nutrition expert. Return valid JSON with only calories, carbs, protein, fat, fiber, and glycemic index per 100g food. No markdown."
            },
            {
              "role": "user",
              "content":
                  "Give nutrition details for: $food strictly in JSON. No markdown."
            }
          ],
          "max_tokens": 200,
          "temperature": 0.7
        }),
      );

      print("📡 API Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data.containsKey('choices') &&
            data['choices'][0].containsKey('message')) {
          String nutritionText = data['choices'][0]['message']['content']
              .replaceAll("```json", "")
              .replaceAll("```", "")
              .trim();

          return {
            "food_name": food, // ✅ Store food name
            "energy_kcal": jsonDecode(nutritionText)[
                "calories"], // Convert "calories" to "energy_kcal"
            "carb_g": jsonDecode(nutritionText)["carbs"],
            "protein_g": jsonDecode(nutritionText)["protein"],
            "fat_g": jsonDecode(nutritionText)["fat"],
            "fibre_g": jsonDecode(
                nutritionText)["fiber"], // Convert "fiber" to "fibre_g"
            "glycemic_index": jsonDecode(
                nutritionText)["glycemic_index"], // ✅ New glycemic index field
          };
        } else {
          print("❌ Unexpected API response format: $data");
          return null;
        }
      } else {
        print("❌ Error analyzing food: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Exception while analyzing food: $e");
      return null;
    }
  }

  // ✅ Add food data to MongoDB (Now includes Glycemic Index)
  static Future<bool> addFoodToDatabase({
    required String foodName,
    required int proteinG,
    required int carbG,
    required int fatG,
    required int fibreG,
    required int energyKcal,
    required int glycemicIndex,
    required String? userId,
  }) async {
    Future<String?> _getUserId() async {
      try {
        final token = await _getAuthToken();
        if (token == null) {
          print("❌ Error: No auth token found.");
          return null;
        }

        final response = await http.get(
          Uri.parse(
              'http://10.0.2.2:5000/api/users/profile'), // Replace with your actual URL
          headers: {
            "Authorization": "Bearer $token",
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print("Fetched user ID from /profile: ${data['_id']}"); // Debugging
          return data['_id']
              as String; // Assuming the user ID is in the '_id' field
        } else {
          print("❌ Failed to load profile: ${response.body}");
          return null;
        }
      } catch (e) {
        print("❌ Failed to load profile: $e");
        return null;
      } // ✅ Retrieve _id from SharedPreferences
    }

    try {
      final token = await _getAuthToken();
      if (token == null) {
        print("❌ Error: No auth token found.");
        return false;
      }

      final userId = await _getUserId(); // ✅ Fetch user ID
      if (userId == null) {
        print("❌ Error: No user ID found.");
        return false;
      }

      final response = await http.post(
        Uri.parse(mongoDbApiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "userId": userId, // ✅ Include user ID
          "food_name": foodName,
          "protein_g": proteinG,
          "carb_g": carbG,
          "fat_g": fatG,
          "fibre_g": fibreG,
          "energy_kcal": energyKcal,
          "glycemic_index": glycemicIndex,
        }),
      );

      print("📡 Server Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Food successfully added to database!");
        return true;
      } else {
        print("❌ Error adding food to database: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Exception while sending data: $e");
      return false;
    }
  }
}
