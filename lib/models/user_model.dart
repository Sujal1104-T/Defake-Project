class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final int totalScans;
  final int threatsDetected;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.totalScans = 0,
    this.threatsDetected = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'totalScans': totalScans,
      'threatsDetected': threatsDetected,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      totalScans: json['totalScans'] ?? 0,
      threatsDetected: json['threatsDetected'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    int? totalScans,
    int? threatsDetected,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      totalScans: totalScans ?? this.totalScans,
      threatsDetected: threatsDetected ?? this.threatsDetected,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
