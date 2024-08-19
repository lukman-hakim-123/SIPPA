import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ObservasiModel {
  final String kegiatan;
  final String hasilObservasi;
  final String rekomendasi;
  final String tanggal;
  final String kelompok;
  final String imageId;
  final String uid;
  final String id;
  final String muridId;
  final String tanggapan;
  ObservasiModel({
    required this.kegiatan,
    required this.hasilObservasi,
    required this.rekomendasi,
    required this.tanggal,
    required this.kelompok,
    required this.imageId,
    required this.uid,
    required this.id,
    required this.muridId,
    required this.tanggapan,
  });

  ObservasiModel copyWith({
    String? kegiatan,
    String? hasilObservasi,
    String? rekomendasi,
    String? tanggal,
    String? kelompok,
    String? imageId,
    String? uid,
    String? id,
    String? muridId,
    String? tanggapan,
  }) {
    return ObservasiModel(
      kegiatan: kegiatan ?? this.kegiatan,
      hasilObservasi: hasilObservasi ?? this.hasilObservasi,
      rekomendasi: rekomendasi ?? this.rekomendasi,
      tanggal: tanggal ?? this.tanggal,
      kelompok: kelompok ?? this.kelompok,
      imageId: imageId ?? this.imageId,
      uid: uid ?? this.uid,
      id: id ?? this.id,
      muridId: muridId ?? this.muridId,
      tanggapan: tanggapan ?? this.tanggapan,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'kegiatan': kegiatan,
      'hasilObservasi': hasilObservasi,
      'rekomendasi': rekomendasi,
      'tanggal': tanggal,
      'kelompok': kelompok,
      'imageId': imageId,
      'uid': uid,
      'muridId': muridId,
      'tanggapan': tanggapan,
    };
  }

  factory ObservasiModel.fromMap(Map<String, dynamic> map) {
    return ObservasiModel(
      kegiatan: map['kegiatan'] ?? '',
      hasilObservasi: map['hasilObservasi'] ?? '',
      rekomendasi: map['rekomendasi'] ?? '',
      tanggal: map['tanggal'] ?? '',
      kelompok: map['kelompok'] ?? '',
      imageId: map['imageId'] ?? '',
      uid: map['uid'] ?? '',
      id: map['\$id'] ?? '',
      muridId: map['muridId'] ?? '',
      tanggapan: map['tanggapan'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ObservasiModel.fromJson(String source) =>
      ObservasiModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ObservasiModel(kegiatan: $kegiatan, hasilObservasi: $hasilObservasi, rekomendasi: $rekomendasi, tanggal: $tanggal, kelompok: $kelompok, imageId: $imageId, uid: $uid, id: $id, muridId: $muridId, tanggapan: $tanggapan)';
  }

  @override
  bool operator ==(covariant ObservasiModel other) {
    if (identical(this, other)) return true;

    return other.kegiatan == kegiatan &&
        other.hasilObservasi == hasilObservasi &&
        other.rekomendasi == rekomendasi &&
        other.tanggal == tanggal &&
        other.kelompok == kelompok &&
        other.imageId == imageId &&
        other.uid == uid &&
        other.id == id &&
        other.tanggapan == tanggapan &&
        other.muridId == muridId;
  }

  @override
  int get hashCode {
    return kegiatan.hashCode ^
        hasilObservasi.hashCode ^
        rekomendasi.hashCode ^
        tanggal.hashCode ^
        kelompok.hashCode ^
        imageId.hashCode ^
        uid.hashCode ^
        id.hashCode ^
        tanggapan.hashCode ^
        muridId.hashCode;
  }
}
