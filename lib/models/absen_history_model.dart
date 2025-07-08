import 'dart:convert';

HistoryAbsenResponse historyAbsenResponseFromJson(String str) =>
    HistoryAbsenResponse.fromJson(json.decode(str));

String historyAbsenResponseToJson(HistoryAbsenResponse data) =>
    json.encode(data.toJson());

class HistoryAbsenResponse {
  String message;
  List<HistoryAbsenData> data;

  HistoryAbsenResponse({required this.message, required this.data});

  factory HistoryAbsenResponse.fromJson(Map<String, dynamic> json) =>
      HistoryAbsenResponse(
        message: json["message"],
        data: List<HistoryAbsenData>.from(
          json["data"].map((x) => HistoryAbsenData.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class HistoryAbsenData {
  int id;
  int? userId;
  DateTime? checkIn;
  String? checkInLocation;
  String? checkInAddress;
  DateTime? checkOut;
  String? checkOutLocation;
  String? checkOutAddress;
  String? status;
  dynamic alasanIzin;
  DateTime? createdAt;
  DateTime? updatedAt;

  HistoryAbsenData({
    required this.id,
    this.userId,
    this.checkIn,
    this.checkInLocation,
    this.checkInAddress,
    this.checkOut,
    this.checkOutLocation,
    this.checkOutAddress,
    this.status,
    this.alasanIzin,
    this.createdAt,
    this.updatedAt,
  });

  factory HistoryAbsenData.fromJson(Map<String, dynamic> json) =>
      HistoryAbsenData(
        id: json["id"] is int
            ? json["id"]
            : int.tryParse(json["id"].toString()) ?? 0,
        userId: json["user_id"] is int
            ? json["user_id"]
            : int.tryParse(json["user_id"].toString()),
        checkIn: json["check_in"] != null
            ? DateTime.tryParse(json["check_in"])
            : null,
        checkInLocation: json["check_in_location"],
        checkInAddress: json["check_in_address"],
        checkOut: json["check_out"] != null
            ? DateTime.tryParse(json["check_out"])
            : null,
        checkOutLocation: json["check_out_location"],
        checkOutAddress: json["check_out_address"],
        status: json["status"],
        alasanIzin: json["alasan_izin"],
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.tryParse(json["updated_at"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "check_in": checkIn?.toIso8601String(),
    "check_in_location": checkInLocation,
    "check_in_address": checkInAddress,
    "check_out": checkOut?.toIso8601String(),
    "check_out_location": checkOutLocation,
    "check_out_address": checkOutAddress,
    "status": status,
    "alasan_izin": alasanIzin,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
