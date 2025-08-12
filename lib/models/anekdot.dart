import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AnekdotModel {
  final String pengamatan;
  final String tujuan;
  final String tanggal;
  final String nilai;
  final String jatiDiri;
  final String literasi;
  final String umpanBalik;
  final String kelompok;
  final String imageId;
  final String uid;
  final String id;
  final String muridId;
  final String tanggapan;
  final String sekolah; // ✅ tambahan

  AnekdotModel({
    required this.pengamatan,
    required this.tujuan,
    required this.tanggal,
    required this.nilai,
    required this.jatiDiri,
    required this.literasi,
    required this.umpanBalik,
    required this.kelompok,
    required this.imageId,
    required this.uid,
    required this.id,
    required this.muridId,
    required this.tanggapan,
    required this.sekolah, // ✅ tambahan
  });

  AnekdotModel copyWith({
    String? pengamatan,
    String? tujuan,
    String? tanggal,
    String? nilai,
    String? jatiDiri,
    String? literasi,
    String? umpanBalik,
    String? kelompok,
    String? imageId,
    String? uid,
    String? id,
    String? muridId,
    String? tanggapan,
    String? sekolah, // ✅ tambahan
  }) {
    return AnekdotModel(
      pengamatan: pengamatan ?? this.pengamatan,
      tujuan: tujuan ?? this.tujuan,
      tanggal: tanggal ?? this.tanggal,
      nilai: nilai ?? this.nilai,
      jatiDiri: jatiDiri ?? this.jatiDiri,
      literasi: literasi ?? this.literasi,
      umpanBalik: umpanBalik ?? this.umpanBalik,
      kelompok: kelompok ?? this.kelompok,
      imageId: imageId ?? this.imageId,
      uid: uid ?? this.uid,
      id: id ?? this.id,
      muridId: muridId ?? this.muridId,
      tanggapan: tanggapan ?? this.tanggapan,
      sekolah: sekolah ?? this.sekolah, // ✅ tambahan
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pengamatan': pengamatan,
      'tujuan': tujuan,
      'tanggal': tanggal,
      'nilai': nilai,
      'jatiDiri': jatiDiri,
      'literasi': literasi,
      'umpanBalik': umpanBalik,
      'kelompok': kelompok,
      'imageId': imageId,
      'uid': uid,
      'muridId': muridId,
      'tanggapan': tanggapan,
      'sekolah': sekolah, // ✅ tambahan
    };
  }

  factory AnekdotModel.fromMap(Map<String, dynamic> map) {
    return AnekdotModel(
      pengamatan: map['pengamatan'] ?? '',
      tujuan: map['tujuan'] ?? '',
      tanggal: map['tanggal'] ?? '',
      nilai: map['nilai'] ?? '',
      jatiDiri: map['jatiDiri'] ?? '',
      literasi: map['literasi'] ?? '',
      umpanBalik: map['umpanBalik'] ?? '',
      kelompok: map['kelompok'] ?? '',
      imageId: map['imageId'] ?? '',
      uid: map['uid'] ?? '',
      id: map['\$id'] ?? '',
      muridId: map['muridId'] ?? '',
      tanggapan: map['tanggapan'] ?? '',
      sekolah: map['sekolah'] ?? '', // ✅ tambahan
    );
  }

  String toJson() => json.encode(toMap());

  factory AnekdotModel.fromJson(String source) =>
      AnekdotModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AnekdotModel(pengamatan: $pengamatan, tujuan: $tujuan, tanggal: $tanggal, nilai: $nilai, jatiDiri: $jatiDiri, literasi: $literasi, umpanBalik: $umpanBalik, kelompok: $kelompok, imageId: $imageId, uid: $uid, id: $id, muridId: $muridId, tanggapan: $tanggapan, sekolah: $sekolah)'; // ✅ tambahan
  }

  @override
  bool operator ==(covariant AnekdotModel other) {
    if (identical(this, other)) return true;

    return other.pengamatan == pengamatan &&
        other.tujuan == tujuan &&
        other.tanggal == tanggal &&
        other.nilai == nilai &&
        other.jatiDiri == jatiDiri &&
        other.literasi == literasi &&
        other.umpanBalik == umpanBalik &&
        other.kelompok == kelompok &&
        other.imageId == imageId &&
        other.uid == uid &&
        other.id == id &&
        other.muridId == muridId &&
        other.tanggapan == tanggapan &&
        other.sekolah == sekolah; // ✅ tambahan
  }

  @override
  int get hashCode {
    return pengamatan.hashCode ^
        tujuan.hashCode ^
        tanggal.hashCode ^
        nilai.hashCode ^
        jatiDiri.hashCode ^
        literasi.hashCode ^
        umpanBalik.hashCode ^
        kelompok.hashCode ^
        imageId.hashCode ^
        uid.hashCode ^
        id.hashCode ^
        muridId.hashCode ^
        tanggapan.hashCode ^
        sekolah.hashCode; // ✅ tambahan
  }
}
