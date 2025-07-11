import 'dart:convert';

import 'package:attendify/endpoint/endpoint.dart';
import 'package:attendify/models/forgot_password_model.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordServices {
  static Map<String, String> _buildHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  /// Request OTP untuk reset password
  static Future<ForgotPasswordModel> requestOtp(String email) async {
    final url = Uri.parse('${Endpoint.baseUrl}/forgot-password');
    final headers = _buildHeaders();

    final otpRequest = OtpRequestModel(email: email);
    final body = otpRequest.toJson();

    print('DEBUG: Request OTP URL: $url');
    print('DEBUG: Request OTP body: ${jsonEncode(body)}');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    print('DEBUG: Request OTP response status: ${response.statusCode}');
    print('DEBUG: Request OTP response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = jsonDecode(response.body);
        return ForgotPasswordModel.fromJson(data);
      } catch (e) {
        print('DEBUG: Error parsing request OTP response: $e');
        throw Exception('Error parsing response: $e');
      }
    } else {
      String message = 'Gagal mengirim OTP';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['message'] != null) {
          message = data['message'];
        }
      } catch (_) {}
      throw Exception('$message (Status: ${response.statusCode})');
    }
  }

  /// Reset password dengan OTP
  static Future<ForgotPasswordModel> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final url = Uri.parse('${Endpoint.baseUrl}/reset-password');
    final headers = _buildHeaders();

    final resetRequest = ResetPasswordModel(
      email: email,
      otp: otp,
      password: newPassword,
      passwordConfirmation: confirmPassword,
    );
    final body = resetRequest.toJson();

    print('DEBUG: Reset password URL: $url');
    print('DEBUG: Reset password body: ${jsonEncode(body)}');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    print('DEBUG: Reset password response status: ${response.statusCode}');
    print('DEBUG: Reset password response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = jsonDecode(response.body);
        return ForgotPasswordModel.fromJson(data);
      } catch (e) {
        print('DEBUG: Error parsing reset password response: $e');
        throw Exception('Error parsing response: $e');
      }
    } else {
      String message = 'Gagal mengubah password';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['message'] != null) {
          message = data['message'];
        }
      } catch (_) {}
      throw Exception('$message (Status: ${response.statusCode})');
    }
  }

  /// Verifikasi OTP
  static Future<ForgotPasswordModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('${Endpoint.baseUrl}/verify-otp');
    final headers = _buildHeaders();

    final verifyRequest = VerifyOtpModel(email: email, otp: otp);
    final body = verifyRequest.toJson();

    print('DEBUG: Verify OTP URL: $url');
    print('DEBUG: Verify OTP body: ${jsonEncode(body)}');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    print('DEBUG: Verify OTP response status: ${response.statusCode}');
    print('DEBUG: Verify OTP response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = jsonDecode(response.body);
        return ForgotPasswordModel.fromJson(data);
      } catch (e) {
        print('DEBUG: Error parsing verify OTP response: $e');
        throw Exception('Error parsing response: $e');
      }
    } else {
      String message = 'OTP tidak valid';
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
