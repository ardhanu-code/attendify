// To parse this JSON data, do
//
//     final trainingsResponse = trainingsResponseFromJson(jsonString);

import 'dart:convert';

TrainingsResponse trainingsResponseFromJson(String str) =>
    TrainingsResponse.fromJson(json.decode(str));

String trainingsResponseToJson(TrainingsResponse data) =>
    json.encode(data.toJson());

class TrainingsResponse {
  String message;
  List<DataTrainings> data;

  TrainingsResponse({required this.message, required this.data});

  factory TrainingsResponse.fromJson(Map<String, dynamic> json) =>
      TrainingsResponse(
        message: json["message"],
        data: List<DataTrainings>.from(
          json["data"].map((x) => DataTrainings.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class DataTrainings {
  int id;
  String title;

  DataTrainings({required this.id, required this.title});

  factory DataTrainings.fromJson(Map<String, dynamic> json) =>
      DataTrainings(id: json["id"], title: json["title"]);

  Map<String, dynamic> toJson() => {"id": id, "title": title};
}
