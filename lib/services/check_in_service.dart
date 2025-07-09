import 'dart:convert';

import 'package:attendify/endpoint/endpoint.dart';
import 'package:attendify/models/check_in_model.dart';
import 'package:attendify/models/check_out_model.dart';
import 'package:http/http.dart' as http;

class CheckInService {
  /// Melakukan check in ke API
  /// [token] = Bearer token user
  /// [lat], [lng], [address], [status], [alasanIzin] = data check in
  static Future<CheckInResponse> checkIn({
    required String token,
    required double lat,
    required double lng,
    required String address,
    required String status,
    String? alasanIzin,
  }) async {
    final url = Uri.parse(Endpoint.checkIn);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = <String, dynamic>{
      'check_in_lat': lat.toString(),
      'check_in_lng': lng.toString(),
      'check_in_address': address,
      'status': status,
    };
    if (alasanIzin != null && alasanIzin.isNotEmpty) {
      body['alasan_izin'] = alasanIzin;
    }
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return checkInResponseFromJson(response.body);
    } else {
      // Coba parsing error message dari response
      String message = 'Gagal check in';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['message'] != null) {
          message = data['message'];
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  /// Melakukan check out ke API
  /// [token] = Bearer token user
  /// [lat], [lng], [address] = data check out
  static Future<CheckOutResponse> checkOut({
    required String token,
    required double lat,
    required double lng,
    required String address,
  }) async {
    final url = Uri.parse(Endpoint.baseUrl + '/absen/checkout');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = <String, dynamic>{
      'check_out_lat': lat.toString(),
      'check_out_lng': lng.toString(),
      'check_out_address': address,
    };
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return checkOutResponseFromJson(response.body);
    } else {
      String message = 'Gagal check out';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['message'] != null) {
          message = data['message'];
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  /// Mengecek apakah user sudah check in hari ini
  static Future<bool> hasCheckedInToday({required String token}) async {
    final url = Uri.parse(Endpoint.allHistoryAbsen);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map && data['data'] is List) {
        final List<dynamic> absenList = data['data'];
        final today = DateTime.now();
        for (final absen in absenList) {
          if (absen is Map &&
              absen['check_in'] != null &&
              absen['status'] != null) {
            final checkInDate = DateTime.tryParse(absen['check_in']);
            if (checkInDate != null &&
                checkInDate.year == today.year &&
                checkInDate.month == today.month &&
                checkInDate.day == today.day &&
                absen['status'].toString().toLowerCase() == 'masuk') {
              return true;
            }
          }
        }
      }
      return false;
    } else {
      throw Exception('Gagal memeriksa status check in hari ini');
    }
  }
}
