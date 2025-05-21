import 'package:flutter/material.dart';

class BackToLoginButton extends StatelessWidget {
  final Function onTap;

  const BackToLoginButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onTap(),
      child: const Text("Change Phone Number"),
    );
  }
}
