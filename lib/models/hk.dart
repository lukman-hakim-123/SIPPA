import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class HkModel {
  final String tujuan;
  final String tanggal;
  final String kegiatan;
  final String nilaiAgama;
  final String jatiDiri;
  final String literasi;
  final String imageId;
  final String kelompok;
  final String uid;
  final String id;
  final String muridId;
  final String rekomendasi;
  final String tanggapan;
  final String sekolah;

  HkModel({
    required this.tujuan,
    required this.tanggal,
    required this.kegiatan,
    required this.nilaiAgama,
    required this.jatiDiri,
    required this.literasi,
    required this.imageId,
    required this.kelompok,
    required this.uid,
    required this.id,
    required this.muridId,
    required this.rekomendasi,
    required this.tanggapan,
    required this.sekolah,
  });

  HkModel copyWith({
    String? tujuan,
    String? tanggal,
    String? kegiatan,
    String? nilaiAgama,
    String? jatiDiri,
    String? literasi,
    String? imageId,
    String? kelompok,
    String? uid,
    String? id,
    String? muridId,
    String? rekomendasi,
    String? tanggapan,
    String? sekolah,
  }) {
    return HkModel(
      tujuan: tujuan ?? this.tujuan,
      tanggal: tanggal ?? this.tanggal,
      kegiatan: kegiatan ?? this.kegiatan,
      nilaiAgama: nilaiAgama ?? this.nilaiAgama,
      jatiDiri: jatiDiri ?? this.jatiDiri,
      literasi: literasi ?? this.literasi,
      imageId: imageId ?? this.imageId,
      kelompok: kelompok ?? this.kelompok,
      uid: uid ?? this.uid,
      id: id ?? this.id,
      muridId: muridId ?? this.muridId,
      rekomendasi: rekomendasi ?? this.rekomendasi,
      tanggapan: tanggapan ?? this.tanggapan,
      sekolah: sekolah ?? this.sekolah,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tujuan': tujuan,
      'tanggal': tanggal,
      'kegiatan': kegiatan,
      'nilaiAgama': nilaiAgama,
      'jatiDiri': jatiDiri,
      'literasi': literasi,
      'imageId': imageId,
      'kelompok': kelompok,
      'uid': uid,
      'muridId': muridId,
      'rekomendasi': rekomendasi,
      'tanggapan': tanggapan,
      'sekolah': sekolah,
    };
  }

  factory HkModel.fromMap(Map<String, dynamic> map) {
    return HkModel(
      tujuan: map['tujuan'] ?? '',
      tanggal: map['tanggal'] ?? '',
      kegiatan: map['kegiatan'] ?? '',
      nilaiAgama: map['nilaiAgama'] ?? '',
      jatiDiri: map['jatiDiri'] ?? '',
      literasi: map['literasi'] ?? '',
      imageId: map['imageId'] ?? '',
      kelompok: map['kelompok'] ?? '',
      uid: map['uid'] ?? '',
      id: map['\$id'] ?? '',
      muridId: map['muridId'] ?? '',
      rekomendasi: map['rekomendasi'] ?? '',
      tanggapan: map['tanggapan'] ?? '',
      sekolah: map['sekolah'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory HkModel.fromJson(String source) =>
      HkModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'HkModel(tujuan: $tujuan, tanggal: $tanggal, kegiatan: $kegiatan, nilaiAgama: $nilaiAgama, jatiDiri: $jatiDiri, literasi: $literasi, imageId: $imageId, kelompok: $kelompok, uid: $uid, id: $id, muridId: $muridId, rekomendasi: $rekomendasi, tanggapan: $tanggapan, sekolah: $sekolah)';
  }

  @override
  bool operator ==(covariant HkModel other) {
    if (identical(this, other)) return true;

    return other.tujuan == tujuan &&
        other.tanggal == tanggal &&
        other.kegiatan == kegiatan &&
        other.nilaiAgama == nilaiAgama &&
        other.jatiDiri == jatiDiri &&
        other.literasi == literasi &&
        other.imageId == imageId &&
        other.kelompok == kelompok &&
        other.uid == uid &&
        other.id == id &&
        other.rekomendasi == rekomendasi &&
        other.tanggapan == tanggapan &&
        other.muridId == muridId &&
        other.sekolah == sekolah;
  }

  @override
  int get hashCode {
    return tujuan.hashCode ^
        tanggal.hashCode ^
        kegiatan.hashCode ^
        nilaiAgama.hashCode ^
        jatiDiri.hashCode ^
        literasi.hashCode ^
        imageId.hashCode ^
        kelompok.hashCode ^
        uid.hashCode ^
        id.hashCode ^
        rekomendasi.hashCode ^
        tanggapan.hashCode ^
        muridId.hashCode ^
        sekolah.hashCode;
  }
}
