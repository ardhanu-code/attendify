import 'dart:convert';

import 'package:attendify/endpoint/endpoint.dart';
import 'package:attendify/models/login_model.dart';
import 'package:attendify/models/register_model.dart';
import 'package:attendify/preferences/preferences.dart';
import 'package:http/http.dart' as http;

/// Common headers for HTTP requests
Map<String, String> getHeader() {
  return <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

Map<String, String> getHeadersLogin(String token) {
  return <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}

/// Register a new user and return the [User] model from register_model.dart
Future<User> registerUser(
  String name,
  String email,
  String password,
  String jenisKelamin,
  String profilePhoto,
  int batchId,
  int trainingId,
) async {
  final response = await http.post(
    Uri.parse(Endpoint.register),
    headers: getHeader(),
    body: jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      'jenis_kelamin': jenisKelamin,
      'profile_photo': profilePhoto,
      'batch_id': batchId,
      'training_id': trainingId,
    }),
  );

  print(response.body);

  if (response.statusCode == 200) {
    final registerResponse = RegisterResponse.fromJson(
      json.decode(response.body),
    );
    return registerResponse.data.user;
  } else {
    throw Exception('Failed to register user.');
  }
}

/// Login a user without requiring a token (for initial login)
Future<UserLogin> loginUserWithoutToken(String email, String password) async {
  final url = Uri.parse(Endpoint.login);
  final headers = getHeader();
  final body = {'email': email, 'password': password};

  print('DEBUG: Login without token URL: $url');
  print('DEBUG: Login without token headers: $headers');
  print('DEBUG: Login without token body: ${jsonEncode(body)}');

  final response = await http.post(
    url,
    headers: headers,
    body: jsonEncode(body),
  );

  print('DEBUG: Login without token response status: ${response.statusCode}');
  print('DEBUG: Login without token response body: ${response.body}');

  if (response.statusCode == 200 || response.statusCode == 201) {
    try {
      final loginResponse = LoginResponse.fromJson(json.decode(response.body));
      // Save token to preferences
      await Preferences.saveToken(loginResponse.data.token);
      return loginResponse.data.user;
    } catch (e) {
      print('DEBUG: Error parsing login response: $e');
      throw Exception('Error parsing login response: $e');
    }
  } else {
    String message = 'Failed to login user';
    try {
      final errorData = json.decode(response.body);
      if (errorData is Map && errorData['message'] != null) {
        message = errorData['message'];
      }
    } catch (_) {}
    throw Exception('$message (Status: ${response.statusCode})');
  }
}

/// Login a user, save the token, and return the [UserLogin] model from login_model.dart
Future<UserLogin> loginUser(String email, String password, String token) async {
  final url = Uri.parse(Endpoint.login);

  // Use different headers based on whether token is provided
  final headers = token.isNotEmpty ? getHeadersLogin(token) : getHeader();
  final body = {'email': email, 'password': password};

  print('DEBUG: Login URL: $url');
  print('DEBUG: Login headers: $headers');
  print('DEBUG: Login body: ${jsonEncode(body)}');
  print('DEBUG: Token provided: ${token.isNotEmpty ? "Yes" : "No"}');

  final response = await http.post(
    url,
    headers: headers,
    body: jsonEncode(body),
  );

  print('DEBUG: Login response status: ${response.statusCode}');
  print('DEBUG: Login response body: ${response.body}');

  if (response.statusCode == 200 || response.statusCode == 201) {
    try {
      final loginResponse = LoginResponse.fromJson(json.decode(response.body));
      // Save token to preferences
      await Preferences.saveToken(loginResponse.data.token);
      return loginResponse.data.user;
    } catch (e) {
      print('DEBUG: Error parsing login response: $e');
      throw Exception('Error parsing login response: $e');
    }
  } else {
    String message = 'Failed to login user';
    try {
      final errorData = json.decode(response.body);
      if (errorData is Map && errorData['message'] != null) {
        message = errorData['message'];
      }
    } catch (_) {}
    throw Exception('$message (Status: ${response.statusCode})');
  }
}
