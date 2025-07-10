class ProfileResponse {
  final String message;
  final ProfileData data;

  ProfileResponse({required this.message, required this.data});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      ProfileResponse(
        message: json['message'],
        data: ProfileData.fromJson(json['data']),
      );
}

class ProfileData {
  final int id;
  final String name;
  final String email;
  final String batchKe;
  final String trainingTitle;
  final Batch batch;
  final Training training;
  final String? jenisKelamin;
  final String? profilePhoto;

  ProfileData({
    required this.id,
    required this.name,
    required this.email,
    required this.batchKe,
    required this.trainingTitle,
    required this.batch,
    required this.training,
    this.jenisKelamin,
    this.profilePhoto,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    batchKe: json['batch_ke'],
    trainingTitle: json['training_title'],
    batch: Batch.fromJson(json['batch']),
    training: Training.fromJson(json['training']),
    jenisKelamin: json['jenis_kelamin'],
    profilePhoto: json['profile_photo'],
  );
}

class Batch {
  final int id;
  final String batchKe;
  final String startDate;
  final String endDate;
  final String createdAt;
  final String updatedAt;

  Batch({
    required this.id,
    required this.batchKe,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Batch.fromJson(Map<String, dynamic> json) => Batch(
    id: json['id'],
    batchKe: json['batch_ke'],
    startDate: json['start_date'],
    endDate: json['end_date'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );
}

class Training {
  final int id;
  final String title;
  final String? description;
  final int? participantCount;
  final String? standard;
  final String? duration;
  final String createdAt;
  final String updatedAt;

  Training({
    required this.id,
    required this.title,
    this.description,
    this.participantCount,
    this.standard,
    this.duration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Training.fromJson(Map<String, dynamic> json) => Training(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    participantCount: json['participant_count'],
    standard: json['standard'],
    duration: json['duration'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );
}
