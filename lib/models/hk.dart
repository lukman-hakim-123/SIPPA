import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class HkModel {
  final String semester;
  final String tanggal;
  final String deskripsi;
  final String nilai;
  final String jatiDiri;
  final String literasi;
  final String imageId;
  final String kelompok;
  final String uid;
  final String id;
  final String muridId;
  final String rekomendasi;
  final String tanggapan;
  final String sekolah; // ✅ Tambahan

  HkModel({
    required this.semester,
    required this.tanggal,
    required this.deskripsi,
    required this.nilai,
    required this.jatiDiri,
    required this.literasi,
    required this.imageId,
    required this.kelompok,
    required this.uid,
    required this.id,
    required this.muridId,
    required this.rekomendasi,
    required this.tanggapan,
    required this.sekolah, // ✅ Tambahan
  });

  HkModel copyWith({
    String? semester,
    String? tanggal,
    String? deskripsi,
    String? nilai,
    String? jatiDiri,
    String? literasi,
    String? imageId,
    String? kelompok,
    String? uid,
    String? id,
    String? muridId,
    String? rekomendasi,
    String? tanggapan,
    String? sekolah, // ✅ Tambahan
  }) {
    return HkModel(
      semester: semester ?? this.semester,
      tanggal: tanggal ?? this.tanggal,
      deskripsi: deskripsi ?? this.deskripsi,
      nilai: nilai ?? this.nilai,
      jatiDiri: jatiDiri ?? this.jatiDiri,
      literasi: literasi ?? this.literasi,
      imageId: imageId ?? this.imageId,
      kelompok: kelompok ?? this.kelompok,
      uid: uid ?? this.uid,
      id: id ?? this.id,
      muridId: muridId ?? this.muridId,
      rekomendasi: rekomendasi ?? this.rekomendasi,
      tanggapan: tanggapan ?? this.tanggapan,
      sekolah: sekolah ?? this.sekolah, // ✅ Tambahan
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'semester': semester,
      'tanggal': tanggal,
      'deskripsi': deskripsi,
      'nilai': nilai,
      'jatiDiri': jatiDiri,
      'literasi': literasi,
      'imageId': imageId,
      'kelompok': kelompok,
      'uid': uid,
      'muridId': muridId,
      'rekomendasi': rekomendasi,
      'tanggapan': tanggapan,
      'sekolah': sekolah, // ✅ Tambahan
    };
  }

  factory HkModel.fromMap(Map<String, dynamic> map) {
    return HkModel(
      semester: map['semester'] ?? '',
      tanggal: map['tanggal'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      nilai: map['nilai'] ?? '',
      jatiDiri: map['jatiDiri'] ?? '',
      literasi: map['literasi'] ?? '',
      imageId: map['imageId'] ?? '',
      kelompok: map['kelompok'] ?? '',
      uid: map['uid'] ?? '',
      id: map['\$id'] ?? '',
      muridId: map['muridId'] ?? '',
      rekomendasi: map['rekomendasi'] ?? '',
      tanggapan: map['tanggapan'] ?? '',
      sekolah: map['sekolah'] ?? '', // ✅ Tambahan
    );
  }

  String toJson() => json.encode(toMap());

  factory HkModel.fromJson(String source) =>
      HkModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'HkModel(semester: $semester, tanggal: $tanggal, deskripsi: $deskripsi, nilai: $nilai, jatiDiri: $jatiDiri, literasi: $literasi, imageId: $imageId, kelompok: $kelompok, uid: $uid, id: $id, muridId: $muridId, rekomendasi: $rekomendasi, tanggapan: $tanggapan, sekolah: $sekolah)'; // ✅ Tambahan
  }

  @override
  bool operator ==(covariant HkModel other) {
    if (identical(this, other)) return true;

    return other.semester == semester &&
        other.tanggal == tanggal &&
        other.deskripsi == deskripsi &&
        other.nilai == nilai &&
        other.jatiDiri == jatiDiri &&
        other.literasi == literasi &&
        other.imageId == imageId &&
        other.kelompok == kelompok &&
        other.uid == uid &&
        other.id == id &&
        other.rekomendasi == rekomendasi &&
        other.tanggapan == tanggapan &&
        other.muridId == muridId &&
        other.sekolah == sekolah; // ✅ Tambahan
  }

  @override
  int get hashCode {
    return semester.hashCode ^
        tanggal.hashCode ^
        deskripsi.hashCode ^
        nilai.hashCode ^
        jatiDiri.hashCode ^
        literasi.hashCode ^
        imageId.hashCode ^
        kelompok.hashCode ^
        uid.hashCode ^
        id.hashCode ^
        rekomendasi.hashCode ^
        tanggapan.hashCode ^
        muridId.hashCode ^
        sekolah.hashCode; // ✅ Tambahan
  }
}
