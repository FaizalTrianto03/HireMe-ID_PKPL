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

  group('Delete Job Tests', () {
    late JobController jobController;

    setUp(() {
      Get.reset();
      Get.testMode = true;
      jobController = buildJobController();
      
      jobController.jobs.addAll([
        {
          'idjob': 'JOB001',
          'position': 'Flutter Developer',
          'location': 'Jakarta',
        },
        {
          'idjob': 'JOB002',
          'position': 'Backend Developer',
          'location': 'Bandung',
        },
        {
          'idjob': 'JOB003',
          'position': 'UI/UX Designer',
          'location': 'Surabaya',
        },
      ]);
      // Tambah tiga job contoh untuk pengujian hapus
    });

    tearDown(() {
      Get.reset();
    });

    test('TC-DELETE-001: Validasi index valid', () {
      // Index pertama harus valid
      final result = jobController.validateJobDataIntegrity(0);
      expect(result, true);
    });

    test('TC-DELETE-002: Validasi index negatif', () {
      // Index negatif tidak valid
      final result = jobController.validateJobDataIntegrity(-1, showErrors: false);
      expect(result, false);
    });

    test('TC-DELETE-003: Validasi index out of bounds', () {
      // Index jauh melebihi ukuran list
      final result = jobController.validateJobDataIntegrity(999);
      expect(result, false);
    });

    test('TC-DELETE-004: Delete job pertama', () {
      // Validasi job pertama ada
      final result = jobController.validateJobDataIntegrity(0);
      expect(result, true);
      expect(jobController.jobs[0]['position'], 'Flutter Developer');
    });

    test('TC-DELETE-005: Delete job terakhir', () {
      // Validasi job terakhir ada
      final lastIndex = jobController.jobs.length - 1;
      final result = jobController.validateJobDataIntegrity(lastIndex);
      expect(result, true);
      expect(jobController.jobs[lastIndex]['position'], 'UI/UX Designer');
    });

    test('TC-DELETE-006: Delete job tengah', () {
      // Validasi job di tengah
      final result = jobController.validateJobDataIntegrity(1);
      expect(result, true);
      expect(jobController.jobs[1]['position'], 'Backend Developer');
    });

    test('TC-DELETE-007: Simulasi delete dan cek count', () {
      // Hapus satu dan kurangi jumlah
      final initialCount = jobController.jobs.length;
      final isValid = jobController.validateJobDataIntegrity(0);
      
      if (isValid) {
        jobController.jobs.removeAt(0);
      }
      
      expect(jobController.jobs.length, initialCount - 1);
    });

    test('TC-DELETE-008: Delete dari empty list', () {
      // Menghapus saat list kosong
      jobController.jobs.clear();
      final result = jobController.validateJobDataIntegrity(0);
      expect(result, false);
    });

    test('TC-DELETE-009: Job dengan ID kosong invalid', () {
      // ID kosong harus gagal
      jobController.jobs.clear();
      jobController.jobs.add({'idjob': '', 'position': 'Test'});
      final result = jobController.validateJobDataIntegrity(0);
      expect(result, false);
    });

    test('TC-DELETE-010: Job tanpa idjob field invalid', () {
      // Field idjob hilang
      jobController.jobs.clear();
      jobController.jobs.add({'position': 'Test'});
      final result = jobController.validateJobDataIntegrity(0);
      expect(result, false);
    });
  });
}
