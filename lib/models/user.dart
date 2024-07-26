// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class User {
  final String id;
  final String email;
  final String nama;
  final String kelompok;
  final String imageId;
  final int levelUser;

  User({
    required this.id,
    required this.email,
    required this.nama,
    required this.kelompok,
    required this.imageId,
    required this.levelUser,
  });

  User copyWith({
    String? id,
    String? email,
    String? nama,
    String? kelompok,
    String? imageId,
    int? levelUser,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      kelompok: kelompok ?? this.kelompok,
      imageId: imageId ?? this.imageId,
      levelUser: levelUser ?? this.levelUser,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    result.addAll({
      'email': email,
      'nama': nama,
      'kelompok': kelompok,
      'imageId': imageId,
      'levelUser': levelUser,
    });
    return result;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['\$id'] ?? '',
      email: map['email'] ?? '',
      nama: map['nama'] ?? '',
      kelompok: map['kelompok'] ?? '',
      imageId: map['imageId'] ?? '',
      levelUser: map['levelUser'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(id: $id, email: $email, nama: $nama, imageId: $imageId,kelompok: $kelompok, levelUser: $levelUser)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.email == email &&
        other.nama == nama &&
        other.kelompok == kelompok &&
        other.imageId == imageId &&
        other.levelUser == levelUser;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        nama.hashCode ^
        kelompok.hashCode ^
        imageId.hashCode;
  }
}
