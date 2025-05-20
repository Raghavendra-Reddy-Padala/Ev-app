import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginMainVeiw extends StatefulWidget {
  const LoginMainVeiw({super.key});

  @override
  State<LoginMainVeiw> createState() => _LoginMainVeiwState();
}

class _LoginMainVeiwState extends State<LoginMainVeiw> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Hi", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
