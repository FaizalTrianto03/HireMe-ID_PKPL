import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:HireMe_Id/recruiter/explore/controllers/job_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.testMode = true;
  });

  JobController buildJobController() {
    return JobController(
      firebaseAuth: MockFirebaseAuth(),
      firebaseFirestore: MockFirebaseFirestore(),
      skipInit: true,
    );
  }

  group('Update Job Tests', () {
    late JobController jobController;
    late DateTime validStartDate;
    late DateTime validEndDate;

    setUp(() {
      Get.reset();
      Get.testMode = true;
      jobController = buildJobController();
      
      final now = DateTime.now();
      validStartDate = DateTime(now.year, now.month, now.day + 1);
      validEndDate = DateTime(now.year, now.month, now.day + 30);
      
      jobController.jobs.addAll([
        {
          'idjob': 'JOB001',
          'position': 'Flutter Developer',
          'location': 'Jakarta',
          'jobType': 'Full-time',
          'categories': ['IT'],
          'salary': 'IDR 10,000,000',
          'startDate': validStartDate.toIso8601String(),
          'endDate': validEndDate.toIso8601String(),
          'jobDetails': {
            'jobDescription': 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
            'requirements': ['Flutter experience'],
            'facilities': ['Health Insurance'],
            'companyDetails': {
              'aboutCompany': 'Innovative tech company building future',
              'industry': 'Technology',
              'website': 'www.company.com',
              'companyGalleryPaths': ['image1.jpg'],
            },
          },
        },
        {
          'idjob': 'JOB002',
          'position': 'Backend Developer',
          'location': 'Bandung',
        },
      ]);
      // Tambah dua job awal untuk skenario update
    });

    tearDown(() {
      Get.reset();
    });

    test('TC-UPDATE-001: Validasi job index valid', () {
      // Index pertama valid
      final result = jobController.validateJobDataIntegrity(0);
      expect(result, true);
    });

    test('TC-UPDATE-002: Validasi job index negatif', () {
      // Index negatif harus gagal
      final result = jobController.validateJobDataIntegrity(-1, showErrors: false);
      expect(result, false);
    });

    test('TC-UPDATE-003: Validasi job index melebihi batas', () {
      // Index jauh melebihi panjang list
      final result = jobController.validateJobDataIntegrity(999);
      expect(result, false);
    });

    test('TC-UPDATE-004: Update position unik', () {
      // Ubah jadi posisi unik baru
      final result = jobController.validateJobUniqueness(
        'Senior Flutter Developer',
        excludeJobIndex: 0
      );
      expect(result, true);
    });

    test('TC-UPDATE-005: Update position duplikat', () {
      // Posisi sudah dipakai job lain
      final result = jobController.validateJobUniqueness(
        'Backend Developer',
        excludeJobIndex: 0
      );
      expect(result, false);
    });

    test('TC-UPDATE-006: Update semua field valid', () {
      // Semua field perubahan valid
      final result = jobController.validateJobRequiredFields(
        position: 'Senior Flutter Developer',
        location: 'Jakarta Selatan',
        jobType: 'Full-time',
        categories: ['IT', 'Mobile'],
        jobDescription: 'Looking for senior developer with Flutter expertise to lead mobile development',
        requirements: ['5+ years experience', 'Flutter expert'],
        facilities: ['Health Insurance', 'Remote Work'],
        salary: 'IDR 15,000,000 - 20,000,000',
        aboutCompany: 'Leading technology company in Indonesia',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg', 'image2.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      expect(result, true);
    });

    test('TC-UPDATE-007: Job dengan ID kosong invalid', () {
      // ID kosong harus gagal
      jobController.jobs.clear();
      jobController.jobs.add({'idjob': '', 'position': 'Test'});
      final result = jobController.validateJobDataIntegrity(0);
      expect(result, false);
    });

    test('TC-UPDATE-008: Job dengan ID null invalid', () {
      // Field idjob hilang
      jobController.jobs.clear();
      jobController.jobs.add({'position': 'Test'});
      final result = jobController.validateJobDataIntegrity(0);
      expect(result, false);
    });
  });
}
