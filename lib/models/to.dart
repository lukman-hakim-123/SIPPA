import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class TanggapanModel {
  final String tanggapan;
  late final String balasan;
  final String tanggal;
  final String kelompok;
  final String uid;
  final String id;
  final String muridId;
  TanggapanModel({
    required this.tanggapan,
    required this.kelompok,
    required this.balasan,
    required this.tanggal,
    required this.uid,
    required this.id,
    required this.muridId,
  });

  TanggapanModel copyWith({
    String? tanggapan,
    String? balasan,
    String? kelompok,
    String? tanggal,
    String? uid,
    String? id,
    String? muridId,
  }) {
    return TanggapanModel(
      tanggapan: tanggapan ?? this.tanggapan,
      balasan: balasan ?? this.balasan,
      tanggal: tanggal ?? this.tanggal,
      kelompok: kelompok ?? this.kelompok,
      uid: uid ?? this.uid,
      id: id ?? this.id,
      muridId: muridId ?? this.muridId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tanggapan': tanggapan,
      'balasan': balasan,
      'tanggal': tanggal,
      'kelompok': kelompok,
      'uid': uid,
      'muridId': muridId,
    };
  }

  factory TanggapanModel.fromMap(Map<String, dynamic> map) {
    return TanggapanModel(
      tanggapan: map['tanggapan'] ?? '',
      balasan: map['balasan'] ?? '',
      tanggal: map['tanggal'] ?? '',
      kelompok: map['kelompok'] ?? '',
      uid: map['uid'] ?? '',
      id: map['\$id'] ?? '',
      muridId: map['muridId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory TanggapanModel.fromJson(String source) =>
      TanggapanModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TanggapanModel(tanggapan: $tanggapan, balasan: $balasan,kelompok: $kelompok,tanggal: $tanggal, uid: $uid, id: $id, muridId: $muridId)';
  }

  @override
  bool operator ==(covariant TanggapanModel other) {
    if (identical(this, other)) return true;

    return other.tanggapan == tanggapan &&
        other.balasan == balasan &&
        other.tanggal == tanggal &&
        other.kelompok == kelompok &&
        other.uid == uid &&
        other.id == id &&
        other.muridId == muridId;
  }

  @override
  int get hashCode {
    return tanggapan.hashCode ^
        balasan.hashCode ^
        kelompok.hashCode ^
        uid.hashCode ^
        id.hashCode ^
        muridId.hashCode;
  }
}
