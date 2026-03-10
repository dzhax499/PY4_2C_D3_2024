import 'package:flutter_dotenv/flutter_dotenv.dart';

class AccessControlService {
  // Aksi yang bisa dilakukan
  static const String actionCreate = 'create';
  static const String actionRead = 'read';
  static const String actionUpdate = 'update';
  static const String actionDelete = 'delete';

  /// Cek apakah role tertentu boleh melakukan action tertentu
  /// `isOwner` opsional: jika bernilai true, berarti current user = author log.
  static bool canPerform(String role, String action, {bool isOwner = false}) {
    switch (action) {
      case actionCreate:
        // Semua bisa create asal ada teamId
        return true;
      case actionRead:
        // Semua bisa read data yang termuat
        return true;
      case actionUpdate:
      case actionDelete:
        // HOMEWORK 5: Kedaulatan Editor (The "Owner-Only" Rule)
        // Hanya pembuat catatan (Owner) yang boleh edit/hapus
        // Role 'Ketua' tidak berpengaruh di sini.
        return isOwner;
      default:
        return false;
    }
  }
}
