// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CpModel {
  final String id;
  final String uid;
  final String tujuan;
  final String kegiatan;
  final bool isDone;
  final String nilaiAgama;
  final String jatiDiri;
  final String literasi;
  final String tanggal;
  final String muridId;
  final String kelompok;
  final String rekomendasi;
  final String tanggapan;
  final String sekolah;

  CpModel({
    required this.id,
    required this.uid,
    required this.tujuan,
    required this.kegiatan,
    required this.isDone,
    required this.nilaiAgama,
    required this.jatiDiri,
    required this.literasi,
    required this.tanggal,
    required this.muridId,
    required this.kelompok,
    required this.rekomendasi,
    required this.tanggapan,
    required this.sekolah,
  });

  CpModel copyWith({
    String? id,
    String? uid,
    String? tujuan,
    String? kegiatan,
    bool? isDone,
    String? nilaiAgama,
    String? jatiDiri,
    String? literasi,
    String? tanggal,
    String? muridId,
    String? kelompok,
    String? rekomendasi,
    String? tanggapan,
    String? sekolah,
  }) {
    return CpModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      tujuan: tujuan ?? this.tujuan,
      kegiatan: kegiatan ?? this.kegiatan,
      isDone: isDone ?? this.isDone,
      nilaiAgama: nilaiAgama ?? this.nilaiAgama,
      jatiDiri: jatiDiri ?? this.jatiDiri,
      literasi: literasi ?? this.literasi,
      tanggal: tanggal ?? this.tanggal,
      muridId: muridId ?? this.muridId,
      kelompok: kelompok ?? this.kelompok,
      rekomendasi: rekomendasi ?? this.rekomendasi,
      tanggapan: tanggapan ?? this.tanggapan,
      sekolah: sekolah ?? this.sekolah,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'tujuan': tujuan,
      'kegiatan': kegiatan,
      'isDone': isDone,
      'nilaiAgama': nilaiAgama,
      'jatiDiri': jatiDiri,
      'literasi': literasi,
      'tanggal': tanggal,
      'muridId': muridId,
      'kelompok': kelompok,
      'rekomendasi': rekomendasi,
      'tanggapan': tanggapan,
      'sekolah': sekolah,
    };
  }

  factory CpModel.fromMap(Map<String, dynamic> map) {
    return CpModel(
      tujuan: map['tujuan'] ?? '',
      kegiatan: map['kegiatan'] ?? '',
      isDone: map['isDone'] ?? false,
      nilaiAgama: map['nilaiAgama'] ?? '',
      jatiDiri: map['jatiDiri'] ?? '',
      literasi: map['literasi'] ?? '',
      tanggal: map['tanggal'] ?? '',
      uid: map['uid'] ?? '',
      id: map['\$id'] ?? '',
      muridId: map['muridId'] ?? '',
      kelompok: map['kelompok'] ?? '',
      rekomendasi: map['rekomendasi'] ?? '',
      tanggapan: map['tanggapan'] ?? '',
      sekolah: map['sekolah'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CpModel.fromJson(String source) =>
      CpModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CpModel(tujuan: $tujuan, kegiatan: $kegiatan, isDone: $isDone, nilaiAgama: $nilaiAgama, jatiDiri: $jatiDiri, literasi: $literasi, tanggal: $tanggal, uid: $uid, id: $id, muridId: $muridId, kelompok: $kelompok, rekomendasi: $rekomendasi, tanggapan: $tanggapan, sekolah: $sekolah)';
  }

  @override
  bool operator ==(covariant CpModel other) {
    if (identical(this, other)) return true;

    return other.tujuan == tujuan &&
        other.kegiatan == kegiatan &&
        other.isDone == isDone &&
        other.nilaiAgama == nilaiAgama &&
        other.jatiDiri == jatiDiri &&
        other.literasi == literasi &&
        other.tanggal == tanggal &&
        other.uid == uid &&
        other.id == id &&
        other.muridId == muridId &&
        other.kelompok == kelompok &&
        other.rekomendasi == rekomendasi &&
        other.tanggapan == tanggapan &&
        other.sekolah == sekolah;
  }

  @override
  int get hashCode {
    return tujuan.hashCode ^
        kegiatan.hashCode ^
        isDone.hashCode ^
        nilaiAgama.hashCode ^
        jatiDiri.hashCode ^
        literasi.hashCode ^
        tanggal.hashCode ^
        uid.hashCode ^
        id.hashCode ^
        muridId.hashCode ^
        kelompok.hashCode ^
        rekomendasi.hashCode ^
        tanggapan.hashCode ^
        sekolah.hashCode;
  }
}
