# SmartFi Mobile (Android)
> **Catat Keuangan + Mentor AI Pribadi**  
> *"Cukup tulis seperti ngobrol, AI yang urus sisanya."*

Aplikasi Android native berbasis **Flutter** yang mengimplementasikan antarmuka khas **Neobrutalism** (kontras tinggi, border tegas 2–4px, hard solid shadow, blueprint grid background, dan respon mekanik tombol).

---

## 🚀 Cara Menjalankan Aplikasi

Aplikasi ini menggunakan konfigurasi lingkungan aman via `env.json` (OpenAI-compatible BangunWeb) untuk fitur kecerdasan AI.

### 1. Prasyarat
- Flutter SDK (3.24+ / Dart 3.13+)
- Android SDK & Perangkat Android / Emulator yang terhubung

### 2. Konfigurasi Lingkungan (`env.json`)
Pastikan file `env.json` telah berada di direktori root `smartfi-mobile` (berisi variabel lingkungan aman tanpa hardcode di repositori):
```json
{
  "AI_BASE_URL": "https://api.bangunweb.com/v1",
  "AI_MODEL": "deepseek-v4.1-flash",
  "AI_API_KEY": "YOUR_API_KEY"
}
```
> Template cadangan tersedia di berkas `env.example.json`.

### 3. Perintah Menjalankan Aplikasi
Jalankan perintah berikut di terminal:
```bash
flutter run --dart-define-from-file=env.json
```
Aplikasi akan langsung berjalan dengan mode **Offline-First (Dummy Repository)** untuk autentikasi, transaksi, dan kategori, serta **Real API** untuk Mentor AI & Smart Input Parser.

---

## 🧠 Fitur & Arsitektur Utama

1. **Dashboard & Visualisasi Finansial**:
   - 3 Kartu Ringkasan (Saldo Terkini, Pemasukan, Pengeluaran).
   - Widget 2x2 Circular Progress (Saldo vs Target Tabungan, Pemasukan, Pengeluaran, Kategori Terbesar).
   - Grafik Batang Tren 7 Hari Terakhir & Diagram Lingkaran Distribusi Kategori (`fl_chart`).
   - Riwayat 5 Transaksi Terkini berstatus Selesai.
   - Modal Saldo Awal (Onboarding) minimal Rp 100.000 jika data baru.
2. **Transaksi & Smart Input AI**:
   - Natural Language Parser (NLP regex Indonesia: "Makan siang 25 ribu", "Gaji 5 juta", "Kopi 20k").
   - Pratinjau interaktif hasil ekstraksi sebelum disimpan.
   - Tambah manual, ubah, dan hapus dengan modal konfirmasi.
   - Filter rentang tanggal dan pencarian instan.
3. **Mentor AI (Penasihat Finansial Pribadi)**:
   - Integrasi API OpenAI-compatible via BangunWeb (`deepseek-v4.1-flash`).
   - System prompt keuangan ketat (tanpa emoji, kasual aku/kamu, titik Rupiah, bold angka/nama).
   - Konteks keuangan dinamis real-time (saldo, total arus kas, pos pengeluaran terbesar, 15 transaksi terakhir).
   - Tombol pintas pertanyaan: *Analisis Otomatis*, *Pengeluaran Terbesar*, *Saran Hemat*.
   - Dukungan Markdown render, tombol *Muat Ulang Respon (Regenerate)*, tombol Refresh, pembersih riwayat obrolan, dan efek audio obrolan.
4. **Kategori Finansial**:
   - Kategori bawaan: Makanan, Transportasi, Hiburan, Gaji.
   - Tambah/edit kategori kustom dengan pilihan 20 ikon Neobrutalism dan 15 warna palet.
5. **Laporan & Ekspor Dokumen**:
   - Filter tanggal mulai, akhir, dan jenis transaksi.
   - Pratinjau tabel rincian transaksi lengkap dengan baris TOTAL & SALDO BERSIH.
   - **Ekspor Dokumen PDF**: Menggunakan generator PDF Neobrutalism resmi via paket `pdf` dan `printing`.
   - **Ekspor Spreadsheet CSV / Excel**: Disimpan ke cache perangkat dan dapat dibagikan langsung ke aplikasi lain via `share_plus`.
6. **Pengaturan & Preferensi**:
   - Ubah profil nama pengguna.
   - Target tabungan bulanan (langsung sinkron ke Widget 2x2 Dashboard).
   - Pilihan tema tampilan Terang vs Gelap.
   - Pengingat harian pencatatan jam harian.
   - Kontrol suara (Mute klik & Mute AI).
   - Koreksi saldo riil otomatis (*Penyesuaian Saldo*).
   - Zona Bahaya: Hapus riwayat transaksi per rentang waktu (Bulan Ini, Tahun Ini, Semua Waktu).

---

## 🔒 Panduan Pengaktifan Firebase (Masa Depan)

Aplikasi telah disiapkan dengan arsitektur **Standby Repositories** di folder `lib/data/repositories/firebase/` dan aturan keamanan di folder `firebase/`. Saat Anda siap menghubungkan backend Cloud Firebase asli, ikuti panduan berikut:

### Langkah 1: Buat Proyek di Firebase Console
1. Buka [Firebase Console](https://console.firebase.google.com/) dan buat proyek baru (Paket **Spark** / Gratis).
2. Daftarkan aplikasi Android dengan:
   - **Package name**: `com.smartfi.mobile`
   - **SHA-1 Fingerprint**: Dapatkan melalui perintah terminal `cd android && ./gradlew signingReport` (dibutuhkan untuk Google Sign-In).

### Langkah 2: Aktifkan Layanan Firebase
1. **Authentication**: Aktifkan penyedia *Email/Password* dan *Google*.
2. **Cloud Firestore**:
   - Buat database di lokasi terdekat (misal `asia-southeast2` Jakarta).
   - Pasang aturan keamanan yang telah disediakan pada berkas `firebase/firestore.rules`.
   - Deploy aturan keamanan menggunakan Firebase CLI:
     ```bash
     firebase deploy --only firestore:rules
     ```

### Langkah 3: Konfigurasi FlutterFire
1. Pasang FlutterFire CLI di sistem Anda jika belum ada:
   ```bash
   dart pub global activate flutterfire_cli
   ```
2. Jalankan perintah konfigurasi otomatis di folder proyek:
   ```bash
   flutterfire configure
   ```
   Perintah ini akan secara otomatis mengunduh `android/app/google-services.json` dan memperbarui `lib/firebase_options.dart`.

### Langkah 4: Tambahkan Paket Firebase ke `pubspec.yaml`
Jalankan:
```bash
flutter pub add firebase_core firebase_auth cloud_firestore google_sign_in
```

### Langkah 5: Aktifkan Repositori di Kode Aplikasi
1. Di `lib/main.dart`, tambahkan inisialisasi Firebase sebelum `runApp`:
   ```dart
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```
2. Di file provider:
   - Ganti `DummyAuthRepository` dengan `FirebaseAuthRepository` di `lib/features/auth/providers/auth_provider.dart`.
   - Ganti `DummyTransactionRepository` dengan `FirebaseTransactionRepository` di `lib/features/transactions/providers/transaction_provider.dart`.
   - Ganti `DummyCategoryRepository` dengan `FirebaseCategoryRepository` di `lib/features/categories/providers/category_provider.dart`.
3. Buka komentar implementasi Firestore di dalam:
   - `lib/data/repositories/firebase/firebase_auth_repository.dart`
   - `lib/data/repositories/firebase/firebase_transaction_repository.dart`
   - `lib/data/repositories/firebase/firebase_category_repository.dart`

---

## 📁 Struktur Direktori

```text
smartfi-mobile/
├── assets/
│   ├── images/logo.png
│   └── sounds/click.mp3, chat.mp3
├── docs/
│   └── PARITY_MATRIX.md
├── firebase/
│   ├── firestore.rules
│   └── firestore.indexes.json
├── lib/
│   ├── core/
│   │   ├── config/ (ai_config.dart, ai_prompts.dart)
│   │   ├── router/ (app_router.dart)
│   │   ├── services/ (audio_service.dart)
│   │   ├── theme/ (neo_colors.dart, neo_theme.dart)
│   │   └── utils/ (currency_formatter.dart, date_formatter.dart, validators.dart)
│   ├── data/
│   │   ├── models/ (user_model.dart, category_model.dart, transaction_model.dart)
│   │   ├── repositories/
│   │   │   ├── dummy/ (dummy_auth, dummy_transaction, dummy_category, dummy_ai)
│   │   │   ├── firebase/ (firebase_auth, firebase_transaction, firebase_category)
│   │   │   └── openai/ (openai_ai_repository.dart)
│   │   └── services/ (pdf_export_service.dart, csv_export_service.dart)
│   ├── features/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── transactions/
│   │   ├── categories/
│   │   ├── ai_advisor/
│   │   ├── reports/
│   │   └── settings/
│   ├── shared/
│   │   └── widgets/ (neo_button, neo_card, neo_input, neo_modal, neo_badge, blueprint_background)
│   ├── firebase_options.dart
│   └── main.dart
├── env.example.json
└── pubspec.yaml
```
