import 'dart:convert'; // Added for jsonEncode and jsonDecode

import 'package:attendify/endpoint/endpoint.dart';
import 'package:attendify/models/check_out_model.dart';
import 'package:http/http.dart' as http;

import '../models/absen_history_model.dart';
import '../models/stat_absen_model.dart';
import '../models/today_absen_model.dart';

class AbsenServices {
  static Map<String, String> _buildHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  static Future<List<HistoryAbsenData>> fetchAbsenHistory(String token) async {
    final response = await http.get(
      Uri.parse(Endpoint.allHistoryAbsen),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final result = historyAbsenResponseFromJson(response.body);
      return result.data; // <-- ini yang dibutuhkan
    } else {
      throw Exception('Failed to load history');
    }
  }

  static Future<StatAbsenResponse> fetchStatAbsen(String token) async {
    final url = Uri.parse(Endpoint.statAbsen);
    final response = await http.get(url, headers: _buildHeaders(token));

    if (response.statusCode == 200) {
      return statAbsenResponseFromJson(response.body);
    } else {
      throw Exception('Failed to load stat absen: ${response.statusCode}');
    }
  }

  /// Mengambil data absensi hari ini
  static Future<TodayAbsenResponse> fetchTodayAbsen(String token) async {
    final url = Uri.parse(Endpoint.todayAbsen);
    final response = await http.get(url, headers: _buildHeaders(token));
    print(response.body);
    if (response.statusCode == 200) {
      return todayAbsenResponseFromJson(response.body);
    } else if (response.statusCode == 404) {
      // Tidak ada data absensi hari ini
      return TodayAbsenResponse(
        message: "Tidak ada data absensi hari ini",
        data: null,
      );
    } else {
      throw Exception('Failed to load today absen: ${response.statusCode}');
    }
  }

  static Future<CheckOutResponse> checkOut({
    required String token,
    required double lat,
    required double lng,
    required String address,
  }) async {
    final url = Uri.parse(Endpoint.checkOut);
    final headers = _buildHeaders(token);
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
}
