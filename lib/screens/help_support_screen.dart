import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
        title: const Text('Help & Support', style: TextStyle(color: Colors.cyanAccent)),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Need help?\n\nContact us:\n📧 support@malwarehunter.com\n\nWe’re here to assist you within 24 hours.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}
