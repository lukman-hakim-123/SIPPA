// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PertumbuhanModel {
  final String tanggal;
  final String uid;
  final String id;
  final String muridId;
  final String kelompok;
  final int tinggi; 
  final int berat; 
  final int kepala; 
  final String fisik; 
  final String rekomendasi; 
  final String tanggapan;
  PertumbuhanModel({
    required this.tanggal,
    required this.uid,
    required this.id,
    required this.muridId,
    required this.kelompok,
    required this.tinggi,
    required this.berat,
    required this.kepala,
    required this.fisik,
    required this.rekomendasi,
    required this.tanggapan,
  });

  PertumbuhanModel copyWith({
    String? tanggal,
    String? uid,
    String? id,
    String? muridId,
    String? kelompok,
    int? tinggi,
    int? berat,
    int? kepala,
    String? fisik,
    String? rekomendasi,
    String? tanggapan,
  }) {
    return PertumbuhanModel(
      tanggal: tanggal ?? this.tanggal,
      uid: uid ?? this.uid,
      id: id ?? this.id,
      muridId: muridId ?? this.muridId,
      kelompok: kelompok ?? this.kelompok,
      tinggi: tinggi ?? this.tinggi,
      berat: berat ?? this.berat,
      kepala: kepala ?? this.kepala,
      fisik: fisik ?? this.fisik,
      rekomendasi: rekomendasi ?? this.rekomendasi,
      tanggapan: tanggapan ?? this.tanggapan,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tanggal': tanggal,
      'uid': uid,
      'muridId': muridId,
      'kelompok': kelompok,
      'tinggi': tinggi,
      'berat': berat,
      'kepala': kepala,
      'fisik': fisik,
      'rekomendasi': rekomendasi,
      'tanggapan': tanggapan,
    };
  }

  factory PertumbuhanModel.fromMap(Map<String, dynamic> map) {
    return PertumbuhanModel(
      tanggal: map['tanggal'] ??'',
      uid: map['uid'] ??'',
      id: map['\$id'] ??'',
      muridId: map['muridId'] ??'',
      kelompok: map['kelompok'] ??'',
      tinggi: map['tinggi'] ??0,
      berat: map['berat'] ??0,
      kepala: map['kepala'] ??0,
      fisik: map['fisik'] ??'',
      rekomendasi: map['rekomendasi'] ??'',
      tanggapan: map['tanggapan'] ??'',
    );
  }

  String toJson() => json.encode(toMap());

  factory PertumbuhanModel.fromJson(String source) => PertumbuhanModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PertumbuhanModel(tanggal: $tanggal, uid: $uid, id: $id, muridId: $muridId, kelompok: $kelompok, tinggi: $tinggi, berat: $berat, kepala: $kepala, fisik: $fisik, rekomendasi: $rekomendasi, tanggapan: $tanggapan)';
  }

  @override
  bool operator ==(covariant PertumbuhanModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.tanggal == tanggal &&
      other.uid == uid &&
      other.id == id &&
      other.muridId == muridId &&
      other.kelompok == kelompok &&
      other.tinggi == tinggi &&
      other.berat == berat &&
      other.kepala == kepala &&
      other.fisik == fisik &&
      other.rekomendasi == rekomendasi &&
      other.tanggapan == tanggapan;
  }

  @override
  int get hashCode {
    return tanggal.hashCode ^
      uid.hashCode ^
      id.hashCode ^
      muridId.hashCode ^
      kelompok.hashCode ^
      tinggi.hashCode ^
      berat.hashCode ^
      kepala.hashCode ^
      fisik.hashCode ^
      rekomendasi.hashCode ^
      tanggapan.hashCode;
  }
}
