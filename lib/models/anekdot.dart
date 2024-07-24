import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AnekdotModel {
  final String pengamatan;
  final String tanggal;
  final String nilai;
  final String jatiDiri;
  final String literasi;
  final String umpanBalik;
  final String kelompok;
  final String uid;
  final String id;
  final String muridId;
  AnekdotModel({
    required this.pengamatan,
    required this.tanggal,
    required this.nilai,
    required this.jatiDiri,
    required this.literasi,
    required this.umpanBalik,
    required this.kelompok,
    required this.uid,
    required this.id,
    required this.muridId,
  });

  AnekdotModel copyWith({
    String? pengamatan,
    String? tanggal,
    String? nilai,
    String? jatiDiri,
    String? literasi,
    String? umpanBalik,
    String? kelompok,
    String? uid,
    String? id,
    String? muridId,
  }) {
    return AnekdotModel(
      pengamatan: pengamatan ?? this.pengamatan,
      tanggal: tanggal ?? this.tanggal,
      nilai: nilai ?? this.nilai,
      jatiDiri: jatiDiri ?? this.jatiDiri,
      literasi: literasi ?? this.literasi,
      umpanBalik: umpanBalik ?? this.umpanBalik,
      kelompok: kelompok ?? this.kelompok,
      uid: uid ?? this.uid,
      id: id ?? this.id,
      muridId: muridId ?? this.muridId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pengamatan': pengamatan,
      'tanggal': tanggal,
      'nilai': nilai,
      'jatiDiri': jatiDiri,
      'literasi': literasi,
      'umpanBalik': umpanBalik,
      'kelompok': kelompok,
      'uid': uid,
      'muridId': muridId,
    };
  }

  factory AnekdotModel.fromMap(Map<String, dynamic> map) {
    return AnekdotModel(
      pengamatan: map['pengamatan'] ?? '',
      tanggal: map['tanggal'] ?? '',
      nilai: map['nilai'] ?? '',
      jatiDiri: map['jatiDiri'] ?? '',
      literasi: map['literasi'] ?? '',
      umpanBalik: map['umpanBalik'] ?? '',
      kelompok: map['kelompok'] ?? '',
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
    return 'AnekdotModel(pengamatan: $pengamatan, tanggal: $tanggal, nilai: $nilai, jatiDiri: $jatiDiri, literasi: $literasi, umpanBalik: $umpanBalik, kelompok: $kelompok, uid: $uid, id: $id, muridId: $muridId)';
  }

  @override
  bool operator ==(covariant AnekdotModel other) {
    if (identical(this, other)) return true;

    return other.pengamatan == pengamatan &&
        other.tanggal == tanggal &&
        other.nilai == nilai &&
        other.jatiDiri == jatiDiri &&
        other.literasi == literasi &&
        other.umpanBalik == umpanBalik &&
        other.kelompok == kelompok &&
        other.uid == uid &&
        other.id == id &&
        other.muridId == muridId;
  }

  @override
  int get hashCode {
    return pengamatan.hashCode ^
        tanggal.hashCode ^
        nilai.hashCode ^
        jatiDiri.hashCode ^
        literasi.hashCode ^
        umpanBalik.hashCode ^
        kelompok.hashCode ^
        uid.hashCode ^
        id.hashCode ^
        muridId.hashCode;
  }
}
