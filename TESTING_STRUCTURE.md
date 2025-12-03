# Struktur Testing HireMe - PKPL

Dokumentasi lengkap struktur testing yang telah diorganisir untuk keperluan pembelajaran (codelab) dan automated testing.

## 📁 Struktur Folder

```
HireMe-PKPL/
├── .maestro/                   # Automated testing dengan Maestro (16 TC)
│   ├── README.md
│   ├── TC-LOGIN-01.yaml
│   ├── TC-LOGIN-02.yaml
│   ├── TC-LOGIN-03.yaml
│   ├── TC-LOGIN-04.yaml
│   ├── TC-REGISTER-01.yaml
│   ├── TC-REGISTER-02.yaml
│   ├── TC-REGISTER-03.yaml
│   ├── TC-REGISTER-04.yaml
│   ├── TC-JOB-01.yaml
│   ├── TC-JOB-02.yaml
│   ├── TC-JOB-03.yaml
│   ├── TC-JOB-04.yaml
│   ├── TC-JOB-05.yaml
│   ├── TC-JOB-06.yaml
│   ├── TC-JOB-07.yaml
│   └── TC-JOB-08.yaml
│
├── codelab/                    # Testing untuk pembelajaran
│   ├── README.md
│   └── unit_testing/
│       ├── login/
│       │   └── login_validation_test.dart
│       ├── register/
│       │   └── register_validation_test.dart
│       └── job/
│           └── job_validation_test.dart
│
└── test/                       # Testing asli (existing)
    ├── auth/
    │   ├── login_test.dart
    │   └── register_test.dart
    └── job/
        ├── create_job_test.dart
        ├── delete_job_test.dart
        └── update_job_test.dart
```

## 🎯 Tujuan

### Folder `.maestro/`
Berisi 16 automated test cases menggunakan Maestro:
- **Login Testing (4 TC)** - Validasi login dengan berbagai skenario
- **Register Testing (4 TC)** - Validasi pendaftaran user baru
- **Job Testing (8 TC)** - Validasi pembuatan dan validasi job posting
- File test menggunakan format YAML
- Comment dalam bahasa sederhana dan mudah dipahami
- Sudah diverifikasi dengan testing manual

### Folder `codelab/`
Berisi unit testing yang sudah dikelompokkan berdasarkan fitur untuk keperluan pembelajaran:
- **Login Testing** - Validasi email, password, dan role
- **Register Testing** - Validasi pendaftaran user baru
- **Job Testing** - Validasi pembuatan job posting

## 📝 Detail Test Cases

| Test Case ID | Deskripsi | File |
|-------------|-----------|------|
| TC-LOGIN-01 | Login dengan email dan password yang benar | `.maestro/TC-LOGIN-01.yaml` |
| TC-LOGIN-02 | Email tanpa format yang benar | `.maestro/TC-LOGIN-02.yaml` |
| TC-LOGIN-03 | Pemeriksaan status akun dan role user | `.maestro/TC-LOGIN-03.yaml` |
| TC-LOGIN-04 | Akun tidak aktif atau role kosong | `.maestro/TC-LOGIN-04.yaml` |
| TC-LOGIN-03 | Pemeriksaan status akun dan role user | `demo/TC-LOGIN-03/test.yaml` |
| TC-LOGIN-04 | Akun tidak aktif atau role kosong | `demo/TC-LOGIN-04/test.yaml` |

### Register Test Cases

| Test Case ID | Deskripsi | File |
|-------------|-----------|------|
| TC-REGISTER-01 | Pendaftaran dengan email baru dan password kuat | `.maestro/TC-REGISTER-01.yaml` |
| TC-REGISTER-02 | Email sudah terdaftar | `.maestro/TC-REGISTER-02.yaml` |
| TC-REGISTER-03 | Tanpa memilih role | `.maestro/TC-REGISTER-03.yaml` |
| TC-REGISTER-04 | Role tidak valid | `.maestro/TC-REGISTER-04.yaml` |

### Job Test Cases

| Test Case ID | Deskripsi | File |
|-------------|-----------|------|
| TC-JOB-01 | Semua field valid dan data berhasil disimpan | `.maestro/TC-JOB-01.yaml` |
| TC-JOB-02 | Field wajib kosong | `.maestro/TC-JOB-02.yaml` |
| TC-JOB-03 | Job position baru berhasil | `.maestro/TC-JOB-03.yaml` |
| TC-JOB-04 | Duplikasi job position | `.maestro/TC-JOB-04.yaml` |
| TC-JOB-05 | Description 50-300 karakter | `.maestro/TC-JOB-05.yaml` |
| TC-JOB-06 | Description kurang dari 50 karakter | `.maestro/TC-JOB-06.yaml` |
| TC-JOB-07 | Company description 150 karakter | `.maestro/TC-JOB-07.yaml` |
| TC-JOB-08 | Company description lebih dari 150 karakter | `.maestro/TC-JOB-08.yaml` |

## 🚀 Cara Menjalankan Testing

### Unit Testing (Codelab)

```bash
# Jalankan semua unit test
flutter test

# Jalankan test spesifik
flutter test codelab/unit_testing/login/login_validation_test.dart
flutter test codelab/unit_testing/register/register_validation_test.dart
flutter test codelab/unit_testing/job/job_validation_test.dart
```

### Automated Testing (Maestro)

```bash
# Install Maestro (jika belum)
powershell -ExecutionPolicy Bypass -File maestro-install.ps1

# Jalankan test case spesifik
maestro test .maestro/TC-LOGIN-01.yaml
maestro test .maestro/TC-REGISTER-01.yaml
maestro test .maestro/TC-JOB-01.yaml

# Jalankan semua test
maestro test .maestro/
```

### Integration Testing (Existing)

```bash
# Jalankan integration test
flutter test integration_test/login_flow_test.dart
```

## 📖 Panduan Gaya Bahasa

Semua comment dalam file demo menggunakan **bahasa sederhana** yang mudah dipahami:

✅ **Good:**
```yaml
# Buka aplikasi
# Tunggu aplikasi siap
# Isi email yang valid
# Klik tombol Login
```

❌ **Avoid:**
```yaml
# Initialize application instance
# Wait for application initialization completion
# Input valid email address credentials
# Execute login button click event
```

## 🎓 Untuk Pembelajaran

## 🎓 Untuk Pembelajaran

File di folder `codelab/` didesain untuk:
- Memahami struktur unit testing di Flutter
- Belajar validasi form dan input
- Mempelajari testing dengan mock Firebase
- Memahami test-driven development (TDD)

## 🤖 Untuk Automated Testing

File di folder `.maestro/` didesain untuk:
- Automated testing dengan Maestro
- Validasi end-to-end flow aplikasi
- Testing yang sudah diverifikasi manual
- 16 test case sesuai requirement

- **Flutter Test** - Unit testing framework
- **Maestro** - UI testing automation
- **Mocktail** - Mocking library untuk Dart
- **Firebase Auth & Firestore** - Backend services
- **GetX** - State management

## 📞 Kontak

Untuk pertanyaan atau bantuan terkait testing, silakan hubungi tim PKPL.

---
**Last Updated:** December 2024
