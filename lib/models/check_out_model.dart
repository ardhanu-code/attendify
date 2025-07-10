// To parse this JSON data, do
//
//     final checkOutResponse = checkOutResponseFromJson(jsonString);

import 'dart:convert';

CheckOutResponse checkOutResponseFromJson(String str) =>
    CheckOutResponse.fromJson(json.decode(str));

String checkOutResponseToJson(CheckOutResponse data) =>
    json.encode(data.toJson());

class CheckOutResponse {
  String? message;
  CheckOutData data;

  CheckOutResponse({this.message, required this.data});

  factory CheckOutResponse.fromJson(Map<String, dynamic> json) =>
      CheckOutResponse(
        message: json["message"],
        data: CheckOutData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class CheckOutData {
  int id;
  String attendanceDate;
  String checkInTime;
  String checkOutTime;
  String checkInAddress;
  String checkOutAddress;
  String checkInLocation;
  String checkOutLocation;
  String status;
  dynamic alasanIzin;

  CheckOutData({
    required this.id,
    required this.attendanceDate,
    required this.checkInTime,
    required this.checkOutTime,
    required this.checkInAddress,
    required this.checkOutAddress,
    required this.checkInLocation,
    required this.checkOutLocation,
    required this.status,
    this.alasanIzin,
  });

  factory CheckOutData.fromJson(Map<String, dynamic> json) => CheckOutData(
    id: json["id"],
    attendanceDate: json["attendance_date"],
    checkInTime: json["check_in_time"],
    checkOutTime: json["check_out_time"],
    checkInAddress: json["check_in_address"],
    checkOutAddress: json["check_out_address"],
    checkInLocation: json["check_in_location"],
    checkOutLocation: json["check_out_location"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "attendance_date": attendanceDate,
    "check_in_time": checkInTime,
    "check_out_time": checkOutTime,
    "check_in_address": checkInAddress,
    "check_out_address": checkOutAddress,
    "check_in_location": checkInLocation,
    "check_out_location": checkOutLocation,
    "status": status,
    "alasan_izin": alasanIzin,
  };

  // Legacy getters for backward compatibility
  String get checkIn => checkInTime;
  String? get checkOut => checkOutTime;
  int get userId => 0; // Not provided in new response
  String get createdAt => ''; // Not provided in new response
  String get updatedAt => ''; // Not provided in new response
  double get checkInLat => 0.0; // Not provided in new response
  double get checkInLng => 0.0; // Not provided in new response
  double? get checkOutLat => null; // Not provided in new response
  double? get checkOutLng => null; // Not provided in new response
}
