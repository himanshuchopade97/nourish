import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:nourish/pages/dashboard.dart';

class Loginpage2 extends StatelessWidget {
  const Loginpage2({super.key});

  //login
  Future<String?> _authUser(BuildContext context,LoginData data) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DashboardPage()),
    );
    return null;
  }

  //recover password
  Future<String?> _recoverPassword(String data) {
    return Future.delayed(Duration(milliseconds: 2000));
  }

  //signup
  Future<String?> _signupUser(SignupData data) {
    return Future.delayed(Duration(microseconds: 2000));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterLogin(
        onLogin: (data) => _authUser(context, data),
        onRecoverPassword: _recoverPassword,
        loginAfterSignUp: false,
        onSignup: _signupUser,
      ),
    );
  }
}
