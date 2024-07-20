import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AnekdotModel {
  final String pengamatan;
  final String tanggal;
  final String analisisCapaian;
  final String uid;
  final String id;
  final String muridId;
  AnekdotModel({
    required this.pengamatan,
    required this.tanggal,
    required this.analisisCapaian,
    required this.uid,
    required this.id,
    required this.muridId,
  });

  AnekdotModel copyWith({
    String? pengamatan,
    String? tanggal,
    String? analisisCapaian,
    String? uid,
    String? id,
    String? muridId,
  }) {
    return AnekdotModel(
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
      'muridId': muridId,
    };
  }

  factory AnekdotModel.fromMap(Map<String, dynamic> map) {
    return AnekdotModel(
      pengamatan: map['pengamatan'] ?? '',
      tanggal: map['tanggal'] ?? '',
      analisisCapaian: map['analisisCapaian'] ?? '',
      uid: map['uid'] ?? '',
      id: map['\$id'] ?? '',
      muridId: map['muridId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AnekdotModel.fromJson(String source) =>
      AnekdotModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AnekdotModel(pengamatan: $pengamatan, tanggal: $tanggal, analisisCapaian: $analisisCapaian,  uid: $uid, id: $id, muridId: $muridId)';
  }

  @override
  bool operator ==(covariant AnekdotModel other) {
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
