// To parse this JSON data, do
//
//     final checkInResponse = checkInResponseFromJson(jsonString);

import 'dart:convert';

CheckInResponse checkInResponseFromJson(String str) =>
    CheckInResponse.fromJson(json.decode(str));

String checkInResponseToJson(CheckInResponse data) =>
    json.encode(data.toJson());

class CheckInResponse {
  String message;
  Data data;

  CheckInResponse({required this.message, required this.data});

  factory CheckInResponse.fromJson(Map<String, dynamic> json) =>
      CheckInResponse(
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class Data {
  int userId;
  DateTime checkIn;
  String checkInLocation;
  double checkInLat;
  double checkInLng;
  String checkInAddress;
  String status;
  dynamic alasanIzin;
  DateTime updatedAt;
  DateTime createdAt;
  int id;

  Data({
    required this.userId,
    required this.checkIn,
    required this.checkInLocation,
    required this.checkInLat,
    required this.checkInLng,
    required this.checkInAddress,
    required this.status,
    required this.alasanIzin,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userId: json["user_id"],
    checkIn: DateTime.parse(json["check_in"]),
    checkInLocation: json["check_in_location"],
    checkInLat: json["check_in_lat"]?.toDouble(),
    checkInLng: json["check_in_lng"]?.toDouble(),
    checkInAddress: json["check_in_address"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
    updatedAt: DateTime.parse(json["updated_at"]),
    createdAt: DateTime.parse(json["created_at"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "check_in": checkIn.toIso8601String(),
    "check_in_location": checkInLocation,
    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_in_address": checkInAddress,
    "status": status,
    "alasan_izin": alasanIzin,
    "updated_at": updatedAt.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "id": id,
  };
}
