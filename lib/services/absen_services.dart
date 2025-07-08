import 'package:attendify/endpoint/endpoint.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/absen_history_model.dart';
import '../models/stat_absen_model.dart';

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
}
