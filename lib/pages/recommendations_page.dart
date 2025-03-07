import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({Key? key}) : super(key: key);

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _foodHistory = [];
  List<String> _recommendations = [];
  List<MealOption> _mealOptions = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Step 1: Get user ID and token
      final userId = await _getUserId();
      if (userId == null) {
        setState(() {
          _error = 'Unable to fetch user ID. Please log in again.';
          _isLoading = false;
        });
        return;
      }

      // Step 2: Fetch food history from MongoDB
      final history = await _fetchFoodHistory(userId);
      if (history.isEmpty) {
        setState(() {
          _error = 'No food history found. Add some foods first!';
          _isLoading = false;
        });
        print("Food History: $history");
        return;
      }

      setState(() {
        _foodHistory = history;
      });

      // Step 3: Generate recommendations based on food history
      final recommendations = await _generateRecommendations(history);
      
      setState(() {
        _recommendations = recommendations;
        _mealOptions = _processMealOptions(recommendations);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading recommendations: $e';
        _isLoading = false;
      });
    }
  }

  // Process the raw recommendations into structured meal options
  List<MealOption> _processMealOptions(List<String> rawRecommendations) {
    List<MealOption> options = [];
    MealOption? currentOption;
    bool isHeader = false;
    
    for (var line in rawRecommendations) {
      line = line.trim();
      
      // Remove asterisks from the line before processing
      line = line.replaceAll('*', '');
      
      // Check if this is an option header (contains "Option")
      if (line.contains("Option")) {
        isHeader = true;
        // Create a new meal option
        currentOption = MealOption(title: line, details: []);
        options.add(currentOption);
      } 
      // If this is a detail line and we have a current option
      else if (currentOption != null && !isHeader) {
        currentOption.details.add(line);
      }
      // This handles the case where it's the first detail line after a header
      else if (currentOption != null && isHeader) {
        isHeader = false;
        currentOption.details.add(line);
      }
      // If we don't have a current option yet, create one with a generic title
      else {
        currentOption = MealOption(title: "Meal Option", details: [line]);
        options.add(currentOption);
      }
    }
    
    // If we ended up with no options (unlikely but possible), create a default
    if (options.isEmpty) {
      options.add(MealOption(
        title: "Recommended Meal Option", 
        details: ["Please add more food history for better recommendations"]
      ));
    }
    
    return options;
  }

  Future<String?> _getUserId() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        print("❌ Error: No auth token found.");
        return null;
      }

      final response = await http.get(
        Uri.parse('https://nourish-backend-enzv.onrender.com/api/users/profile'),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Fetched user ID from /profile: ${data['_id']}");
        return data['_id'] as String;
      } else {
        print("❌ Failed to load profile: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Failed to load profile: $e");
      return null;
    }
  }

  Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      print("❌ No auth token found in SharedPreferences!");
    } else {
      print("✅ Retrieved auth token: $token");
    }

    return token;
  }

  Future<List<Map<String, dynamic>>> _fetchFoodHistory(String userId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception("No auth token found");
      }

      final response = await http.get(
        Uri.parse('https://nourish-backend-enzv.onrender.com/api/food/get-food?userId=$userId'),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> foods = jsonDecode(response.body);
        return foods.map((food) => food as Map<String, dynamic>).toList();
      } else {
        throw Exception("Failed to load food history: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching food history: $e");
      throw Exception("Failed to load food history");
    }
  }

  Future<List<String>> _generateRecommendations(List<Map<String, dynamic>> foodHistory) async {
    try {
      // Prepare data for Together AI analysis
      final foodSummary = foodHistory.map((food) => {
        "name": food['food_name'],
        "protein": food['protein_g'],
        "carbs": food['carb_g'],
        "fat": food['fat_g'],
        "fiber": food['fibre_g'],
        "calories": food['energy_kcal'],
        "glycemic_index": food['glycemic_index']
      }).toList();

      // Check if we have meaningful data
      if (foodSummary.isEmpty) {
        return ["Please add more food items to get personalized recommendations."];
      }

      const String apiKey = "bb8315f0403a1dc870b93a1cb678a2d9a12fcda4e7b82d02442207314b48a9bc";
      const String baseUrl = "https://api.together.xyz/v1/chat/completions";

      // Create a more detailed prompt for the AI
      final prompt = """
Generate a meal plan for a user with the following details: ${jsonEncode(foodSummary)}. The current meal is lunch. Provide 3 meal options based on the type of the meal
""";

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
              "content": "You are a nutrition expert. Generate a personalized meal plan based on the user's context. The meal plan should be strictly based on users's existing habits, which are given in the context. Additionally, consider the current time of the day and provide 3 meal options for the user to choose from. Do not print the current context , only give meal plan based on current time of the day (example 3 meal options for lunch if current time is between 12 noon to 3:30 pm),make sure it is suitable for diabetic person(low glycemic index) also make sure that the options that you give are a compatible meal choice altogether, indian cuisine , along with calories /100 gms and macros and should be strictly according to the user's past eating habits, healthy and low glycemic index food required."
            },
            {
              "role": "user",
              "content": prompt
            }
          ],
          "max_tokens": 500,
          "temperature": 0.7
        }),
      );

      print("📡 API Response from Together AI: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data.containsKey('choices') && data['choices'][0].containsKey('message')) {
          String rawRecommendations = data['choices'][0]['message']['content'].trim();
          
          // Split recommendations by new line
          List<String> recommendations = rawRecommendations
              .split('\n')
              .where((line) => line.trim().isNotEmpty)
              .toList();
          
          // If recommendations are too few, add a default one
          if (recommendations.length < 3) {
            recommendations.add("Consider adding more variety to your diet for better nutritional balance.");
          }
          
          return recommendations;
        }
      }
      
      return ["Unable to generate personalized recommendations at this time."];
    } catch (e) {
      print("❌ Error generating recommendations: $e");
      return ["Error generating recommendations. Please try again later."];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Recommendations'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.green, // This sets the text and icon color
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecommendations,
            color: Colors.green,
          ),
        ],
      ),
      body: Container(
        color: Colors.black87, // Dark background for the entire page
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ))
            : _error.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _error,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _loadRecommendations,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Based on Your Eating Habits',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Analyzed ${_foodHistory.length} items from your food history',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Recommended Foods For You',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _mealOptions.length,
                            itemBuilder: (context, index) {
                              final option = _mealOptions[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 16),
                                color: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Colors.green.shade800, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title section
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade900,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.circular(18),
                                              border: Border.all(color: Colors.green, width: 2),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              option.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Details section
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: option.details.length,
                                      itemBuilder: (context, detailIndex) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16, 
                                            vertical: 8
                                          ),
                                          child: Text(
                                            option.details[detailIndex],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

// Model class to structure meal options
class MealOption {
  final String title;
  final List<String> details;

  MealOption({required this.title, required this.details});
}