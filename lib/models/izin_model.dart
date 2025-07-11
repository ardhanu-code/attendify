import 'dart:convert';

IzinRequest izinRequestFromJson(String str) =>
    IzinRequest.fromJson(json.decode(str));

String izinRequestToJson(IzinRequest data) => json.encode(data.toJson());

class IzinRequest {
  final String date;
  final String alasanIzin;

  IzinRequest({required this.date, required this.alasanIzin});

  factory IzinRequest.fromJson(Map<String, dynamic> json) =>
      IzinRequest(date: json["date"], alasanIzin: json["alasan_izin"]);

  Map<String, dynamic> toJson() => {"date": date, "alasan_izin": alasanIzin};
}

IzinResponse izinResponseFromJson(String str) =>
    IzinResponse.fromJson(json.decode(str));

String izinResponseToJson(IzinResponse data) => json.encode(data.toJson());

class IzinResponse {
  final String message;
  final IzinData data;

  IzinResponse({required this.message, required this.data});

  factory IzinResponse.fromJson(Map<String, dynamic> json) => IzinResponse(
    message: json["message"],
    data: IzinData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class IzinData {
  final int id;
  final String attendanceDate;
  final String? checkInTime;
  final String? checkInLat;
  final String? checkInLng;
  final String? checkInLocation;
  final String? checkInAddress;
  final String status;
  final String alasanIzin;

  IzinData({
    required this.id,
    required this.attendanceDate,
    this.checkInTime,
    this.checkInLat,
    this.checkInLng,
    this.checkInLocation,
    this.checkInAddress,
    required this.status,
    required this.alasanIzin,
  });

  factory IzinData.fromJson(Map<String, dynamic> json) => IzinData(
    id: json["id"],
    attendanceDate: json["attendance_date"],
    checkInTime: json["check_in_time"],
    checkInLat: json["check_in_lat"],
    checkInLng: json["check_in_lng"],
    checkInLocation: json["check_in_location"],
    checkInAddress: json["check_in_address"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "attendance_date": attendanceDate,
    "check_in_time": checkInTime,
    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_in_location": checkInLocation,
    "check_in_address": checkInAddress,
    "status": status,
    "alasan_izin": alasanIzin,
  };
}
