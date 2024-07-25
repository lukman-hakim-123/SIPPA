import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class FbModel {
  final String tanggal;
  final String keterangan;
  final String nilai;
  final String jatiDiri;
  final String literasi;
  final String umpanBalik;
  final String imageId1;
  final String imageId2;
  final String imageId3;
  final String kelompok;
  final String uid;
  final String id;
  final String muridId;
  FbModel({
    required this.tanggal,
    required this.keterangan,
    required this.nilai,
    required this.jatiDiri,
    required this.literasi,
    required this.umpanBalik,
    required this.imageId1,
    required this.imageId2,
    required this.imageId3,
    required this.kelompok,
    required this.uid,
    required this.id,
    required this.muridId,
  });

  FbModel copyWith({
    String? tanggal,
    String? keterangan,
    String? nilai,
    String? jatiDiri,
    String? literasi,
    String? umpanBalik,
    String? imageId1,
    String? imageId2,
    String? imageId3,
    String? kelompok,
    String? uid,
    String? id,
    String? muridId,
  }) {
    return FbModel(
      tanggal: tanggal ?? this.tanggal,
      keterangan: keterangan ?? this.keterangan,
      nilai: nilai ?? this.nilai,
      jatiDiri: jatiDiri ?? this.jatiDiri,
      literasi: literasi ?? this.literasi,
      umpanBalik: umpanBalik ?? this.umpanBalik,
      imageId1: imageId1 ?? this.imageId1,
      imageId2: imageId2 ?? this.imageId2,
      imageId3: imageId3 ?? this.imageId3,
      kelompok: kelompok ?? this.kelompok,
      uid: uid ?? this.uid,
      id: id ?? this.id,
      muridId: muridId ?? this.muridId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tanggal': tanggal,
      'keterangan': keterangan,
      'nilai': nilai,
      'jatiDiri': jatiDiri,
      'literasi': literasi,
      'umpanBalik': umpanBalik,
      'imageId1': imageId1,
      'imageId2': imageId2,
      'imageId3': imageId3,
      'kelompok': kelompok,
      'uid': uid,
      'muridId': muridId,
    };
  }

  factory FbModel.fromMap(Map<String, dynamic> map) {
    return FbModel(
      tanggal: map['tanggal'] ?? '',
      keterangan: map['keterangan'] ?? '',
      nilai: map['nilai'] ?? '',
      jatiDiri: map['jatiDiri'] ?? '',
      literasi: map['literasi'] ?? '',
      umpanBalik: map['umpanBalik'] ?? '',
      imageId1: map['imageId1'] ?? '',
      imageId2: map['imageId2'] ?? '',
      imageId3: map['imageId3'] ?? '',
      kelompok: map['kelompok'] ?? '',
      uid: map['uid'] ?? '',
      id: map['\$id'] ?? '',
      muridId: map['muridId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory FbModel.fromJson(String source) =>
      FbModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FbModel(tanggal: $tanggal, keterangan: $keterangan, nilai: $nilai, jatiDiri: $jatiDiri, literasi: $literasi, umpanBalik: $umpanBalik, imageId1: $imageId1, imageId2: $imageId2, imageId3: $imageId3, kelompok: $kelompok, uid: $uid, id: $id, muridId: $muridId)';
  }

  @override
  bool operator ==(covariant FbModel other) {
    if (identical(this, other)) return true;

    return other.tanggal == tanggal &&
        other.keterangan == keterangan &&
        other.nilai == nilai &&
        other.jatiDiri == jatiDiri &&
        other.literasi == literasi &&
        other.umpanBalik == umpanBalik &&
        other.imageId1 == imageId1 &&
        other.imageId2 == imageId2 &&
        other.imageId3 == imageId3 &&
        other.kelompok == kelompok &&
        other.uid == uid &&
        other.id == id &&
        other.muridId == muridId;
  }

  @override
  int get hashCode {
    return tanggal.hashCode ^
        keterangan.hashCode ^
        nilai.hashCode ^
        jatiDiri.hashCode ^
        literasi.hashCode ^
        umpanBalik.hashCode ^
        imageId1.hashCode ^
        imageId2.hashCode ^
        imageId3.hashCode ^
        kelompok.hashCode ^
        uid.hashCode ^
        id.hashCode ^
        muridId.hashCode;
  }
}
