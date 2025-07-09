// To parse this JSON data, do
//
//     final todayAbsenResponse = todayAbsenResponseFromJson(jsonString);

import 'dart:convert';

TodayAbsenResponse todayAbsenResponseFromJson(String str) =>
    TodayAbsenResponse.fromJson(json.decode(str));

String todayAbsenResponseToJson(TodayAbsenResponse data) =>
    json.encode(data.toJson());

class TodayAbsenResponse {
  String message;
  TodayAbsenData? data;

  TodayAbsenResponse({required this.message, this.data});

  factory TodayAbsenResponse.fromJson(Map<String, dynamic> json) =>
      TodayAbsenResponse(
        message: json["message"],
        data: json["data"] != null
            ? TodayAbsenData.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class TodayAbsenData {
  String tanggal;
  String? jamMasuk;
  String? jamKeluar;
  String? alamatMasuk;
  String? alamatKeluar;
  String? status;
  String? alasanIzin;

  TodayAbsenData({
    required this.tanggal,
    this.jamMasuk,
    this.jamKeluar,
    this.alamatMasuk,
    this.alamatKeluar,
    this.status,
    this.alasanIzin,
  });

  factory TodayAbsenData.fromJson(Map<String, dynamic> json) => TodayAbsenData(
    tanggal: json["tanggal"],
    jamMasuk: json["jam_masuk"],
    jamKeluar: json["jam_keluar"],
    alamatMasuk: json["alamat_masuk"],
    alamatKeluar: json["alamat_keluar"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );

  Map<String, dynamic> toJson() => {
    "tanggal": tanggal,
    "jam_masuk": jamMasuk,
    "jam_keluar": jamKeluar,
    "alamat_masuk": alamatMasuk,
    "alamat_keluar": alamatKeluar,
    "status": status,
    "alasan_izin": alasanIzin,
  };

  // Tambahkan getter agar kompatibel dengan maps_page.dart
  String get checkIn => jamMasuk ?? '';
  String? get checkOut => jamKeluar;
}
