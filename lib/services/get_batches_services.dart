import 'dart:convert';

import 'package:attendify/endpoint/endpoint.dart';
import 'package:attendify/models/batches_models.dart';
import 'package:http/http.dart' as http;

class BatchesServices {
  static Map<String, String> getHeaders() {
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  static Future<BatchesResponse> fetchBatches() async {
    final response = await http.get(
      Uri.parse(Endpoint.getBatch),
      headers: getHeaders(),
    );

    print(response.body);

    if (response.statusCode == 200) {
      return BatchesResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load batches');
    }
  }
}
