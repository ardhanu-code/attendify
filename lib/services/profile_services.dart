import 'dart:convert';
import 'dart:io';
import 'package:attendify/endpoint/endpoint.dart';
import 'package:http/http.dart' as http;
import 'package:attendify/models/profile_model.dart';
import 'package:attendify/models/edit_profile_model.dart';
import 'package:attendify/models/edit_profile_photo_model.dart';

class ProfileServices {
  static Future<ProfileData> fetchProfile(String token) async {
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

  static Future<EditProfileData> updateProfileName({
    required String token,
    required String name,
  }) async {
    final url = Uri.parse(Endpoint.profile);
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({'name': name}),
    );
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return EditProfileResponse.fromJson(jsonBody).data;
    } else {
      throw Exception('Failed to update profile');
    }
  }

  static Future<PhotoProfileData> uploadProfilePhotoBase64({
    required String token,
    required File photoFile,
  }) async {
    final url = Uri.parse(Endpoint.profilePhoto);
    final bytes = await photoFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({'profile_photo': base64Image}),
    );
    print('Upload photo status: \\${response.statusCode}');
    print('Upload photo body: \\${response.body}');
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return EditProfilePhotoResponse.fromJson(jsonBody).data;
    } else {
      throw Exception('Failed to upload profile photo: \\${response.body}');
    }
  }
}
