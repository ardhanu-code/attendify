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

    print(response.body);
    if (response.statusCode == 200) {
      // Parse menggunakan model yang benar sesuai response API
      final historyResponse = historyAbsenResponseFromJson(response.body);
      return historyResponse.data;
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
  static Future<TodayAbsenResponse> fetchTodayAbsen(
    String token, {
    DateTime? tanggal,
  }) async {
    // Ambil tanggal hari ini jika tidak diberikan
    final DateTime date = tanggal ?? DateTime.now();
    final String formattedDate =
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    // Asumsikan endpoint menerima query param ?tanggal=yyyy-MM-dd
    final url = Uri.parse(Endpoint.todayAbsen(formattedDate));
    final response = await http.get(url, headers: _buildHeaders(token));
    print('DEBUG: Today absen API response body: ${response.body}');
    print('DEBUG: Today absen API status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      try {
        return todayAbsenResponseFromJson(response.body);
      } catch (e) {
        print('DEBUG: Error parsing today absen response: $e');
        // Return a safe response if parsing fails
        return TodayAbsenResponse(
          message: "Error parsing response: $e",
          data: null,
        );
      }
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

    // Format current time for check out
    final now = DateTime.now();
    final checkOutTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    // Format attendance date (YYYY-MM-DD)
    final attendanceDate =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final body = <String, dynamic>{
      'attendance_date': attendanceDate,
      'check_out': checkOutTime,
      'check_out_lat': lat.toString(),
      'check_out_lng': lng.toString(),
      'check_out_location': "${lat.toString()},${lng.toString()}",
      'check_out_address': address,
    };

    print('DEBUG: Check-out request body: ${jsonEncode(body)}');
    print('DEBUG: Check-out URL: $url');
    print('DEBUG: Check-out headers: $headers');
    print('DEBUG: Attendance date: $attendanceDate');
    print('DEBUG: Check-out time: $checkOutTime');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    print('DEBUG: Check-out response status: ${response.statusCode}');
    print('DEBUG: Check-out response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final checkOutResponse = checkOutResponseFromJson(response.body);
        print('DEBUG: Parsed check-out response successfully');
        print('DEBUG: Message: ${checkOutResponse.message}');
        print('DEBUG: Data ID: ${checkOutResponse.data.id}');
        print('DEBUG: Check-out time: ${checkOutResponse.data.checkOutTime}');
        return checkOutResponse;
      } catch (e) {
        print('DEBUG: Error parsing check-out response: $e');
        throw Exception('Error parsing response: $e');
      }
    } else {
      String message = 'Gagal check out';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['message'] != null) {
          message = data['message'];
        }
      } catch (_) {}
      throw Exception('$message (Status: ${response.statusCode})');
    }
  }
}
