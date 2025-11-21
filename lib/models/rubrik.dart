// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class RubrikModel {
  final String tujuan;
  final String skor;
  final String agama;
  final String jatidiri;
  final String literasi;
  final String tanggal;
  final String uid;
  final String id;
  final String muridId;
  final String kelompok;
  final String rekomendasi; // umpan balik
  final String tanggapan;
  final String sekolah;

  RubrikModel({
    required this.tujuan,
    required this.skor,
    required this.agama,
    required this.jatidiri,
    required this.literasi,
    required this.tanggal,
    required this.uid,
    required this.id,
    required this.muridId,
    required this.kelompok,
    required this.rekomendasi,
    required this.tanggapan,
    required this.sekolah,
  });

  RubrikModel copyWith({
    String? tujuan,
    String? skor,
    String? agama,
    String? jatidiri,
    String? literasi,
    String? tanggal,
    String? uid,
    String? id,
    String? muridId,
    String? kelompok,
    String? rekomendasi,
    String? tanggapan,
    String? sekolah,
  }) {
    return RubrikModel(
      tujuan: tujuan ?? this.tujuan,
      skor: skor ?? this.skor,
      agama: agama ?? this.agama,
      jatidiri: jatidiri ?? this.jatidiri,
      literasi: literasi ?? this.literasi,
      tanggal: tanggal ?? this.tanggal,
      uid: uid ?? this.uid,
      id: id ?? this.id,
      muridId: muridId ?? this.muridId,
      kelompok: kelompok ?? this.kelompok,
      rekomendasi: rekomendasi ?? this.rekomendasi,
      tanggapan: tanggapan ?? this.tanggapan,
      sekolah: sekolah ?? this.sekolah,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tujuan': tujuan,
      'skor': skor,
      'agama': agama,
      'jatidiri': jatidiri,
      'literasi': literasi,
      'tanggal': tanggal,
      'uid': uid,
      'muridId': muridId,
      'kelompok': kelompok,
      'rekomendasi': rekomendasi,
      'tanggapan': tanggapan,
      'sekolah': sekolah,
    };
  }

  factory RubrikModel.fromMap(Map<String, dynamic> map) {
    return RubrikModel(
      tujuan: map['tujuan'] ?? '',
      skor: map['skor'] ?? '',
      agama: map['agama'] ?? '',
      jatidiri: map['jatidiri'] ?? '',
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

  factory RubrikModel.fromJson(String source) =>
      RubrikModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RubrikModel(tujuan: $tujuan, skor: $skor, agama: $agama, jatidiri: $jatidiri, literasi: $literasi, tanggal: $tanggal, uid: $uid, id: $id, muridId: $muridId, kelompok: $kelompok, rekomendasi: $rekomendasi, tanggapan: $tanggapan, sekolah: $sekolah)';
  }

  @override
  bool operator ==(covariant RubrikModel other) {
    if (identical(this, other)) return true;

    return other.tujuan == tujuan &&
        other.skor == skor &&
        other.agama == agama &&
        other.jatidiri == jatidiri &&
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
        skor.hashCode ^
        agama.hashCode ^
        jatidiri.hashCode ^
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
