class ForgotPasswordModel {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  ForgotPasswordModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ForgotPasswordModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data};
  }
}

class OtpRequestModel {
  final String email;

  OtpRequestModel({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class ResetPasswordModel {
  final String email;
  final String otp;
  final String password;
  final String passwordConfirmation;

  ResetPasswordModel({
    required this.email,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}

class VerifyOtpModel {
  final String email;
  final String otp;

  VerifyOtpModel({required this.email, required this.otp});

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp};
  }
}
