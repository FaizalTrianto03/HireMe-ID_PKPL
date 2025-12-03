# Codelab - Unit Testing Guide

Panduan pembelajaran untuk memahami dan menulis unit test di Flutter.

## 📚 Pengenalan

Unit testing adalah proses testing yang fokus pada pengujian komponen individual dalam aplikasi. Di folder ini, kita telah mengorganisir unit test berdasarkan fitur untuk memudahkan pembelajaran.

## 🎯 Tujuan Pembelajaran

Setelah mempelajari codelab ini, Anda akan mampu:
1. Memahami struktur dasar unit test di Flutter
2. Menulis test untuk validasi form input
3. Menggunakan mock objects untuk testing
4. Memahami konsep positive dan negative testing
5. Membuat test yang mudah dibaca dan di-maintain

## 📁 Struktur Codelab

```
codelab/
└── unit_testing/
    ├── login/
    │   └── login_validation_test.dart
    ├── register/
    │   └── register_validation_test.dart
    └── job/
        └── job_validation_test.dart
```

## 🔍 Penjelasan Per Modul

### 1. Login Validation Test

**File:** `unit_testing/login/login_validation_test.dart`

**Apa yang dipelajari:**
- Validasi format email
- Validasi panjang password
- Validasi role selection
- Mock Firebase Authentication

**Contoh Test:**
```dart
test('Email valid harus lolos validasi', () {
  // Siapkan data uji
  const email = 'user@example.com';
  
  // Jalankan fungsi validasi
  final result = authController.validateEmailFormat(email, showErrors: false);
  
  // Cek hasilnya
  expect(result, true, reason: 'Valid email should pass validation');
});
```

**Konsep Penting:**
- Arrange-Act-Assert pattern
- Comment dalam bahasa sederhana
- Penggunaan `expect()` untuk verifikasi
- Parameter `reason` untuk dokumentasi

### 2. Register Validation Test

**File:** `unit_testing/register/register_validation_test.dart`

**Apa yang dipelajari:**
- Password strength validation (minimal 8 karakter, harus ada huruf dan angka)
- Email uniqueness check
- Role validation untuk pendaftaran
- Integration flow testing

**Contoh Test:**
```dart
test('Password kurang dari 8 karakter harus gagal', () {
  // Siapkan password pendek
  const password = 'Pass123';
  
  // Validasi untuk registrasi
  final result = authController.validatePasswordStrength(
    password, 
    isRegistration: true,
    showErrors: false
  );
  
  // Harus gagal
  expect(result, false, reason: 'Password with less than 8 characters should be invalid');
});
```

**Konsep Penting:**
- Negative testing (test kasus yang harus gagal)
- Boundary testing (test di batas minimum/maksimum)
- Testing dengan multiple conditions

### 3. Job Validation Test

**File:** `unit_testing/job/job_validation_test.dart`

**Apa yang dipelajari:**
- Validasi multiple fields
- String length validation (min/max)
- Uniqueness validation
- DateTime validation

**Contoh Test:**
```dart
test('Description 50 karakter atau lebih harus valid', () {
  // Siapkan tanggal valid
  final now = DateTime.now();
  final validStartDate = DateTime(now.year, now.month, now.day + 1);
  final validEndDate = DateTime(now.year, now.month, now.day + 30);

  // Description tepat 50 karakter
  const jobDescription = '12345678901234567890123456789012345678901234567890';
  
  // Jalankan validasi
  final result = jobController.validateJobRequiredFields(
    position: 'Flutter Developer',
    location: 'Jakarta',
    jobType: 'Full-time',
    categories: ['IT'],
    jobDescription: jobDescription,
    // ... field lainnya
    showErrors: false,
  );
  
  // Harus lolos
  expect(result, true, reason: 'Description with 50 characters should be valid');
});
```

**Konsep Penting:**
- Complex validation dengan banyak parameter
- Boundary value testing
- Setup dan teardown untuk test data

## 🧪 Pattern Testing yang Digunakan

### 1. Arrange-Act-Assert (AAA)

```dart
test('Deskripsi test', () {
  // ARRANGE: Siapkan data dan kondisi
  const email = 'test@example.com';
  
  // ACT: Jalankan fungsi yang di-test
  final result = controller.validateEmail(email);
  
  // ASSERT: Verifikasi hasilnya
  expect(result, true);
});
```

### 2. Given-When-Then

```dart
test('Email kosong harus gagal validasi', () {
  // GIVEN: User tidak mengisi email
  const email = '';
  
  // WHEN: Validasi dijalankan
  final result = controller.validateEmail(email);
  
  // THEN: Sistem menolak dengan hasil false
  expect(result, false);
});
```

## ✅ Best Practices

### 1. Naming Convention
```dart
// ✅ Good: Jelas dan deskriptif
test('Email tanpa @ harus gagal validasi', () { });

// ❌ Avoid: Terlalu teknis atau singkat
test('TC001', () { });
test('testEmailValidation', () { });
```

### 2. Comment yang Jelas
```dart
// ✅ Good: Comment sederhana
// Siapkan data uji
// Jalankan validasi
// Cek hasilnya

// ❌ Avoid: Comment terlalu teknis
// Initialize test data structure
// Execute validation method
// Verify return value
```

### 3. Satu Test, Satu Tujuan
```dart
// ✅ Good: Fokus pada satu validasi
test('Email kosong harus gagal', () {
  expect(validate(''), false);
});

// ❌ Avoid: Test banyak hal sekaligus
test('Validasi login', () {
  expect(validateEmail(''), false);
  expect(validatePassword(''), false);
  expect(validateRole(''), false);
});
```

## 🎓 Latihan

### Latihan 1: Email Validation
Buat test untuk validasi:
- Email dengan spasi di depan/belakang
- Email dengan huruf besar/kecil
- Email dengan angka

### Latihan 2: Password Validation
Buat test untuk:
- Password dengan karakter spesial
- Password sangat panjang (>50 karakter)
- Password dengan spasi

### Latihan 3: Job Description Validation
Buat test untuk:
- Description tepat 300 karakter (batas atas)
- Description 301 karakter (melebihi batas)
- Description dengan karakter spesial

## 📖 Referensi

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Mocktail Documentation](https://pub.dev/packages/mocktail)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)

## 🚀 Cara Menjalankan

```bash
# Jalankan semua test di folder login
flutter test codelab/unit_testing/login/

# Jalankan semua test di folder register
flutter test codelab/unit_testing/register/

# Jalankan semua test di folder job
flutter test codelab/unit_testing/job/

# Jalankan semua unit test
flutter test codelab/
```

## 💡 Tips

1. **Mulai dari test sederhana** - Jangan langsung test yang kompleks
2. **Baca error message dengan teliti** - Error message Flutter test sangat informatif
3. **Gunakan `setUp()` dan `tearDown()`** - Untuk inisialisasi dan cleanup
4. **Test positive dan negative case** - Jangan hanya test yang berhasil
5. **Tulis test dulu, kode belakangan** - TDD approach untuk kode yang lebih robust

## 🤝 Kontribusi

Jika Anda menemukan cara testing yang lebih baik atau ingin menambahkan test case baru, silakan diskusikan dengan tim.

---
**Happy Testing! 🧪**
