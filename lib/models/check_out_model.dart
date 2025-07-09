// To parse this JSON data, do
//
//     final checkOutResponse = checkOutResponseFromJson(jsonString);

import 'dart:convert';

CheckOutResponse checkOutResponseFromJson(String str) =>
    CheckOutResponse.fromJson(json.decode(str));

String checkOutResponseToJson(CheckOutResponse data) =>
    json.encode(data.toJson());

class CheckOutResponse {
  String message;
  CheckOutData data;

  CheckOutResponse({required this.message, required this.data});

  factory CheckOutResponse.fromJson(Map<String, dynamic> json) =>
      CheckOutResponse(
        message: json["message"],
        data: CheckOutData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class CheckOutData {
  int id;
  int userId;
  String checkIn;
  String checkInLocation;
  String checkInAddress;
  String? checkOut;
  String? checkOutLocation;
  String? checkOutAddress;
  String status;
  dynamic alasanIzin;
  String createdAt;
  String updatedAt;
  double checkInLat;
  double checkInLng;
  double? checkOutLat;
  double? checkOutLng;

  CheckOutData({
    required this.id,
    required this.userId,
    required this.checkIn,
    required this.checkInLocation,
    required this.checkInAddress,
    this.checkOut,
    this.checkOutLocation,
    this.checkOutAddress,
    required this.status,
    this.alasanIzin,
    required this.createdAt,
    required this.updatedAt,
    required this.checkInLat,
    required this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
  });

  factory CheckOutData.fromJson(Map<String, dynamic> json) => CheckOutData(
    id: json["id"],
    userId: json["user_id"],
    checkIn: json["check_in"],
    checkInLocation: json["check_in_location"],
    checkInAddress: json["check_in_address"],
    checkOut: json["check_out"],
    checkOutLocation: json["check_out_location"],
    checkOutAddress: json["check_out_address"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    checkInLat: json["check_in_lat"]?.toDouble(),
    checkInLng: json["check_in_lng"]?.toDouble(),
    checkOutLat: json["check_out_lat"]?.toDouble(),
    checkOutLng: json["check_out_lng"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "check_in": checkIn,
    "check_in_location": checkInLocation,
    "check_in_address": checkInAddress,
    "check_out": checkOut,
    "check_out_location": checkOutLocation,
    "check_out_address": checkOutAddress,
    "status": status,
    "alasan_izin": alasanIzin,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_out_lat": checkOutLat,
    "check_out_lng": checkOutLng,
  };
}
