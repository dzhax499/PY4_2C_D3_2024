# logbook_app_001

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
---

## Self-Reflection: Penerapan Prinsip SRP pada History Logger Feature

### Bagaimana prinsip SRP membantu saat menambah fitur History Logger?

Penerapan **Single Responsibility Principle (SRP)** sangat membantu dalam pengembangan fitur History Logger ini. Berikut adalah bagaimana prinsip ini bekerja:

#### 1. **Pemisahan Code yang Jelas (Modular)**
- **CounterController**: berfungsi untuk logika bisnis, yaitu mengelola nilai counter dan mencatat aktivitas ke dalam history.
- **CounterView**: berfungsi untuk presentasi UI dan interaksi user.

Dengan pemisahan ini, ketika saya menambah fitur history logger, saya hanya perlu memodifikasi CounterController untuk:
- Menyimpan tipe aktivitas (increment, decrement, reset)
- Menyimpan pesan log dengan timestamp

#### 2. **Kemudahan dalam Perubahan dan Ekspansi**
Saat diminta menambahkan warna dan icon untuk setiap tipe aktivitas:
- saya **tidak perlu mengubah logika di CounterController**
- saya hanya memodifikasi **CounterView** untuk menambahkan logic UI (penentuan warna, icon)
- Method helper `_getActivityIcon()` dibuat tanpa mengganggu business logic

#### 3. **Maintainability yang Lebih Baik**
- Jika ada bug di history logging, saya tahu untuk kelihatan ke `CounterController`
- Jika ada masalah tampilan history (warna, ikon, layout), saya fokus ke `CounterView`
- Tidak perlu debug di file yang tidak relevan atau khawatir tentang side effects yang tidak terduga

#### 4. **Reusability dan Fleksibilitas**
- Method `getLastFiveActivities()` di CounterController bisa digunakan berulang kali di berbagai tempat tanpa perlu modifikasi
- Format data history (Map dengan type dan message) cukup fleksibel untuk menambah field baru di masa depan

#### Kesimpulan
Dengan menerapkan SRP, kode menjadi lebih mudah dipahami, dimodifikasi, dan di-maintain. Setiap class memiliki alasan yang jelas untuk berubah, sehingga membuat proses development lebih efisien dan minim risiko kesalahan.