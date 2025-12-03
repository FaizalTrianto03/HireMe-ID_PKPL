import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:HireMe_Id/recruiter/explore/controllers/job_controller.dart';
import 'package:mocktail/mocktail.dart';

// Mock class untuk Firebase
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

// Helper untuk membuat controller
JobController buildJobController() {
  return JobController(
    firebaseAuth: MockFirebaseAuth(),
    firebaseFirestore: MockFirebaseFirestore(),
    skipInit: true,
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.testMode = true;
  });

  group('Job Position Validation', () {
    late JobController jobController;

    setUp(() {
      Get.reset();
      jobController = buildJobController();
    });

    tearDown(() {
      Get.reset();
    });

    test('Position valid harus lolos validasi', () {
      // Siapkan tanggal valid
      final now = DateTime.now();
      final validStartDate = DateTime(now.year, now.month, now.day + 1);
      final validEndDate = DateTime(now.year, now.month, now.day + 30);

      // Data uji
      const position = 'Flutter Developer';
      
      // Jalankan validasi
      final result = jobController.validateJobRequiredFields(
        position: position,
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 5,000,000 - 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      
      // Cek hasil
      expect(result, true, reason: 'Valid position should pass validation');
    });

    test('Position kosong harus gagal validasi', () {
      // Siapkan tanggal valid
      final now = DateTime.now();
      final validStartDate = DateTime(now.year, now.month, now.day + 1);
      final validEndDate = DateTime(now.year, now.month, now.day + 30);

      // Data uji
      const position = '';
      
      // Jalankan validasi
      final result = jobController.validateJobRequiredFields(
        position: position,
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 5,000,000 - 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      
      // Cek hasil
      expect(result, false, reason: 'Empty position should be invalid');
    });

    test('Position kurang dari 3 karakter harus gagal', () {
      // Siapkan tanggal valid
      final now = DateTime.now();
      final validStartDate = DateTime(now.year, now.month, now.day + 1);
      final validEndDate = DateTime(now.year, now.month, now.day + 30);

      // Data uji
      const position = 'AB';
      
      // Jalankan validasi
      final result = jobController.validateJobRequiredFields(
        position: position,
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 5,000,000 - 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      
      // Cek hasil
      expect(result, false, reason: 'Position with less than 3 characters should be invalid');
    });
  });

  group('Job Description Validation', () {
    late JobController jobController;

    setUp(() {
      Get.reset();
      jobController = buildJobController();
    });

    tearDown(() {
      Get.reset();
    });

    test('Description 50 karakter atau lebih harus valid', () {
      // Siapkan tanggal valid
      final now = DateTime.now();
      final validStartDate = DateTime(now.year, now.month, now.day + 1);
      final validEndDate = DateTime(now.year, now.month, now.day + 30);

      // Data uji (tepat 50 karakter)
      const jobDescription = '12345678901234567890123456789012345678901234567890';
      
      // Jalankan validasi
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: jobDescription,
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 5,000,000 - 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      
      // Cek hasil
      expect(result, true, reason: 'Description with 50 characters should be valid');
    });

    test('Description kurang dari 50 karakter harus gagal', () {
      // Siapkan tanggal valid
      final now = DateTime.now();
      final validStartDate = DateTime(now.year, now.month, now.day + 1);
      final validEndDate = DateTime(now.year, now.month, now.day + 30);

      // Data uji (kurang dari 50 karakter)
      const jobDescription = 'Short description';
      
      // Jalankan validasi
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: jobDescription,
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 5,000,000 - 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      
      // Cek hasil
      expect(result, false, reason: 'Description with less than 50 characters should be invalid');
    });
  });

  group('Company Description Validation', () {
    late JobController jobController;

    setUp(() {
      Get.reset();
      jobController = buildJobController();
    });

    tearDown(() {
      Get.reset();
    });

    test('Company description 150 karakter atau kurang harus valid', () {
      // Siapkan tanggal valid
      final now = DateTime.now();
      final validStartDate = DateTime(now.year, now.month, now.day + 1);
      final validEndDate = DateTime(now.year, now.month, now.day + 30);

      // Data uji (150 karakter)
      const aboutCompany = 'This is a test company description with exactly one hundred and fifty characters to validate the maximum length allowed for company description field.';
      
      // Jalankan validasi
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 5,000,000 - 10,000,000',
        aboutCompany: aboutCompany,
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      
      // Cek hasil
      expect(result, true, reason: 'Company description with 150 characters should be valid');
    });

    test('Company description lebih dari 150 karakter harus gagal', () {
      // Siapkan tanggal valid
      final now = DateTime.now();
      final validStartDate = DateTime(now.year, now.month, now.day + 1);
      final validEndDate = DateTime(now.year, now.month, now.day + 30);

      // Data uji (151 karakter)
      const aboutCompany = 'This is a test company description with one hundred and fifty one characters to validate that descriptions exceeding the maximum length are rejected properly.';
      
      // Jalankan validasi
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 5,000,000 - 10,000,000',
        aboutCompany: aboutCompany,
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      
      // Cek hasil
      expect(result, false, reason: 'Company description exceeding 150 characters should be invalid');
    });
  });

  group('Job Uniqueness Validation', () {
    late JobController jobController;

    setUp(() {
      Get.reset();
      jobController = buildJobController();
      
      // Tambahkan job yang sudah ada untuk uji duplikasi
      jobController.jobs.add({
        'position': 'Mobile Engineer',
        'idjob': 'TESTJOB001',
      });
    });

    tearDown(() {
      Get.reset();
    });

    test('Position baru yang unik harus lolos validasi', () {
      // Data uji (position baru)
      const position = 'Backend Developer';
      
      // Jalankan validasi
      final result = jobController.validateJobUniqueness(position, showErrors: false);
      
      // Cek hasil
      expect(result, true, reason: 'Unique job position should be accepted');
    });

    test('Position yang sudah ada harus gagal validasi', () {
      // Data uji (position yang sudah ada)
      const position = 'Mobile Engineer';
      
      // Jalankan validasi
      final result = jobController.validateJobUniqueness(position, showErrors: false);
      
      // Cek hasil
      expect(result, false, reason: 'Duplicate job position should be rejected');
    });

    test('Position duplikat dengan huruf besar kecil berbeda harus gagal', () {
      // Data uji (case berbeda tapi sama)
      const position = 'MOBILE ENGINEER';
      
      // Jalankan validasi
      final result = jobController.validateJobUniqueness(position, showErrors: false);
      
      // Cek hasil
      expect(result, false, reason: 'Case insensitive duplicate should be rejected');
    });
  });
}
