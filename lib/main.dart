import 'package:flutter/material.dart';
import 'package:nourish/pages/add_food_item.dart';
import 'package:nourish/pages/premium.dart';
import 'package:nourish/pages/profilepage.dart';
import 'package:nourish/pages/recommendations_page.dart';
import 'package:nourish/pages/dashboard.dart';
import 'package:nourish/pages/homepage.dart';
import 'package:nourish/pages/loginpage.dart';
import 'package:nourish/pages/registerpage.dart';
import 'package:nourish/pages/vitals.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nourish',
      routes: {
        '/': (context) => HomePage(), // Dashboard page route
        '/landing': (context) => HomePage(),
        '/login': (context) => LoginPage(), // Login page route
        '/register': (context) => RegisterPage(), //Register page route
        '/dashboard': (context) => DashboardPage(),
        '/recommendations': (context) => RecommendationsPage(),
        '/vitals': (context) => VitalsPage(),
        '/addfooditem': (context) => AddFoodItem(),
        '/profile': (context) => ProfilePage(),
        '/premium': (context) => ExplorePremium(),
      },
      theme: ThemeData(primarySwatch: Colors.green),
      // home:  AddNewFood(),
    );
  }
}
