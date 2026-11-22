import 'package:flutter/material.dart';

import 'screens/account_screens.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

void main() {
  runApp(const CampusMarketApp());
}

class CampusMarketApp extends StatefulWidget {
  const CampusMarketApp({super.key});

  @override
  State<CampusMarketApp> createState() => _CampusMarketAppState();
}

class _CampusMarketAppState extends State<CampusMarketApp> {
  bool _signedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusMarket',
      debugShowCheckedModeBanner: false,
      theme: campusMarketTheme(),
      home: _signedIn
          ? HomeScreen(onLogout: () => setState(() => _signedIn = false))
          : LoginScreen(onLogin: () => setState(() => _signedIn = true)),
    );
  }
}
