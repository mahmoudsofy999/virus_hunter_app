import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_screen.dart';
import 'welcome_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? selectedFile;
  String fileName = 'No file selected';
  bool isScanning = false;
  double _progress = 0.0;
  String? scanResult;
  Color resultColor = Colors.transparent;
  bool isGuest = true;

  @override
  void initState() {
    super.initState();
    _loadGuestStatus();
  }

  Future<void> _loadGuestStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isGuest = prefs.getBool('isGuest') ?? true;
    });
  }

  Future<void> pickFile() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apk'],
    );

    if (picked != null && picked.files.single.path != null) {
      setState(() {
        selectedFile = File(picked.files.single.path!);
        fileName = picked.files.single.name;
      });
    } else {
      setState(() {
        selectedFile = null;
        fileName = 'No file selected';
      });
    }
  }

  void _setScanResult(String prediction) {
    setState(() {
      scanResult = prediction.toUpperCase();
      resultColor = prediction == 'benign'
          ? Colors.green
          : prediction == 'malware'
          ? Colors.red
          : Colors.orange;
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        scanResult = null;
      });
    });
  }

  Future<void> scanFile() async {
    if (selectedFile == null) return;

    final prefs = await SharedPreferences.getInstance();
    int guestScanCount = prefs.getInt('guestScanCount') ?? 0;

    if (isGuest && guestScanCount >= 3) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guest limit reached. Please sign up to continue.'),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
      return;
    }

    setState(() {
      isScanning = true;
      _progress = 0.0;
    });

    final stopwatch = Stopwatch()..start();

    final uri = Uri.parse('https://apk-analyzer-api-production.up.railway.app/predict_apk');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('apk', selectedFile!.path));

    late http.StreamedResponse response;
    late String respStr;

    try {
      response = await request.send();
      respStr = await response.stream.bytesToString();
    } catch (e) {
      stopwatch.stop();
      if (mounted) {
        setState(() {
          isScanning = false;
          _progress = 0.0;
        });
        _setScanResult('Error');
      }
      return;
    }

    stopwatch.stop();

    final totalDuration = stopwatch.elapsed.inMilliseconds;
    int elapsed = 0;
    const interval = 100;

    while (elapsed < totalDuration) {
      await Future.delayed(const Duration(milliseconds: interval));
      elapsed += interval;
      if (!mounted) return;
      setState(() {
        _progress = (elapsed / totalDuration).clamp(0.0, 1.0);
      });
    }

    if (mounted) {
      setState(() {
        isScanning = false;
        _progress = 1.0;
      });

      await Future.delayed(const Duration(milliseconds: 300));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(respStr);
        final prediction = jsonResponse['prediction']?.toString().toLowerCase() ?? 'unknown';
        _setScanResult(prediction);
      } else {
        _setScanResult('Scan failed (${response.statusCode})');
      }

      if (isGuest) {
        await prefs.setInt('guestScanCount', guestScanCount + 1);
      }

      await Future.delayed(const Duration(seconds: 5));
      if (mounted) {
        setState(() {
          _progress = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1A),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/circuit_bg3.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.cyanAccent, size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                );
              },
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.cyanAccent, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/logo_icon2.png', height: 100),
                  const SizedBox(height: 16),
                  Text(
                    'MALWARE DETECTOR',
                    style: GoogleFonts.poppins(
                      color: Colors.cyanAccent,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Image.asset('assets/robot2.png', height: 320),
                  const SizedBox(height: 16),
                  Text(
                    fileName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (isScanning)
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.white12,
                          color: Colors.cyanAccent,
                          minHeight: 6,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${(_progress * 100).toInt()}%',
                          style: const TextStyle(color: Colors.cyanAccent),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  GestureDetector(
                    onTap: pickFile,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E6FF), Color(0xFF00B8E6)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Upload File',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: isScanning ? null : scanFile,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C9FF), Color(0xFF0099CC)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: isScanning
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'Start Scan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (scanResult != null)
            Positioned(
              bottom: 30,
              left: 24,
              right: 24,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: resultColor.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: resultColor.withOpacity(0.6),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    scanResult!,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
