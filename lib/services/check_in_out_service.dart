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
    required DateTime attendanceDate,
    String? alasanIzin,
  }) async {
    final url = Uri.parse(Endpoint.checkIn);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Format date sesuai model (yyyy-MM-dd)
    final String formattedDate =
        "${attendanceDate.year.toString().padLeft(4, '0')}-${attendanceDate.month.toString().padLeft(2, '0')}-${attendanceDate.day.toString().padLeft(2, '0')}";

    // Format jam dan menit saja
    final String checkInTime =
        "${attendanceDate.hour.toString().padLeft(2, '0')}:${attendanceDate.minute.toString().padLeft(2, '0')}";

    // Format lokasi string
    final String locationString = "${lat.toString()},${lng.toString()}";

    final body = <String, dynamic>{
      'attendance_date': formattedDate,
      'check_in': checkInTime,
      'check_in_lat': lat.toString(),
      'check_in_lng': lng.toString(),
      'check_in_location': locationString,
      'check_in_address': address,
    };

    // Tambahkan alasan_izin hanya jika ada dan status adalah izin
    if (alasanIzin != null &&
        alasanIzin.isNotEmpty &&
        status.toLowerCase() == 'izin') {
      body['alasan_izin'] = alasanIzin;
    }

    print('Check-in request body: ${jsonEncode(body)}');
    print('Check-in URL: $url');
    print('Check-in headers: $headers');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
    print('Check-in response status: ${response.statusCode}');
    print('Check-in response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return checkInResponseFromJson(response.body);
    } else {
      String message = 'Gagal check in';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['message'] != null) {
          message = data['message'];
        }
      } catch (_) {}
      throw Exception('$message (Status: ${response.statusCode})');
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
    final url = Uri.parse(Endpoint.checkOut);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

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
