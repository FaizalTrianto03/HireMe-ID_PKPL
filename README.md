# HireMe.id – Aplikasi Pencarian Kerja Mobile

HireMe.id adalah aplikasi Flutter untuk mencari lowongan pekerjaan dengan pengalaman pengguna yang modern. Pengguna dapat menjelajah pekerjaan, melakukan pencarian (termasuk voice search), serta login menggunakan email/password atau Google. Admin dapat mengelola Event promosi/rekrutmen yang tampil sebagai slider di beranda.

Link unduh APK (build siap pakai):

- Google Drive: https://drive.google.com/drive/folders/1cco-ZywH3J3urdi-nu7_IbiYE18JtlCd?usp=sharing
	- Buka folder tersebut dan ambil file APK (misalnya `app-release.apk`).

## ✨ Fitur Utama

- Jelajah & pencarian pekerjaan (non-login dan login)
- Voice Search menggunakan speech-to-text untuk mempercepat pencarian
- Autentikasi dengan Firebase Auth (Email/Password) dan Google Sign-In
- Slider Event di beranda (data dari Firestore; gambar dari Nextcloud via WebDAV)
- Manajemen Event (Admin): buat, edit, hapus, toggle status per event, serta toggle status global
- Integrasi penyimpanan Nextcloud (WebDAV) untuk aset/gambar event
- Navigasi menggunakan GetX, UI responsif dengan tema ungu khas

## 🧱 Teknologi yang Dipakai

- Flutter (Dart 3.5+)
- GetX (state management & routing)
- Firebase: Core, Auth, Firestore, Storage
- Google Sign-In
- Nextcloud via WebDAV (`webdav_client`) + konfigurasi `.env`
- Speech To Text (`speech_to_text`) + izin mikrofon
- Lainnya: `shared_preferences`, `image_picker`, `url_launcher`, `google_maps_flutter`, `geocoding`, `connectivity_plus`, `carousel_slider`, `lottie`, dll. Lihat `pubspec.yaml` untuk daftar lengkap.

## 🗂️ Struktur Proyek (ringkas)

- `lib/`
	- `auth/` – layar login/daftar/lupa sandi dan kontroler
	- `non_login/` – halaman beranda & browsing untuk pengguna belum login
	- `admin/event/` – halaman admin untuk manajemen event (buat/edit/hapus/detail)
	- `utils/setup_mic.dart` – layanan SpeechService (voice search)
	- `utils/webdav_service.dart` – integrasi Nextcloud WebDAV (ambil header auth, upload/download, list)
	- `routes/` – definisi rute dengan GetX
	- `dependency_injection.dart` – inisialisasi binding/di
	- `main.dart` – entry point aplikasi

## ⚙️ Prasyarat

- Flutter SDK (stable) yang kompatibel dengan Dart 3.5+
- Android SDK / Android Studio untuk build & run Android
- Akun Firebase beserta konfigurasi Android (file `android/app/google-services.json` sudah ada di repo)

Opsional (namun direkomendasikan bila memakai fitur terkait):

- Nextcloud (untuk penyimpanan gambar Event via WebDAV)
- Google Maps API Key (bila mengaktifkan fitur peta/geo)

## 🔐 Konfigurasi Lingkungan (.env)

Aplikasi memakai variabel lingkungan untuk kredensial Nextcloud. Salin file contoh berikut lalu isi sesuai kredensial:

1) Duplikasi file `.env.example` menjadi `.env` di root proyek
2) Isi nilai variabel berikut:

```
NEXTCLOUD_USERNAME=your_nextcloud_username
NEXTCLOUD_PASSWORD=your_nextcloud_password
```

Catatan:
- File `.env` sudah direferensikan di `pubspec.yaml` dan dibaca di `main.dart`/`webdav_service.dart` melalui `flutter_dotenv`.
- Jika `.env` tidak diisi, fitur slider Event (gambar) dan akses WebDAV akan gagal karena auth header tidak tersedia.

## 🚀 Menjalankan Aplikasi (Android)

Di Windows (Command Prompt):

```cmd
flutter pub get
flutter run
```

Pilih perangkat/emulator Android yang tersedia.

## 📦 Build APK Release

```cmd
flutter build apk --release
```

Hasil build ada di:

```
build\app\outputs\flutter-apk\app-release.apk
```

Jika tidak ingin build sendiri, gunakan APK yang telah disediakan di Google Drive (tautan di atas).

## 🧩 Catatan Integrasi

- Firebase
	- Pastikan project Firebase aktif dan `google-services.json` valid (sudah berada di `android/app/`).
	- Untuk Google Sign-In di Android, pastikan SHA-1/SH A-256 ke Firebase Project sudah diset (jika mengalami kendala login Google).

- Nextcloud WebDAV
	- Kredensial diambil dari `.env` (lihat bagian Konfigurasi Lingkungan).
	- Semua operasi file disimpan di folder `HireMe_Id_App/` pada akun Nextcloud.

- Izin Mikrofon
	- Voice search membutuhkan izin mikrofon. Pastikan emulator/device memberikan izin ketika diminta.

## ❓ Troubleshooting

- Gagal memuat gambar Event / slider blank
	- Cek `.env` (pastikan `NEXTCLOUD_USERNAME` & `NEXTCLOUD_PASSWORD` terisi benar)
	- Pastikan server Nextcloud dapat diakses

- Gagal login Google
	- Pastikan SHA-1/SH A-256 aplikasi terdaftar di Firebase Console
	- Pastikan paket aplikasi dan konfigurasi `google-services.json` sesuai

- Error permission mikrofon / voice search tidak aktif
	- Pastikan sudah memberikan izin mikrofon di perangkat/emulator

## 📄 Lisensi

Hak cipta milik pemilik proyek. Penggunaan kode di luar tujuan proyek ini harap dikonsultasikan terlebih dahulu.

=======