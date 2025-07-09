// To parse this JSON data, do
//
//     final editProfilePhotoResponse = editProfilePhotoResponseFromJson(jsonString);

import 'dart:convert';

EditProfilePhotoResponse editProfilePhotoResponseFromJson(String str) =>
    EditProfilePhotoResponse.fromJson(json.decode(str));

String editProfilePhotoResponseToJson(EditProfilePhotoResponse data) =>
    json.encode(data.toJson());

class EditProfilePhotoResponse {
  String message;
  PhotoProfileData data;

  EditProfilePhotoResponse({required this.message, required this.data});

  factory EditProfilePhotoResponse.fromJson(Map<String, dynamic> json) =>
      EditProfilePhotoResponse(
        message: json["message"],
        data: PhotoProfileData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class PhotoProfileData {
  String profilePhoto;

  PhotoProfileData({required this.profilePhoto});

  factory PhotoProfileData.fromJson(Map<String, dynamic> json) =>
      PhotoProfileData(profilePhoto: json["profile_photo"]);

  Map<String, dynamic> toJson() => {"profile_photo": profilePhoto};
}
