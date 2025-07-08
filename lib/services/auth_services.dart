import 'dart:convert';

import 'package:attendify/endpoint/endpoint.dart';
import 'package:attendify/models/login_model.dart';
import 'package:attendify/models/register_model.dart';
import 'package:attendify/preferences/preferences.dart';
import 'package:http/http.dart' as http;

/// Common headers for HTTP requests
Map<String, String> getHeaders(String token) {
  return <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

/// Register a new user and return the [User] model from register_model.dart
Future<User> registerUser(
  String name,
  String email,
  String password,
  String jenisKelamin,
  String profilePhoto,
  String token,
  int batchId,
  int trainingId,
) async {
  final response = await http.post(
    Uri.parse(Endpoint.register),
    headers: getHeaders(token),
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

  if (response.statusCode == 201) {
    final registerResponse = RegisterResponse.fromJson(
      json.decode(response.body),
    );
    return registerResponse.data.user;
  } else {
    throw Exception('Failed to register user.');
  }
}

/// Login a user, save the token, and return the [UserLogin] model from login_model.dart
Future<UserLogin> loginUser(String email, String password, String token) async {
  final response = await http.post(
    Uri.parse(Endpoint.login),
    headers: getHeaders(token),
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    final loginResponse = LoginResponse.fromJson(json.decode(response.body));
    // Save token to preferences
    await Preferences.saveToken(loginResponse.data.token);
    return loginResponse.data.user;
  } else {
    throw Exception('Failed to login user.');
  }
}
