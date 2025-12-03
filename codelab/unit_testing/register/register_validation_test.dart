import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:HireMe_Id/auth/controllers/auth_controller.dart';
import 'package:mocktail/mocktail.dart';

// Mock class untuk Firebase
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

// Helper untuk membuat controller
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

  group('Register Email Validation', () {
    late AuthController authController;

    setUp(() {
      Get.reset();
      authController = buildAuthController();
    });

    tearDown(() {
      Get.reset();
    });

    test('Email valid harus lolos validasi', () {
      // Data uji
      const email = 'newuser@test.com';
      
      // Jalankan validasi
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Cek hasil
      expect(result, true, reason: 'Valid email should pass validation');
    });

    test('Email kosong harus gagal validasi', () {
      // Data uji
      const email = '';
      
      // Jalankan validasi
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Cek hasil
      expect(result, false, reason: 'Empty email should be invalid');
    });

    test('Email format invalid harus ditolak', () {
      // Daftar email tidak valid
      const invalidEmails = [
        'invalidemail',
        '@example.com',
        'user@',
        'user.example.com',
      ];
      
      // Cek semua email invalid
      for (final email in invalidEmails) {
        final result = authController.validateEmailFormat(email, showErrors: false);
        expect(result, false, reason: 'Invalid email "$email" should be rejected');
      }
    });
  });

  group('Register Password Validation', () {
    late AuthController authController;

    setUp(() {
      Get.reset();
      authController = buildAuthController();
    });

    tearDown(() {
      Get.reset();
    });

    test('Password valid dengan huruf dan angka harus lolos', () {
      // Data uji
      const password = 'Password123';
      
      // Jalankan validasi untuk registrasi
      final result = authController.validatePasswordStrength(
        password, 
        isRegistration: true,
        showErrors: false
      );
      
      // Cek hasil
      expect(result, true, reason: 'Password with letters and numbers should be valid');
    });

    test('Password kurang dari 8 karakter harus gagal', () {
      // Data uji
      const password = 'Pass123';
      
      // Jalankan validasi
      final result = authController.validatePasswordStrength(
        password, 
        isRegistration: true,
        showErrors: false
      );
      
      // Cek hasil
      expect(result, false, reason: 'Password with less than 8 characters should be invalid');
    });

    test('Password tanpa angka harus gagal', () {
      // Data uji
      const password = 'PasswordOnly';
      
      // Jalankan validasi
      final result = authController.validatePasswordStrength(
        password, 
        isRegistration: true,
        showErrors: false
      );
      
      // Cek hasil
      expect(result, false, reason: 'Password without numbers should be invalid');
    });

    test('Password tanpa huruf harus gagal', () {
      // Data uji
      const password = '12345678';
      
      // Jalankan validasi
      final result = authController.validatePasswordStrength(
        password, 
        isRegistration: true,
        showErrors: false
      );
      
      // Cek hasil
      expect(result, false, reason: 'Password without letters should be invalid');
    });

    test('Password minimal 8 karakter dengan huruf dan angka harus lolos', () {
      // Data uji
      const password = 'Pass1234';
      
      // Jalankan validasi
      final result = authController.validatePasswordStrength(
        password, 
        isRegistration: true,
        showErrors: false
      );
      
      // Cek hasil
      expect(result, true, reason: 'Password meeting minimal requirements should be valid');
    });
  });

  group('Register Role Selection Validation', () {
    late AuthController authController;

    setUp(() {
      Get.reset();
      authController = buildAuthController();
    });

    tearDown(() {
      Get.reset();
    });

    test('Role jobseeker harus valid untuk registrasi', () {
      // Data uji
      const role = 'jobseeker';
      
      // Jalankan validasi
      final result = authController.validateRoleSelection(role, showErrors: false);
      
      // Cek hasil
      expect(result, true, reason: 'Jobseeker role should be valid');
    });

    test('Role recruiter harus valid untuk registrasi', () {
      // Data uji
      const role = 'recruiter';
      
      // Jalankan validasi
      final result = authController.validateRoleSelection(role, showErrors: false);
      
      // Cek hasil
      expect(result, true, reason: 'Recruiter role should be valid');
    });

    test('Role kosong harus gagal validasi', () {
      // Data uji
      const role = '';
      
      // Jalankan validasi
      final result = authController.validateRoleSelection(role, showErrors: false);
      
      // Cek hasil
      expect(result, false, reason: 'Empty role should be invalid');
    });

    test('Role admin tidak boleh untuk registrasi', () {
      // Data uji
      const role = 'admin';
      
      // Jalankan validasi
      final result = authController.validateRoleSelection(role, showErrors: false);
      
      // Cek hasil
      expect(result, false, reason: 'Admin role should not be allowed');
    });

    test('Role tidak valid harus ditolak', () {
      // Data uji
      const role = 'superuser';
      
      // Jalankan validasi
      final result = authController.validateRoleSelection(role, showErrors: false);
      
      // Cek hasil
      expect(result, false, reason: 'Invalid role should be rejected');
    });
  });

  group('Register Integration Test', () {
    late AuthController authController;

    setUp(() {
      Get.reset();
      authController = buildAuthController();
    });

    tearDown(() {
      Get.reset();
    });

    test('Flow registrasi lengkap jobseeker harus sukses', () {
      // Data uji lengkap
      const email = 'newjobseeker@test.com';
      const password = 'SecurePass123';
      const role = 'jobseeker';
      
      // Validasi email
      final emailValid = authController.validateEmailFormat(email, showErrors: false);
      expect(emailValid, true, reason: 'Email validation should pass');
      
      // Validasi password
      final passwordValid = authController.validatePasswordStrength(
        password, 
        isRegistration: true,
        showErrors: false
      );
      expect(passwordValid, true, reason: 'Password validation should pass');
      
      // Validasi role
      final roleValid = authController.validateRoleSelection(role, showErrors: false);
      expect(roleValid, true, reason: 'Role validation should pass');
    });

    test('Flow registrasi lengkap recruiter harus sukses', () {
      // Data uji lengkap
      const email = 'newrecruiter@company.com';
      const password = 'Recruiter2024';
      const role = 'recruiter';
      
      // Validasi email
      final emailValid = authController.validateEmailFormat(email, showErrors: false);
      expect(emailValid, true, reason: 'Email validation should pass');
      
      // Validasi password
      final passwordValid = authController.validatePasswordStrength(
        password, 
        isRegistration: true,
        showErrors: false
      );
      expect(passwordValid, true, reason: 'Password validation should pass');
      
      // Validasi role
      final roleValid = authController.validateRoleSelection(role, showErrors: false);
      expect(roleValid, true, reason: 'Role validation should pass');
    });
  });
}
