import 'package:flutter/material.dart';

class ExplorePremium extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background to black
      appBar: AppBar(
        title: Text('Explore Premium', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NutriBuddy - Your AI-Powered Nutritionist',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text for contrast
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Ask anything, anytime! Our smart AI Dietitian chatbot provides instant answers to all your nutrition and wellness queries, making healthy eating effortless.',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70), // Lighter white for readability
            ),
            SizedBox(height: 16),
            Text(
              'Expert Nutrition Guidance, Anytime',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text for contrast
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Get real-time advice from certified dietitians for personalized meal plans, blood sugar management, and holistic nutrition strategies because your health deserves expert care! ',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70), // Lighter white for readability
            ),
            SizedBox(height: 32),
            Text(
              'Choose Your Plan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            _buildPlanCard(
              title: 'Free',
              price: '\$0 /month',
              features: [
                'Basic calorie tracking',
                'Basic food database',
                'Community forum access',
              ],
              excludedFeatures: [
                'Nutri-Buddy AI Assistant',
                'Expert Nutrition Guidance',
              ],
              isCurrent: true,
            ),
            // SizedBox(height: 16),
            // _buildPlanCard(
            //   title: 'Pro',
            //   price: '\$9.99 /month',
            //   features: [
            //     'Advanced tracking',
            //     'Expanded food database',
            //     'Community access',
            //     'Nutri-Buddy AI Assistant',
            //   ],
            //   excludedFeatures: [
            //     'Expert Nutrition Guidance',
            //   ],
            //   buttonText: 'Get Pro',
            // ),
            SizedBox(height: 16),
            _buildPlanCard(
              title: 'Ultimate',
              price: '\$19.99 /month',
              features: [
                'Advanced tracking',
                'Complete food database',
                'Community access',
                'Nutri-Buddy AI Assistant',
                'Expert Nutrition Guidance',
              ],
              buttonText: 'Get Ultimate',
              isPopular: true,
            ),
            SizedBox(height: 32),
            Center(
              child: Text(
                '© 2025 Nourish. All rights reserved.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required List<String> features,
    List<String> excludedFeatures = const [],
    String buttonText = 'Current Plan',
    bool isCurrent = false,
    bool isPopular = false,
  }) {
    return Card(
      elevation: 4,
      color: Colors.grey[900], // Dark grey card background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Most Popular',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              price,
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            SizedBox(height: 16),
            ...features
                .map((feature) => _buildFeatureItem(feature, true))
                .toList(),
            ...excludedFeatures
                .map((feature) => _buildFeatureItem(feature, false))
                .toList(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isCurrent
                  ? null
                  : () {
                      // Handle plan selection
                    },
              child: Text(
                buttonText,
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrent ? Colors.grey : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, bool isIncluded) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isIncluded ? Icons.check_circle : Icons.cancel,
            color: isIncluded ? Colors.green : Colors.red,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
                fontSize: 14,
                color: Colors.white70), // Lighter white for readability
          ),
        ],
      ),
    );
  }
}
