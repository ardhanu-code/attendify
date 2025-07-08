import 'dart:convert';
import 'package:attendify/endpoint/endpoint.dart';
import 'package:http/http.dart' as http;
import 'package:attendify/models/profile_model.dart';

class ProfileServices {
  static Future<ProfileData> fetchProfile(String token) async {
    // Replace with your actual API endpoint
    final url = Uri.parse(Endpoint.profile);
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return ProfileResponse.fromJson(jsonBody).data;
    } else {
      throw Exception('Failed to load profile');
    }
  }
}
