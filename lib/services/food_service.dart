import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FoodService {
  // API endpoints
  static const String togetherApiUrl = "https://api.together.xyz/v1/chat/completions";
  static const String togetherApiKey = "bb8315f0403a1dc870b93a1cb678a2d9a12fcda4e7b82d02442207314b48a9bc";
  
  // Backend API base URL (no port specification)
  static const String backendBaseUrl = "https://nourish-backend-enzv.onrender.com";
  static const String mongoDbApiUrl = "$backendBaseUrl/api/food/add-food";
  static const String userProfileUrl = "$backendBaseUrl/api/users/profile";

  // ✅ Fetch JWT token from SharedPreferences
  static Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      print("❌ No auth token found in SharedPreferences!");
    } else {
      print("✅ Retrieved auth token: ${token.substring(0, 10)}..."); // Only log part of the token for security
    }

    return token;
  }

  // ✅ Get user ID - consolidated method that tries SharedPreferences first, then API
  static Future<String?> _getUserId() async {
    // First try to get from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('_id');
    
    if (userId != null) {
      print("✅ Retrieved user ID from SharedPreferences: $userId");
      return userId;
    }
    
    // If not in SharedPreferences, fetch from API
    try {
      final token = await _getAuthToken();
      if (token == null) {
        print("❌ Error: No auth token found when trying to get user ID");
        return null;
      }

      print("📡 Fetching user profile from: $userProfileUrl");
      final response = await http.get(
        Uri.parse(userProfileUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("📡 Profile API response status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userId = data['_id'] as String;
        
        // Save to SharedPreferences for future use
        await prefs.setString('_id', userId);
        
        print("✅ Fetched and saved user ID: $userId");
        return userId;
      } else {
        print("❌ Failed to load profile: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Exception when loading profile: $e");
      return null;
    }
  }

  // ✅ Analyze food using AI (Now includes Glycemic Index)
  static Future<Map<String, dynamic>?> analyzeFood(String food) async {
    try {
      print("📡 Analyzing food: $food");
      final response = await http.post(
        Uri.parse(togetherApiUrl),
        headers: {
          "Authorization": "Bearer $togetherApiKey",
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

      print("📡 AI API Response status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data.containsKey('choices') &&
            data['choices'][0].containsKey('message')) {
          String nutritionText = data['choices'][0]['message']['content']
              .replaceAll("```json", "")
              .replaceAll("```", "")
              .trim();

          // Try to parse the JSON response
          try {
            final nutritionData = jsonDecode(nutritionText);
            
            return {
              "food_name": food,
              "energy_kcal": nutritionData["calories"],
              "carb_g": nutritionData["carbs"],
              "protein_g": nutritionData["protein"],
              "fat_g": nutritionData["fat"],
              "fibre_g": nutritionData["fiber"],
              "glycemic_index": nutritionData["glycemic_index"],
            };
          } catch (e) {
            print("❌ Error parsing nutrition JSON: $e");
            print("⚠️ Nutrition text received: $nutritionText");
            return null;
          }
        } else {
          print("❌ Unexpected API response format: $data");
          return null;
        }
      } else {
        print("❌ Error analyzing food: ${response.statusCode} - ${response.body}");
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
    String? userId, // Optional parameter - we'll fetch it if not provided
  }) async {
    try {
      print("📡 Starting addFoodToDatabase process");
      
      // Get auth token
      final token = await _getAuthToken();
      if (token == null) {
        print("❌ Error: No auth token found for adding food.");
        return false;
      }

      // Get user ID if not provided
      final String actualUserId;
      if (userId != null && userId.isNotEmpty) {
        actualUserId = userId;
        print("✅ Using provided userId: $actualUserId");
      } else {
        final fetchedId = await _getUserId();
        if (fetchedId == null) {
          print("❌ Error: Could not retrieve user ID.");
          return false;
        }
        actualUserId = fetchedId;
        print("✅ Using fetched userId: $actualUserId");
      }

      // Prepare payload
      final payload = {
        "userId": actualUserId,
        "food_name": foodName,
        "protein_g": proteinG,
        "carb_g": carbG,
        "fat_g": fatG,
        "fibre_g": fibreG,
        "energy_kcal": energyKcal,
        "glycemic_index": glycemicIndex,
      };
      
      print("📤 Sending payload to $mongoDbApiUrl: $payload");

      // Send request
      final response = await http.post(
        Uri.parse(mongoDbApiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      print("📡 Server Response: ${response.statusCode}");
      print("📡 Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Food successfully added to database!");
        return true;
      } else {
        print("❌ Error adding food to database: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Exception while adding food to database: $e");
      return false;
    }
  }
}