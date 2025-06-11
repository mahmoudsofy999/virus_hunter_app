import 'dart:convert';
import 'package:flutter/foundation.dart'; // 👈 Needed for kDebugMode
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://ecommerce.routemisr.com/api/v1';

  static Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    required String rePassword,
    required String phone,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/signup');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "rePassword": rePassword,
          "phone": phone,
        }),
      );

      if (kDebugMode) {
        print('SignUp → Status Code: ${response.statusCode}');
        print('SignUp → Response Body: ${response.body}');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode != 201) {
        return {
          "message": data["message"] ?? "Something went wrong",
          "status": "fail"
        };
      }

      return data;
    } catch (e) {
      if (kDebugMode) print('SignUp Error: $e');
      return {"message": "Exception: $e", "status": "fail"};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/signin');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (kDebugMode) {
        print('Login → Status Code: ${response.statusCode}');
        print('Login → Response Body: ${response.body}');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        return {
          "message": data["message"] ?? "Login failed",
          "status": "fail"
        };
      }

      return data;
    } catch (e) {
      if (kDebugMode) print('Login Error: $e');
      return {"message": "Exception: $e", "status": "fail"};
    }
  }
}
