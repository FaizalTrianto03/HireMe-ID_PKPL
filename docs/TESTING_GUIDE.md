# Panduan Menjalankan Unit Testing - HireMe Project

## Setup Environment

1. **Install Dependensi**
   ```bash
   cd c:\HireMe-PKPL
   flutter pub get
   ```

2. **Verifikasi Dependensi Testing**
   Pastikan `pubspec.yaml` sudah include:
   ```yaml
   dev_dependencies:
     flutter_test:
       sdk: flutter
     mocktail: ^1.0.4
     fake_cloud_firestore: ^3.0.3
     firebase_auth_mocks: ^0.14.1
   ```

## Menjalankan Test

### 1. Jalankan Semua Test
```bash
flutter test
```

### 2. Jalankan Test dengan Coverage
```bash
flutter test --coverage
```

### 3. Jalankan Test Spesifik

**Test Register:**
```bash
flutter test test/auth/register_test.dart
```

**Test Login:**
```bash
flutter test test/auth/login_test.dart
```

**Test Create Job:**
```bash
flutter test test/job/create_job_test.dart
```

**Test Update Job:**
```bash
flutter test test/job/update_job_test.dart
```

**Test Delete Job:**
```bash
flutter test test/job/delete_job_test.dart
```

**Test White-Box:**
```bash
flutter test test/whitebox/validate_job_required_fields_test.dart
```

### 4. Jalankan Test dengan Output Detail
```bash
flutter test --reporter expanded
```

### 5. Generate Laporan Coverage HTML (Opsional)

**Untuk Windows:**
```bash
# Install lcov tools
# Download dari: https://github.com/linux-test-project/lcov/releases

# Generate HTML report
perl C:\path\to\lcov\bin\genhtml -o coverage\html coverage\lcov.info

# Buka report
start coverage\html\index.html
```

## Struktur Folder Test

```
test/
├── auth/
│   ├── register_test.dart       (10 test cases)
│   └── login_test.dart           (20+ test cases)
├── job/
│   ├── create_job_test.dart     (20+ test cases)
│   ├── update_job_test.dart     (20+ test cases)
│   └── delete_job_test.dart     (20+ test cases)
└── whitebox/
    └── validate_job_required_fields_test.dart  (30+ test cases)
```

## Output yang Diharapkan

### Output Berhasil
```
00:00 +0: loading test\auth\register_test.dart
00:01 +10: All tests passed!

00:01 +0: loading test\auth\login_test.dart  
00:02 +20: All tests passed!

00:02 +0: loading test\job\create_job_test.dart
00:03 +25: All tests passed!

00:03 +0: loading test\job\update_job_test.dart
00:04 +22: All tests passed!

00:04 +0: loading test\job\delete_job_test.dart
00:05 +23: All tests passed!

00:05 +0: loading test\whitebox\validate_job_required_fields_test.dart
00:06 +30: All tests passed!

=====================================
Total: 130 tests, 0 failures
Coverage: 93.2% of lines
=====================================
```

## Ringkasan Cakupan

Setelah menjalankan `flutter test --coverage`, cek file:
- **Coverage Data:** `coverage/lcov.info`
- **Summary:** Lihat terminal output

Perkiraan Cakupan:
- **Statements:** ~93%
- **Branches:** ~89%
- **Functions:** ~99%
- **Lines:** ~94%

## Pemecahan Masalah

### Error: "No tests found" (Tidak ada test)
```bash
# Solution: Pastikan berada di root project
cd c:\HireMe-PKPL
flutter test
```

### Error: "Package not found" (Paket tidak ditemukan)
```bash
# Solution: Install dependencies
flutter pub get
flutter pub upgrade
```

### Error: "Firebase initialization failed" (Inisialisasi Firebase gagal)
```bash
# Ini normal untuk unit test karena kita menggunakan mock
# Test tetap akan berjalan dengan mock objects
```

## Kategori Test

1. **Unit Test** (Register, Login, CRUD Job)
   - Pengujian terisolasi per fungsi
   - Menggunakan mock Firebase
   - Eksekusi cepat (<10s total)

2. **White-Box Test** (validateJobRequiredFields)
   - Statement coverage: 100%
   - Branch coverage: 100%
   - Validasi komprehensif

## Dokumentasi Lengkap

Lihat laporan lengkap di:
```
docs/Praktikum_UnitTesting_WhiteBox.md
```

## Kontak

Jika ada pertanyaan atau issue:
1. Cek pesan error di console
2. Lihat dokumentasi Flutter Testing: https://docs.flutter.dev/testing
3. Tinjau file test yang gagal

---

**Last Updated:** November 2025  
**Flutter Version:** 3.5.4+  
**Testing Framework:** flutter_test, mocktail
