# Matriks Paritas Fitur SmartFi (Web Next.js ke Mobile Flutter)

Dokumen ini memetakan seluruh fitur, logika, fungsi, dan tampilan dari aplikasi web SmartFi (`smartfi-app`) ke arsitektur aplikasi mobile Android berbasis Flutter (`smartfi-mobile`).

> **Prinsip Utama:**
> - Seluruh fitur, perhitungan, validasi, dan estetika Neobrutalism dipertahankan 100%.
> - Backend menggunakan Firebase (Auth, Cloud Firestore), dengan layer Repository dummy offline-first terlebih dahulu sehingga aplikasi dapat berjalan dan diuji langsung di HP tanpa konfigurasi Firebase awal.
> - Implementasi Firebase murni disediakan di file terpisah (belum diaktifkan).
> - Tidak ada API key di dalam kode sumber.

---

## Tabel Matriks Paritas Fitur

| No | Modul / Fitur | File Sumber Web (Next.js) | Rencana Implementasi di Flutter | Status | Keterangan & Penyesuaian Mobile |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | **Fondasi & Desain (Neobrutalism)** | | | | |
| 1.1 | Tema Warna & Design Tokens | `design.md`, `tailwind.config.js`, `globals.css` | `lib/core/theme/neo_colors.dart`, `neo_theme.dart` | Selesai | Warna: Biru muda `#E6F0FF`, Putih `#FFFFFF`, Aksen Biru `#3B82F6`, Hijau `#10B981`, Merah `#EF4444`, Kuning `#F59E0B`, Ungu `#8B5CF6`. |
| 1.2 | Komponen Tombol Neobrutalism | `src/components/ui/Button.jsx`, `design.md` | `lib/shared/widgets/neo_button.dart` | Selesai | Border 2-4px hitam pekat, hard shadow 4-8px tanpa blur, efek mekanis bergeser saat ditekan. |
| 1.3 | Komponen Kartu / Kontainer | `src/components/ui/Card.jsx`, `design.md` | `lib/shared/widgets/neo_card.dart` | Selesai | Background putih, border 4px hitam, solid shadow 8px, sudut kaku (radius 0-6). |
| 1.4 | Komponen Input Field | `src/components/ui/Input.jsx`, `design.md` | `lib/shared/widgets/neo_input.dart` | Selesai | Border 2-4px hitam, shadow aktif saat fokus, label uppercase tebal. |
| 1.5 | Dialog & Bottom Sheet Modal | `src/components/ui/Modal.jsx`, `design.md` | `lib/shared/widgets/neo_modal.dart` | Selesai | Dialog & bottom sheet bergaya Neobrutalism dengan header warna `#E6F0FF` dan border tebal. |
| 1.6 | Utilitas Format & Validator | `src/lib/utils.js`, `validators.js` | `lib/core/utils/formatters.dart`, `validators.dart` | Selesai | Format mata uang Rupiah (`Rp 1.000.000`), format tanggal Indonesia (`dd MMM yyyy`), validasi email & nominal. |
| 1.7 | Efek Suara (Audio Feedback) | `src/utils/playSound.js`, `sounds/*.mp3` | `lib/core/services/audio_service.dart` | Selesai | Audio efek klik dan respons AI dengan toggle mute di pengaturan. |
| **2** | **Navigasi & Arsitektur Utama** | | | | |
| 2.1 | Rute & Navigasi Utama | `src/app/layout.js`, `src/proxy.js` | `lib/core/router/app_router.dart` (GoRouter) | Selesai | Guard rute sesi pengguna: Splash -> Auth (Login/Register) -> Main Shell. |
| 2.2 | Shell Navigasi Bawah (Bottom Bar) | `src/components/layout/Sidebar.jsx` | `lib/features/main/main_screen.dart` | Selesai | Menggantikan sidebar web dengan Bottom Navigation Bar 5 tab: Beranda, Transaksi, Mentor AI, Laporan, Pengaturan. |
| 2.3 | Top Header & Profil Avatar | `src/components/layout/Header.jsx` | `lib/shared/widgets/neo_app_bar.dart` | Selesai | Header atas dengan judul layar, tombol notifikasi, dan avatar pengguna. |
| **3** | **Autentikasi (Auth)** | | | | |
| 3.1 | Masuk dengan Email & Kata Sandi | `src/app/(auth)/login/page.js` | `lib/features/auth/screens/login_screen.dart` | Selesai | Validasi form (email wajib, kata sandi wajib), pesan error bahasa Indonesia, loading state. |
| 3.2 | Masuk dengan Google (Google Sign-In) | `src/app/(auth)/login/page.js` | `lib/features/auth/widgets/google_sign_in_button.dart` | Selesai | Tombol Neobrutalism Google Sign-In, integrasi dengan dummy repo & persiapan Firebase Google Auth. |
| 3.3 | Pendaftaran Akun Baru (Register) | `src/app/(auth)/register/page.js` | `lib/features/auth/screens/register_screen.dart` | Selesai | Form email & kata sandi (min. 6 karakter), auto generate kategori bawaan untuk akun baru. |
| 3.4 | Pengelolaan Sesi & Keluar (Logout) | `src/proxy.js`, `Sidebar.jsx` | `lib/data/repositories/auth_repository.dart` | Selesai | Sesi tersimpan persisten (tidak perlu login ulang), tombol keluar di Pengaturan & Sidebar. |
| **4** | **Dashboard / Beranda** | | | | |
| 4.1 | Ringkasan Saldo, Pemasukan, Pengeluaran | `src/app/dashboard/page.js` | `lib/features/dashboard/widgets/summary_cards.dart` | Selesai | Kartu Saldo Terkini (biru), Pemasukan (hijau), Pengeluaran (merah). |
| 4.2 | Widget Statistik 2x2 (Mobile First) | `FITUR.md`, `PROJECT_CONTEXT.txt` | `lib/features/dashboard/widgets/widget_2x2.dart` | Selesai | Grid 2x2 Circular Progress: 1. Saldo (% target tabungan), 2. Pemasukan, 3. Pengeluaran, 4. Kategori Terbesar (% & nama). |
| 4.3 | Grafik Batang Tren 7 Hari Terakhir | `src/app/dashboard/page.js` (Recharts) | `lib/features/dashboard/widgets/expense_bar_chart.dart` (fl_chart) | Selesai | Menghitung pengeluaran harian 7 hari terakhir secara dinamis dengan ticks angka rapi. |
| 4.4 | Grafik Lingkaran Pengeluaran Kategori | `src/app/dashboard/page.js` (Recharts) | `lib/features/dashboard/widgets/category_pie_chart.dart` (fl_chart) | Selesai | Distribusi pengeluaran per kategori warna-warni + legend nama kategori. |
| 4.5 | Riwayat 5 Transaksi Terkini | `src/app/dashboard/page.js` | `lib/features/dashboard/widgets/recent_transactions_list.dart` | Selesai | List transaksi terbaru dengan badge kategori kuning, nominal bertanda (+/-), dan badge Selesai. |
| 4.6 | Modal Saldo Awal (Onboarding) | `src/components/dashboard/OnboardingModal.jsx` | `lib/features/dashboard/widgets/initial_balance_dialog.dart` | Selesai | Muncul otomatis jika pengguna baru belum memiliki transaksi sama sekali (minimal Rp 100.000). |
| **5** | **Transaksi & Smart Input AI** | | | | |
| 5.1 | Smart Input AI (Natural Language Parser) | `src/components/transactions/SmartInput.jsx`, `api/ai/chat` | `lib/features/transactions/widgets/smart_input_box.dart` | Selesai | Input kalimat alami ("Makan siang warteg 25 ribu"), parsing tipe, kategori, nominal, deskripsi. |
| 5.2 | Pratinjau & Edit Hasil Smart Input | `src/components/transactions/SmartInput.jsx` | `lib/features/transactions/widgets/smart_preview_card.dart` | Selesai | Menampilkan hasil ekstraksi AI yang dapat diedit langsung sebelum ditekan Simpan. |
| 5.3 | Ringkasan Bulan Ini & Bar Pemasukan/Pengeluaran | `src/app/dashboard/transactions/page.js` | `lib/features/transactions/widgets/transaction_monthly_summary.dart` | Selesai | Kartu Saldo Terkini + Bar Chart komparasi pemasukan vs pengeluaran bulan ini. |
| 5.4 | Daftar Riwayat Transaksi | `src/app/dashboard/transactions/page.js` | `lib/features/transactions/widgets/transaction_list_view.dart` | Selesai | Daftar transaksi lengkap diurutkan dari yang terbaru dengan format tanggal Indonesia. |
| 5.5 | Tambah Manual & Edit Transaksi | `src/components/transactions/ManualForm.jsx` | `lib/features/transactions/widgets/transaction_form_dialog.dart` | Selesai | Modal input transaksi manual (tipe income/expense, kategori, nominal, deskripsi, tanggal). |
| 5.6 | Hapus Transaksi | `src/app/dashboard/transactions/page.js` | `lib/features/transactions/screens/transactions_screen.dart` | Selesai | Tombol hapus dengan konfirmasi dialog Neobrutalism. |
| 5.7 | Pencarian & Filter Transaksi | `src/components/transactions/TransactionFilters.jsx` | `lib/features/transactions/widgets/transaction_search_filter.dart` | Selesai | Filter berdasarkan jenis (semua/pemasukan/pengeluaran), rentang tanggal, & kata kunci pencarian. |
| **6** | **Mentor AI (Penasihat Finansial Pribadi)** | | | | |
| 6.1 | Antarmuka Chat & Bubble Percakapan | `src/app/dashboard/ai-advisor/page.js` | `lib/features/ai_advisor/screens/ai_advisor_screen.dart` | Selesai | Bubble chat User (kuning) & AI (putih) dengan avatar logo SmartFi dan border tebal. |
| 6.2 | Penyusunan Konteks Keuangan Real-time | `src/app/dashboard/ai-advisor/page.js`, `api/chat` | `lib/data/repositories/ai_repository.dart` | Selesai | Mengirim saldo, pemasukan, pengeluaran, kategori terbesar, dan 15 transaksi terbaru ke AI. |
| 6.3 | Aturan & System Prompt Keuangan Ketat | `src/app/api/chat/route.js` | `lib/core/config/ai_prompts.dart` | Selesai | Hanya topik finansial, bahasa kasual (aku & kamu), tanpa emoji, format uang titik ("Rp 300.000"), nama & angka dicetak tebal. |
| 6.4 | Tombol Pintasan Saran Cepat | `src/app/dashboard/ai-advisor/page.js` | `lib/features/ai_advisor/widgets/suggestion_pills.dart` | Selesai | Tombol "Analisis Otomatis", "Pengeluaran Terbesar", "Saran Hemat". |
| 6.5 | Fitur Chat: Muat Ulang Respon (Regenerate) | `src/app/dashboard/ai-advisor/page.js` | `lib/features/ai_advisor/widgets/chat_message_bubble.dart` | Selesai | Mengulang generasi respons terakhir dari asisten AI. |
| 6.6 | Fitur Chat: Refresh Percakapan & Hapus Riwayat | `src/app/dashboard/ai-advisor/page.js` | `lib/features/ai_advisor/screens/ai_advisor_screen.dart` | Selesai | Tombol Muat Ulang Chat & tombol Hapus Riwayat Chat dengan konfirmasi. |
| 6.7 | Render Teks Format Markdown | `src/app/dashboard/ai-advisor/page.js` (`react-markdown`) | `lib/features/ai_advisor/widgets/chat_message_bubble.dart` (`flutter_markdown`) | Selesai | Format heading, bullet list, ordered list, quote, dan bold text rapi. |
| 6.8 | Penyimpanan Riwayat Chat Lokal | `src/app/dashboard/ai-advisor/page.js` (`localStorage`) | `lib/features/ai_advisor/providers/ai_provider.dart` (`shared_preferences`) | Selesai | Histori percakapan tetap tersimpan saat pengguna keluar dan membuka kembali layar Mentor AI. |
| **7** | **Kategori (Manajemen Kategori)** | | | | |
| 7.1 | Grid Daftar Kategori & Ikon | `src/app/dashboard/categories/page.js` | `lib/features/categories/screens/categories_screen.dart` | Selesai | Grid kartu kategori dengan warna latar khas, ikon Neobrutalism, dan badge tipe. |
| 7.2 | Kategori Default Pengguna | `src/app/dashboard/categories/page.js` | `lib/data/models/category_model.dart` | Selesai | Makanan, Transportasi, Hiburan, Gaji (terkunci dari hapus). |
| 7.3 | Tambah Kategori Baru | `src/app/dashboard/categories/page.js` | `lib/features/categories/widgets/category_form_modal.dart` | Selesai | Form modal: Nama kategori, pilihan tipe (Income/Expense), 20 pilihan ikon, 15 palet warna. |
| 7.4 | Edit & Hapus Kategori | `src/app/dashboard/categories/page.js` | `lib/features/categories/screens/categories_screen.dart` | Selesai | Ubah detail kategori custom, hapus kategori dengan dialog konfirmasi. |
| **8** | **Laporan Keuangan & Ekspor** | | | | |
| 8.1 | Filter Periode & Jenis Laporan | `src/app/dashboard/reports/page.js` | `lib/features/reports/widgets/report_filter_card.dart` | Selesai | Pemilih tanggal mulai, tanggal akhir, serta tipe (Semua, Pemasukan, Pengeluaran). |
| 8.2 | Kartu Ringkasan (Pemasukan, Pengeluaran, Saldo) | `src/app/dashboard/reports/page.js` | `lib/features/reports/widgets/report_summary_cards.dart` | Selesai | Menghitung total pemasukan, total pengeluaran, dan saldo bersih sesuai periode filter. |
| 8.3 | Tabel Pratinjau Transaksi | `src/app/dashboard/reports/page.js` | `lib/features/reports/widgets/report_table.dart` | Selesai | Tabel nomor, tanggal, kategori, deskripsi, nominal pemasukan/pengeluaran, baris TOTAL & SALDO BERSIH. |
| 8.4 | Ekspor Dokumen PDF | `src/app/dashboard/reports/page.js` (`window.print`) | `lib/data/services/pdf_export_service.dart` (`pdf` + `printing`) | Selesai | Membuat file PDF berformat resmi SmartFi Neobrutalism, simpan ke HP, dan buka/bagikan. |
| 8.5 | Ekspor Dokumen Excel / CSV | `src/app/dashboard/reports/page.js` | `lib/data/services/csv_export_service.dart` (`share_plus`) | Selesai | Menyusun data ke spreadsheet `.csv`, simpan ke cache perangkat, dan bagikan via `share_plus`. |
| **9** | **Pengaturan (Settings) & Preferensi** | | | | |
| 9.1 | Pembaruan Profil Pengguna | `src/app/dashboard/settings/page.js` | `lib/features/settings/widgets/profile_settings_card.dart` | Selesai | Ubah Nama Lengkap (email read-only). |
| 9.2 | Target Tabungan Bulanan | `src/app/dashboard/settings/page.js` | `lib/features/settings/widgets/savings_target_card.dart` | Selesai | Input nominal target tabungan bulanan dengan format ribuan otomatis. |
| 9.3 | Preferensi Tema Gelap / Terang | `src/components/ThemeToggle.jsx`, `settings` | `lib/features/settings/widgets/theme_settings_card.dart` | Selesai | Toggle tema Light / Dark mode Neobrutalism tersimpan di preferensi. |
| 9.4 | Pengingat Harian (Scheduled Local Notification) | `src/app/dashboard/settings/page.js` | `lib/features/settings/widgets/notification_settings_card.dart` | Selesai | Toggle aktif/nonaktif pengingat + time picker jam harian tersimpan di preferensi. |
| 9.5 | Kontrol Efek Suara (Mute Audio) | `src/app/dashboard/settings/page.js` | `lib/features/settings/widgets/audio_settings_card.dart` | Selesai | Toggle matikan suara klik tombol dan matikan suara AI. |
| 9.6 | Koreksi Saldo Aktual Manual | `src/app/dashboard/settings/page.js` | `lib/features/settings/widgets/balance_correction_card.dart` | Selesai | Menghitung selisih saldo riil dengan saldo tersimpan, otomatis buat transaksi penyesuaian. |
| 9.7 | Informasi Paket / Status Langganan | `src/app/dashboard/settings/page.js` | `lib/features/settings/widgets/subscription_info_card.dart` | Selesai | Menampilkan status paket akun (Bebas / Unlimited). |
| 9.8 | Zona Bahaya: Hapus Data Transaksi | `src/app/dashboard/settings/page.js` | `lib/features/settings/widgets/danger_zone_card.dart` | Selesai | Hapus riwayat transaksi berdasarkan rentang (Bulan Ini, Tahun Ini, Semua Waktu) dengan konfirmasi. |
| 9.9 | Navigasi Kelola Kategori & Tombol Keluar | `src/app/dashboard/settings/page.js` | `lib/features/settings/screens/settings_screen.dart` | Selesai | Akses cepat ke Manajemen Kategori dan tombol Logout akun. |
| **10** | **Arsitektur Data & Kesiapan Backend** | | | | |
| 10.1 | Model Data (User, Category, Transaction) | `scripts/schema.sql`, `PROJECT_CONTEXT.txt` | `lib/data/models/` | Selesai | Definisi objek Dart dengan serialisasi JSON & Firestore converter. |
| 10.2 | Dummy Repositories (Offline-Ready) | - | `lib/data/repositories/dummy/` | Selesai | Implementasi in-memory & SharedPreferences agar aplikasi langsung jalan 100% tanpa konfigurasi Firebase. |
| 10.3 | Firebase Repositories (Standby / Belum Diaktifkan) | `PLANNING_SMARTFI_MOBILE.txt` (Bagian 6 & 7) | `lib/data/repositories/firebase/` | Selesai | Kode Firebase Auth & Cloud Firestore siap pakai di file terpisah, tanpa memanggil initializeApp. |
| 10.4 | Firestore Security Rules & Indexes | `PLANNING_SMARTFI_MOBILE.txt` (Bagian 6.4) | `firebase/firestore.rules`, `firestore.indexes.json` | Selesai | Aturan keamanan Cloud Firestore subkoleksi `users/{uid}`. |

