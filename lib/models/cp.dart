// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CpModel {
  final String tujuan;
  final String konteks;
  final bool isDone;
  final String teramati;
  final String tanggal;
  final String uid;
  final String id;
  final String muridId;
  final String kelompok;
  final String rekomendasi;
  final String tanggapan;
  CpModel({
    required this.tujuan,
    required this.konteks,
    required this.isDone,
    required this.teramati,
    required this.tanggal,
    required this.uid,
    required this.id,
    required this.muridId,
    required this.kelompok,
    required this.rekomendasi,
    required this.tanggapan,
  });

  CpModel copyWith({
    String? tujuan,
    String? konteks,
    bool? isDone,
    String? teramati,
    String? tanggal,
    String? uid,
    String? id,
    String? muridId,
    String? kelompok,
    String? rekomendasi,
    String? tanggapan,
  }) {
    return CpModel(
      tujuan: tujuan ?? this.tujuan,
      konteks: konteks ?? this.konteks,
      isDone: isDone ?? this.isDone,
      teramati: teramati ?? this.teramati,
      uid: uid ?? this.uid,
      id: id ?? this.id,
      muridId: muridId ?? this.muridId,
      tanggal: tanggal ?? this.tanggal,
      kelompok: kelompok ?? this.kelompok,
      rekomendasi: rekomendasi ?? this.rekomendasi,
      tanggapan: tanggapan ?? this.tanggapan,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tujuan': tujuan,
      'konteks': konteks,
      'isDone': isDone,
      'teramati': teramati,
      'tanggal': tanggal,
      'uid': uid,
      'muridId': muridId,
      'kelompok': kelompok,
      'rekomendasi': rekomendasi,
      'tanggapan': tanggapan,
    };
  }

  factory CpModel.fromMap(Map<String, dynamic> map) {
    return CpModel(
      tujuan: map['tujuan'] ?? '',
      konteks: map['konteks'] ?? '',
      isDone: map['isDone'] ?? false,
      teramati: map['teramati'] ?? '',
      tanggal: map['tanggal'] ?? '',
      uid: map['uid'] ?? '',
      id: map['\$id'] ?? '',
      muridId: map['muridId'] ?? '',
      kelompok: map['kelompok'] ?? '',
      rekomendasi: map['rekomendasi'] ?? '',
      tanggapan: map['tanggapan'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CpModel.fromJson(String source) =>
      CpModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CpModel(tujuan: $tujuan, konteks: $konteks, isDone: $isDone, teramati: $teramati, tanggal: $tanggal, uid: $uid, id: $id, muridId: $muridId,kelompok: $kelompok,rekomendasi: $rekomendasi,tanggapan: $tanggapan,)';
  }

  @override
  bool operator ==(covariant CpModel other) {
    if (identical(this, other)) return true;

    return other.tujuan == tujuan &&
        other.konteks == konteks &&
        other.isDone == isDone &&
        other.teramati == teramati &&
        other.tanggal == tanggal &&
        other.uid == uid &&
        other.id == id &&
        other.muridId == muridId &&
        other.rekomendasi == rekomendasi &&
        other.tanggapan == tanggapan &&
        other.kelompok == kelompok;
  }

  @override
  int get hashCode {
    return tujuan.hashCode ^
        konteks.hashCode ^
        isDone.hashCode ^
        teramati.hashCode ^
        tanggal.hashCode ^
        uid.hashCode ^
        id.hashCode ^
        muridId.hashCode ^
        rekomendasi.hashCode ^
        tanggapan.hashCode ^
        kelompok.hashCode;
  }
}
