import 'package:mongo_dart/mongo_dart.dart';

/// LogModel (Modul 4 - Langkah 1 BSON Mapping)
/// Mentransformasi data Logbook ↔ BSON/Map untuk pengiriman ke MongoDB Atlas.
///
/// - toMap()    : "Membungkus" data ke format BSON (kardus pengiriman)
/// - fromMap()  : "Membongkar" data dari BSON kembali ke objek Flutter
class LogModel {
  final ObjectId? id; // Penanda unik global dari MongoDB
  final String title;
  final String description;
  final DateTime date;
  final String category; // 'Pribadi', 'Pekerjaan', 'Urgent'

  LogModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    this.category = 'Pribadi',
  });

  // [CONVERT] Memasukkan data ke "Kardus" (BSON/Map) untuk dikirim ke Cloud
  Map<String, dynamic> toMap() {
    return {
      '_id': id ?? ObjectId(), // Buat ID otomatis jika belum ada
      'title': title,
      'description': description,
      'date': date.toIso8601String(), // Simpan tanggal dalam format standar
      'category': category,
    };
  }

  // [REVERT] Membongkar "Kardus" (BSON/Map) kembali menjadi objek Flutter
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['_id'] as ObjectId?,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      category: map['category'] ?? 'Pribadi',
    );
  }
}
