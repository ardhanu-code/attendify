// To parse this JSON data, do
//
//     final historyAbsenResponse = historyAbsenResponseFromJson(jsonString);

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
  DateTime attendanceDate;
  String? checkInTime;
  dynamic checkOutTime;
  double? checkInLat;
  double? checkInLng;
  dynamic checkOutLat;
  dynamic checkOutLng;
  String? checkInAddress;
  dynamic checkOutAddress;
  String? checkInLocation;
  dynamic checkOutLocation;
  Status status;
  String? alasanIzin;

  HistoryAbsenData({
    required this.id,
    required this.attendanceDate,
    required this.checkInTime,
    required this.checkOutTime,
    required this.checkInLat,
    required this.checkInLng,
    required this.checkOutLat,
    required this.checkOutLng,
    required this.checkInAddress,
    required this.checkOutAddress,
    required this.checkInLocation,
    required this.checkOutLocation,
    required this.status,
    required this.alasanIzin,
  });

  factory HistoryAbsenData.fromJson(Map<String, dynamic> json) =>
      HistoryAbsenData(
        id: json["id"],
        attendanceDate: DateTime.parse(json["attendance_date"]),
        checkInTime: json["check_in_time"],
        checkOutTime: json["check_out_time"],
        checkInLat: json["check_in_lat"]?.toDouble(),
        checkInLng: json["check_in_lng"]?.toDouble(),
        checkOutLat: json["check_out_lat"],
        checkOutLng: json["check_out_lng"],
        checkInAddress: json["check_in_address"],
        checkOutAddress: json["check_out_address"],
        checkInLocation: json["check_in_location"],
        checkOutLocation: json["check_out_location"],
        status:
            statusValues.map[json["status"]] ??
            Status.MASUK, // default ke MASUK jika tidak ditemukan
        alasanIzin: json["alasan_izin"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "attendance_date":
        "${attendanceDate.year.toString().padLeft(4, '0')}-${attendanceDate.month.toString().padLeft(2, '0')}-${attendanceDate.day.toString().padLeft(2, '0')}",
    "check_in_time": checkInTime,
    "check_out_time": checkOutTime,
    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_out_lat": checkOutLat,
    "check_out_lng": checkOutLng,
    "check_in_address": checkInAddress,
    "check_out_address": checkOutAddress,
    "check_in_location": checkInLocation,
    "check_out_location": checkOutLocation,
    "status": statusValues.reverse[status],
    "alasan_izin": alasanIzin,
  };
}

enum Status { IZIN, MASUK }

final statusValues = EnumValues({
  "izin": Status.IZIN,
  "masuk": Status.MASUK,
  "permission": Status.IZIN, // tambahan untuk kompatibilitas
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
