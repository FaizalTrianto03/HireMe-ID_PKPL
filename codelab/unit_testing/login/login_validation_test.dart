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

  group('Login Email Format Validation', () {
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
      const email = 'user@example.com';
      
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

    test('Email tanpa @ harus gagal validasi', () {
      // Data uji
      const email = 'userexample.com';
      
      // Jalankan validasi
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Cek hasil
      expect(result, false, reason: 'Email without @ should be invalid');
    });

    test('Email tanpa domain harus gagal validasi', () {
      // Data uji
      const email = 'user@';
      
      // Jalankan validasi
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Cek hasil
      expect(result, false, reason: 'Email without domain should be invalid');
    });

    test('Email tanpa username harus gagal validasi', () {
      // Data uji
      const email = '@example.com';
      
      // Jalankan validasi
      final result = authController.validateEmailFormat(email, showErrors: false);
      
      // Cek hasil
      expect(result, false, reason: 'Email without username should be invalid');
    });
  });

  group('Login Password Validation', () {
    late AuthController authController;

    setUp(() {
      Get.reset();
      authController = buildAuthController();
    });

    tearDown(() {
      Get.reset();
    });

    test('Password valid minimal 6 karakter harus lolos', () {
      // Data uji
      const password = 'pass123';
      
      // Jalankan validasi
      final result = authController.validatePasswordStrength(password, showErrors: false);
      
      // Cek hasil
      expect(result, true, reason: 'Password with 6+ characters should be valid');
    });

    test('Password kosong harus gagal validasi', () {
      // Data uji
      const password = '';
      
      // Jalankan validasi
      final result = authController.validatePasswordStrength(password, showErrors: false);
      
      // Cek hasil
      expect(result, false, reason: 'Empty password should be invalid');
    });

    test('Password kurang dari 6 karakter harus gagal', () {
      // Data uji
      const password = 'pass1';
      
      // Jalankan validasi
      final result = authController.validatePasswordStrength(password, showErrors: false);
      
      // Cek hasil
      expect(result, false, reason: 'Password with less than 6 characters should be invalid');
    });

    test('Password tepat 6 karakter harus lolos', () {
      // Data uji
      const password = 'pass12';
      
      // Jalankan validasi
      final result = authController.validatePasswordStrength(password, showErrors: false);
      
      // Cek hasil
      expect(result, true, reason: 'Password with exactly 6 characters should be valid');
    });
  });

  group('Login Role Validation', () {
    late AuthController authController;

    setUp(() {
      Get.reset();
      authController = buildAuthController();
    });

    tearDown(() {
      Get.reset();
    });

    test('Role jobseeker harus valid', () {
      // Data uji
      const role = 'jobseeker';
      
      // Jalankan validasi
      final result = authController.validateRoleSelection(role, showErrors: false);
      
      // Cek hasil
      expect(result, true, reason: 'Jobseeker role should be valid');
    });

    test('Role recruiter harus valid', () {
      // Data uji
      const role = 'recruiter';
      
      // Jalankan validasi
      final result = authController.validateRoleSelection(role, showErrors: false);
      
      // Cek hasil
      expect(result, true, reason: 'Recruiter role should be valid');
    });

    test('Role admin tidak boleh untuk registrasi biasa', () {
      // Data uji
      const role = 'admin';
      
      // Jalankan validasi
      final result = authController.validateRoleSelection(role, showErrors: false);
      
      // Cek hasil
      expect(result, false, reason: 'Admin role should not be allowed');
    });

    test('Role kosong harus gagal validasi', () {
      // Data uji
      const role = '';
      
      // Jalankan validasi
      final result = authController.validateRoleSelection(role, showErrors: false);
      
      // Cek hasil
      expect(result, false, reason: 'Empty role should be invalid');
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
}
