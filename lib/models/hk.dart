import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class HkModel {
  final String pengamatan;
  final String tanggal;
  final String analisisCapaian;
  final String uid;
  final String id;
  final String muridId;
  HkModel({
    required this.pengamatan,
    required this.tanggal,
    required this.analisisCapaian,
    required this.uid,
    required this.id,
    required this.muridId,
  });

  HkModel copyWith({
    String? pengamatan,
    String? tanggal,
    String? analisisCapaian,
    String? uid,
    String? id,
    String? muridId,
  }) {
    return HkModel(
      pengamatan: pengamatan ?? this.pengamatan,
      tanggal: tanggal ?? this.tanggal,
      analisisCapaian: analisisCapaian ?? this.analisisCapaian,
      uid: uid ?? this.uid,
      id: id ?? this.id,
      muridId: muridId ?? this.muridId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pengamatan': pengamatan,
      'tanggal': tanggal,
      'analisisCapaian': analisisCapaian,
      'uid': uid,
      'id': id,
      'muridId': muridId,
    };
  }

  factory HkModel.fromMap(Map<String, dynamic> map) {
    return HkModel(
      pengamatan: map['pengamatan'] as String,
      tanggal: map['tanggal'] as String,
      analisisCapaian: map['analisisCapaian'] as String,
      uid: map['uid'] as String,
      id: map['id'] as String,
      muridId: map['muridId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory HkModel.fromJson(String source) =>
      HkModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'HkModel(pengamatan: $pengamatan, tanggal: $tanggal, analisisCapaian: $analisisCapaian, uid: $uid, id: $id, muridId: $muridId)';
  }

  @override
  bool operator ==(covariant HkModel other) {
    if (identical(this, other)) return true;

    return other.pengamatan == pengamatan &&
        other.tanggal == tanggal &&
        other.analisisCapaian == analisisCapaian &&
        other.uid == uid &&
        other.id == id &&
        other.muridId == muridId;
  }

  @override
  int get hashCode {
    return pengamatan.hashCode ^
        tanggal.hashCode ^
        analisisCapaian.hashCode ^
        uid.hashCode ^
        id.hashCode ^
        muridId.hashCode;
  }
}
