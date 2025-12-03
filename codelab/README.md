# Testing Codelab - HireMe

Folder ini berisi testing yang dikelompokkan berdasarkan kategori untuk keperluan pembelajaran dan dokumentasi.

## Struktur Folder

- **unit_testing/** - Unit test untuk fungsi dan method individual
  - `login/` - Test untuk fitur login
  - `register/` - Test untuk fitur registrasi
  - `job/` - Test untuk fitur job posting

- **integration_testing/** - Integration test untuk flow lengkap aplikasi

## Cara Menjalankan Test

```bash
# Jalankan semua unit test
flutter test

# Jalankan test spesifik
flutter test codelab/unit_testing/login/login_validation_test.dart

# Jalankan integration test
flutter test integration_test/
```
