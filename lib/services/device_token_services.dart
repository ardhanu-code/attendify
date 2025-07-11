import 'dart:convert';

import 'package:attendify/endpoint/endpoint.dart';
import 'package:attendify/preferences/preferences.dart';
import 'package:http/http.dart' as http;

/// Model for device token response
class DeviceTokenResponse {
  final String message;
  final DeviceTokenData data;

  DeviceTokenResponse({required this.message, required this.data});

  factory DeviceTokenResponse.fromJson(Map<String, dynamic> json) {
    return DeviceTokenResponse(
      message: json['message'],
      data: DeviceTokenData.fromJson(json['data']),
    );
  }
}

class DeviceTokenData {
  final int userId;
  final String playerId;

  DeviceTokenData({required this.userId, required this.playerId});

  factory DeviceTokenData.fromJson(Map<String, dynamic> json) {
    return DeviceTokenData(
      userId: json['user_id'],
      playerId: json['player_id'],
    );
  }
}

/// Send device token (player_id) to backend
Future<DeviceTokenResponse> sendDeviceToken(String playerId) async {
  final token = await Preferences.getToken();
  if (token == null || token.isEmpty) {
    throw Exception('User token is required');
  }

  final url = Uri.parse('${Endpoint.baseUrl}/device-token');
  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
  final body = jsonEncode({'player_id': playerId});

  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    final jsonResponse = json.decode(response.body);
    return DeviceTokenResponse.fromJson(jsonResponse);
  } else {
    String message = 'Failed to send device token';
    try {
      final errorData = json.decode(response.body);
      if (errorData is Map && errorData['message'] != null) {
        message = errorData['message'];
      }
    } catch (_) {}
    throw Exception('$message (Status: ${response.statusCode})');
  }
}
