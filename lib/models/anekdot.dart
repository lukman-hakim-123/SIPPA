import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AnekdotModel {
  final String bulan;
  final String tanggal;
  final String analisisCapaian;
  final DateTime createdAt;
  final String uid;
  final String id;
  final String muridId;
  AnekdotModel({
    required this.bulan,
    required this.tanggal,
    required this.analisisCapaian,
    required this.createdAt,
    required this.uid,
    required this.id,
    required this.muridId,
  });

  AnekdotModel copyWith({
    String? bulan,
    String? tanggal,
    String? analisisCapaian,
    DateTime? createdAt,
    String? uid,
    String? id,
    String? muridId,
  }) {
    return AnekdotModel(
      bulan: bulan ?? this.bulan,
      tanggal: tanggal ?? this.tanggal,
      analisisCapaian: analisisCapaian ?? this.analisisCapaian,
      createdAt: createdAt ?? this.createdAt,
      uid: uid ?? this.uid,
      id: id ?? this.id,
      muridId: muridId ?? this.muridId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bulan': bulan,
      'tanggal': tanggal,
      'analisisCapaian': analisisCapaian,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'uid': uid,
      'id': id,
      'muridId': muridId,
    };
  }

  factory AnekdotModel.fromMap(Map<String, dynamic> map) {
    return AnekdotModel(
      bulan: map['bulan'] as String,
      tanggal: map['tanggal'] as String,
      analisisCapaian: map['analisisCapaian'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      uid: map['uid'] as String,
      id: map['\$id'] as String,
      muridId: map['muridId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AnekdotModel.fromJson(String source) =>
      AnekdotModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AnekdotModel(bulan: $bulan, tanggal: $tanggal, analisisCapaian: $analisisCapaian, createdAt: $createdAt, uid: $uid, id: $id, muridId: $muridId)';
  }

  @override
  bool operator ==(covariant AnekdotModel other) {
    if (identical(this, other)) return true;

    return other.bulan == bulan &&
        other.tanggal == tanggal &&
        other.analisisCapaian == analisisCapaian &&
        other.createdAt == createdAt &&
        other.uid == uid &&
        other.id == id &&
        other.muridId == muridId;
  }

  @override
  int get hashCode {
    return bulan.hashCode ^
        tanggal.hashCode ^
        analisisCapaian.hashCode ^
        createdAt.hashCode ^
        uid.hashCode ^
        id.hashCode ^
        muridId.hashCode;
  }
}
