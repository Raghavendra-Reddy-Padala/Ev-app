import 'package:flutter/material.dart';



class CompanyLogo extends StatefulWidget {
  const CompanyLogo({super.key});

  @override
  _CompanyLogoState createState() => _CompanyLogoState();
}

class _CompanyLogoState extends State<CompanyLogo> {
  late String _currentLogo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateLogo();
  }

  void _updateLogo() {

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    setState(() {
      _currentLogo = isDarkMode ? AssetsStrings.lightLogo : AssetsStrings.darkLogo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(_currentLogo);
  }
}

