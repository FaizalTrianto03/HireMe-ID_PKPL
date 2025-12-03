import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:HireMe_Id/auth/controllers/auth_controller.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes 
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

// Controller helper factory untuk test (skip auto load SharedPreferences)
AuthController buildAuthController() {
  return AuthController(
    firebaseAuth: MockFirebaseAuth(),
    firestore: MockFirebaseFirestore(),
    skipAutoLoad: true,
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.testMode = true;
  });

  group('Login Email Format Validation Tests', () {
    late AuthController authController;

    setUp(() {
      Get.reset();
      authController = buildAuthController();
    });

    tearDown(() {
      Get.reset();
    });

    test('TC-LOGIN-001: Login dengan email valid', () {
      // Siapkan data uji
      const email = 'user@example.com';
      
      // Jalankan fungsi validasi email
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Verifikasi hasil (reason tetap Inggris)
      expect(result, true, reason: 'Valid email should pass validation');
    });

    test('TC-LOGIN-002: Login dengan email kosong (negative test)', () {
      // Email kosong
      const email = '';
      
      // Validasi email
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Verifikasi gagal
      expect(result, false, reason: 'Empty email should be invalid');
    });

    test('TC-LOGIN-003: Login dengan email tanpa @ (negative test)', () {
      // Email tanpa simbol @
      const email = 'userexample.com';
      
      // Validasi email
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Verifikasi gagal
      expect(result, false, reason: 'Email without @ should be invalid');
    });

    test('TC-LOGIN-004: Login dengan email tanpa domain (negative test)', () {
      // Email tanpa domain
      const email = 'user@';
      
      // Validasi email
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Verifikasi gagal
      expect(result, false, reason: 'Email without domain should be invalid');
    });

    test('TC-LOGIN-005: Login dengan email tanpa username (negative test)', () {
      // Email tanpa username
      const email = '@example.com';
      
      // Validasi email
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Verifikasi gagal
      expect(result, false, reason: 'Email without username should be invalid');
    });
  });

  group('Login Password Validation Tests', () {
    late AuthController authController;

    setUp(() {
      Get.reset();
      authController = buildAuthController();
    });

    tearDown(() {
      Get.reset();
    });

    test('TC-PASS-001: Login dengan password valid (minimal 6 karakter)', () {
      // Password panjang cukup
      const password = 'pass123';
      
      // Validasi password
      final result = authController.validatePasswordStrength(password, showErrors: false);
      
      // Verifikasi lolos
      expect(result, true, reason: 'Password with 6+ characters should be valid for login');
    });

    test('TC-PASS-002: Login dengan password kosong (negative test)', () {
      // Password kosong
      const password = '';
      
      // Validasi password
      final result = authController.validatePasswordStrength(password, showErrors: false);
      
      // Verifikasi gagal
      expect(result, false, reason: 'Empty password should be invalid');
    });

    test('TC-PASS-003: Login dengan password kurang dari 6 karakter (negative test)', () {
      // Kurang dari batas minimal
      const password = 'pass1'; // 5 characters
      
      // Validasi password
      final result = authController.validatePasswordStrength(password, showErrors: false);
      
      // Verifikasi gagal
      expect(result, false, reason: 'Password with less than 6 characters should be invalid');
    });

    test('TC-PASS-004: Login dengan password tepat 6 karakter (boundary test)', () {
      // Batas bawah valid
      const password = 'pass12'; // Exactly 6 characters
      
      // Validasi password
      final result = authController.validatePasswordStrength(password, showErrors: false);
      
      // Verifikasi lolos
      expect(result, true, reason: 'Password with exactly 6 characters should be valid');
    });

    test('TC-PASS-005: Login dengan password panjang', () {
      // Password panjang
      const password = 'ThisIsAVeryLongPasswordForTesting123456';
      
      // Validasi password
      final result = authController.validatePasswordStrength(password, showErrors: false);
      
      // Verifikasi lolos
      expect(result, true, reason: 'Long password should be valid');
    });
  });

  group('Login Role Validation Tests', () {
    late AuthController authController;

    setUp(() {
      Get.reset();
      authController = buildAuthController();
    });

    tearDown(() {
      Get.reset();
    });

    test('TC-ROLE-001: Validasi role jobseeker', () {
      // Role jobseeker valid
      const role = 'jobseeker';
      
      // Validasi role
      final result = authController.validateRoleSelection(role, showErrors: false);
      
      // Verifikasi lolos
      expect(result, true, reason: 'Jobseeker role should be valid');
    });

    test('TC-ROLE-002: Validasi role recruiter', () {
      // Role recruiter valid
      const role = 'recruiter';
      
      // Validasi role
      final result = authController.validateRoleSelection(role, showErrors: false);
      
      // Verifikasi lolos
      expect(result, true, reason: 'Recruiter role should be valid');
    });

    test('TC-ROLE-003: Validasi role admin (negative test)', () {
      // Role tidak diizinkan
      const role = 'admin';
      
      // Validasi role
      final result = authController.validateRoleSelection(role, showErrors: false);
      
      // Verifikasi gagal
      expect(result, false, reason: 'Admin role should not be allowed for regular login registration');
    });

    test('TC-ROLE-004: Validasi role kosong (negative test)', () {
      // Role kosong
      const role = '';
      
      // Validasi role
      final result = authController.validateRoleSelection(role, showErrors: false);
      
      // Verifikasi gagal
      expect(result, false, reason: 'Empty role should be invalid');
    });

    test('TC-ROLE-005: Validasi role invalid (negative test)', () {
      // Role tidak dikenal
      const role = 'superuser';
      
      // Validasi role
      final result = authController.validateRoleSelection(role, showErrors: false);
      
      // Verifikasi gagal
      expect(result, false, reason: 'Invalid role should be rejected');
    });
  });

  group('Edge Cases Tests', () {
    late AuthController authController;

    setUp(() {
      Get.reset();
      authController = buildAuthController();
    });

    tearDown(() {
      Get.reset();
    });

    test('TC-EDGE-001: Email dengan spasi di awal dan akhir', () {
      // Email memiliki spasi awal/akhir
      const email = '  user@test.com  ';
      
      // Validasi email
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Verifikasi lolos
      expect(result, true, reason: 'Email with leading/trailing spaces should be trimmed and validated');
    });

    test('TC-EDGE-002: Email dengan huruf besar', () {
      // Email huruf besar
      const email = 'USER@TEST.COM';
      
      // Validasi email
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Verifikasi lolos
      expect(result, true, reason: 'Email with uppercase letters should be valid');
    });

    test('TC-EDGE-003: Email dengan angka dan karakter khusus', () {
      // Format email kompleks
      const email = 'user.name+tag123@example-company.com';
      
      // Validasi email
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Verifikasi lolos
      expect(result, true, reason: 'Email with numbers and special chars should be valid');
    });

    test('TC-EDGE-004: Password dengan spasi', () {
      // Password mengandung spasi
      const password = 'pass word';
      
      // Validasi password
      final result = authController.validatePasswordStrength(password, showErrors: false);
      
      // Verifikasi lolos
      expect(result, true, reason: 'Password with spaces should be valid if length >= 6');
    });

    test('TC-EDGE-005: Password dengan karakter spesial', () {
      // Password karakter spesial
      const password = 'p@ssw0rd!';
      
      // Validasi password
      final result = authController.validatePasswordStrength(password, showErrors: false);
      
      // Verifikasi lolos
      expect(result, true, reason: 'Password with special characters should be valid');
    });

    test('TC-EDGE-006: Email dengan multiple dots dalam domain', () {
      // Domain bertingkat
      const email = 'user@mail.company.co.id';
      
      // Validasi email
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Verifikasi lolos
      expect(result, true, reason: 'Email with multiple dots in domain should be valid');
    });

    test('TC-EDGE-007: Email dengan underscore', () {
      // Email underscore
      const email = 'user_name@test.com';
      
      // Validasi email
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Verifikasi lolos
      expect(result, true, reason: 'Email with underscore should be valid');
    });

    test('TC-EDGE-008: Password dengan hanya angka', () {
      // Password hanya angka
      const password = '123456';
      
      // Validasi password
      final result = authController.validatePasswordStrength(password, showErrors: false);
      
      // Verifikasi lolos
      expect(result, true, reason: 'Password with only numbers should be valid for login (not registration)');
    });
  });

  group('Integration Tests - Full Login Flow Validation', () {
    late AuthController authController;

    setUp(() {
      Get.reset();
      authController = buildAuthController();
    });

    tearDown(() {
      Get.reset();
    });

    test('TC-INT-LOGIN-001: Full validation flow dengan credentials valid', () {
      // Kredensial valid lengkap
      const email = 'jobseeker@test.com';
      // Gunakan password langsung di pemanggilan agar tidak unused variable
      final emailValid = authController.validateEmailFormat(email, showErrors: false);
      expect(emailValid, true, reason: 'Step 1: Email validation should pass');
      final passwordValid = authController.validatePasswordStrength('password123', showErrors: false);
      expect(passwordValid, true, reason: 'Step 2: Password validation should pass');
    });

    test('TC-INT-LOGIN-002: Login validation failure pada email invalid', () {
      // Email invalid
      const email = 'invalidemail';
      const password = 'password123';
      
      // Validasi email
      final emailValid = authController.validateEmailFormat(email, showErrors: false);
      
      // Gagal pada langkah email
      expect(emailValid, false, reason: 'Login should fail at email validation step');
    });

    test('TC-INT-LOGIN-003: Login validation failure pada password invalid', () {
      // Password terlalu pendek
      const email = 'valid@test.com';
      const password = 'pass'; // Too short
      
      // Validasi email & password
      final emailValid = authController.validateEmailFormat(email, showErrors: false);
      final passwordValid = authController.validatePasswordStrength(password, showErrors: false);
      
      // Email pass, password fail
      expect(emailValid, true, reason: 'Email validation should pass');
      expect(passwordValid, false, reason: 'Login should fail at password validation step');
    });

    test('TC-INT-LOGIN-004: Login validation dengan berbagai format email valid', () {
      // Daftar email valid
      final validEmails = [
        'user@example.com',
        'test.user@company.co.id',
        'admin123@test-server.org',
        'user+tag@mail.com',
      ];
      
      // Validasi setiap email
      for (final email in validEmails) {
        final result = authController.validateEmailFormat(email, showErrors: false);
        expect(result, true, reason: 'Email "$email" should be valid');
      }
    });

    test('TC-INT-LOGIN-005: Login validation dengan berbagai password valid', () {
      // Daftar password valid
      final validPasswords = [
        'password123',
        'P@ssw0rd!',
        'simple',
        '123456',
        'VeryLongPasswordWithManyCharacters',
      ];
      
      // Validasi setiap password
      for (final password in validPasswords) {
        final result = authController.validatePasswordStrength(password, showErrors: false);
        expect(result, true, reason: 'Password "$password" should be valid for login');
      }
    });

    test('TC-INT-LOGIN-006: Sequential validation untuk login flow', () {
      // Data login valid
      const email = 'recruiter@company.com';
      const password = 'recruit123';
      
      var validationStep = 0;
      
      // Langkah 1: email
      final emailValid = authController.validateEmailFormat(email, showErrors: false);
      if (emailValid) validationStep = 1;
      expect(validationStep, 1, reason: 'Should progress to step 1 after email validation');
      
      // Langkah 2: password
      final passwordValid = authController.validatePasswordStrength(password, showErrors: false);
      if (passwordValid) validationStep = 2;
      expect(validationStep, 2, reason: 'Should progress to step 2 after password validation');
      
      // Final sukses
      expect(emailValid && passwordValid, true, 
        reason: 'Both validations should pass for successful login');
    });
  });

  group('Boundary Tests', () {
    late AuthController authController;

    setUp(() {
      Get.reset();
      authController = buildAuthController();
    });

    tearDown(() {
      Get.reset();
    });

    test('TC-BOUND-001: Password dengan panjang 5 karakter (boundary - invalid)', () {
      // Password panjang 5
      const password = '12345';
      
      // Validasi password
      final result = authController.validatePasswordStrength(password, showErrors: false);
      
      // Harus gagal
      expect(result, false, reason: 'Password with 5 characters should be invalid');
    });

    test('TC-BOUND-002: Password dengan panjang 6 karakter (boundary - valid)', () {
      // Password panjang 6
      const password = '123456';
      
      // Validasi password
      final result = authController.validatePasswordStrength(password, showErrors: false);
      
      // Harus lolos
      expect(result, true, reason: 'Password with 6 characters should be valid');
    });

    test('TC-BOUND-003: Email dengan TLD minimal 2 karakter', () {
      // TLD dua huruf
      const email = 'user@test.co';
      
      // Validasi email
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Lolos
      expect(result, true, reason: 'Email with 2-character TLD should be valid');
    });

    test('TC-BOUND-004: Email dengan TLD 1 karakter (invalid)', () {
      // TLD satu huruf
      const email = 'user@test.c';
      
      // Validasi email
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Gagal
      expect(result, false, reason: 'Email with 1-character TLD should be invalid');
    });
  });

  group('Special Characters Tests', () {
    late AuthController authController;

    setUp(() {
      Get.reset();
      authController = buildAuthController();
    });

    tearDown(() {
      Get.reset();
    });

    test('TC-SPECIAL-001: Email dengan dots', () {
      // Email mengandung titik
      const email = 'first.last@example.com';
      
      // Validasi email
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Lolos
      expect(result, true, reason: 'Email with dots should be valid');
    });

    test('TC-SPECIAL-002: Email dengan plus sign', () {
      // Email dengan plus
      const email = 'user+tag@example.com';
      
      // Validasi email
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Lolos
      expect(result, true, reason: 'Email with plus sign should be valid');
    });

    test('TC-SPECIAL-003: Email dengan hyphen dalam domain', () {
      // Email dengan hyphen
      const email = 'user@test-company.com';
      
      // Validasi email
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Lolos
      expect(result, true, reason: 'Email with hyphen in domain should be valid');
    });

    test('TC-SPECIAL-004: Password dengan semua karakter spesial umum', () {
      // Password banyak simbol (escape $)
      const password = '!@#\$%^&*()';
      
      // Validasi password
      final result = authController.validatePasswordStrength(password, showErrors: false);
      
      // Lolos
      expect(result, true, reason: 'Password with special characters should be valid if length >= 6');
    });
  });
}
