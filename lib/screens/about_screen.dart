import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
        title: const Text('About Malware Detector', style: TextStyle(color: Colors.cyanAccent)),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Malware Detector is a mobile app that uses AI to detect malicious APKs.\n\nDeveloped as part of a graduation project at EELU.\n\nVersion 1.0.0\n© 2025 Malware Hunter Team.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}
