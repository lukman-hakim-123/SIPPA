// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CpModel {
  final String tujuan;
  final String konteks; // kegiatan
  final bool isDone;
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
  final String sekolah; // ✅ Tambahan

  CpModel({
    required this.tujuan,
    required this.konteks,
    required this.isDone,
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
    required this.sekolah, // ✅
  });

  CpModel copyWith({
    String? tujuan,
    String? konteks,
    bool? isDone,
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
    String? sekolah, // ✅
  }) {
    return CpModel(
      tujuan: tujuan ?? this.tujuan,
      konteks: konteks ?? this.konteks,
      isDone: isDone ?? this.isDone,
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
      sekolah: sekolah ?? this.sekolah, // ✅
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tujuan': tujuan,
      'konteks': konteks,
      'isDone': isDone,
      'agama': agama,
      'jatidiri': jatidiri,
      'literasi': literasi,
      'tanggal': tanggal,
      'uid': uid,
      'muridId': muridId,
      'kelompok': kelompok,
      'rekomendasi': rekomendasi,
      'tanggapan': tanggapan,
      'sekolah': sekolah, // ✅
    };
  }

  factory CpModel.fromMap(Map<String, dynamic> map) {
    return CpModel(
      tujuan: map['tujuan'] ?? '',
      konteks: map['konteks'] ?? '',
      isDone: map['isDone'] ?? false,
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
      sekolah: map['sekolah'] ?? '', // ✅
    );
  }

  String toJson() => json.encode(toMap());

  factory CpModel.fromJson(String source) =>
      CpModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CpModel(tujuan: $tujuan, konteks: $konteks, isDone: $isDone, agama: $agama, jatidiri: $jatidiri, literasi: $literasi, tanggal: $tanggal, uid: $uid, id: $id, muridId: $muridId, kelompok: $kelompok, rekomendasi: $rekomendasi, tanggapan: $tanggapan, sekolah: $sekolah)';
  }

  @override
  bool operator ==(covariant CpModel other) {
    if (identical(this, other)) return true;

    return other.tujuan == tujuan &&
        other.konteks == konteks &&
        other.isDone == isDone &&
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
        konteks.hashCode ^
        isDone.hashCode ^
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
