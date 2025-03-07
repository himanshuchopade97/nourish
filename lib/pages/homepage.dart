import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.eco, size: 50, color: Colors.greenAccent),
            const Text(
              'Welcome to',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            // Glowing text effect
            Container(
              child: const Text(
                'Nourish',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 30,
                      color: Colors.greenAccent,
                      offset: Offset(0, 0),
                    ),
                    Shadow(
                      blurRadius: 50,
                      color: Colors.green,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Be fit from Within',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _featureCard(Icons.add, 'Personalized Plans',
                    'Tailored to your unique goals'),
                const SizedBox(width: 10),
                _featureCard(Icons.bar_chart, 'Track Progress',
                    'Monitor your fitness journey'),
                const SizedBox(width: 10),
                _featureCard(Icons.groups, 'Expert Community',
                    'Learn from fitness professionals'),
              ],
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _customButton('Login', true, () {
                  Navigator.pushNamed(context, '/login');
                }),
                const SizedBox(width: 20),
                _customButton('Sign Up', false, () {
                  Navigator.pushNamed(context, '/register');
                }),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Start your journey to a healthier lifestyle today',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _featureCard(IconData icon, String title, String subtitle) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 2),
        color: Colors.black54,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green, size: 40),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _customButton(String text, bool isPrimary, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: isPrimary ? Colors.green : Colors.black,
      foregroundColor: isPrimary ? Colors.white : Colors.green,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: const BorderSide(color: Colors.green),
      ),
    ),
    child: Text(text, style: const TextStyle(fontSize: 16)),
  );
}
