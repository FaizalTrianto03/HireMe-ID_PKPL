import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:HireMe_Id/recruiter/explore/controllers/job_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

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
  });

  group('White-Box Testing: validateJobRequiredFields()', () {
    late JobController jobController;
    late DateTime validStartDate;
    late DateTime validEndDate;

    setUp(() {
      Get.reset();
      jobController = buildJobController();
      
      final now = DateTime.now();
      validStartDate = DateTime(now.year, now.month, now.day + 1);
      validEndDate = DateTime(now.year, now.month, now.day + 30);
    });

    tearDown(() {
      Get.reset();
    });

    // Uji STATEMENT COVERAGE
    // S1: cek position kosong
    test('TC-ST-01: Position kosong (Statement S1)', () {
      final result = jobController.validateJobRequiredFields(
        position: '',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false, // No snackbar in tests!
      );
      expect(result, false);
    });

    // S2: cek panjang position < 3
    test('TC-ST-02: Position kurang dari 3 karakter (Statement S2)', () {
      final result = jobController.validateJobRequiredFields(
        position: 'AB',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      expect(result, false);
    });

    // S3: cek location kosong
    test('TC-ST-03: Location kosong (Statement S3)', () {
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: '',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      expect(result, false);
    });

    // S4: cek jobType kosong
    test('TC-ST-04: JobType kosong (Statement S4)', () {
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: '',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      expect(result, false);
    });

    // S5: cek categories kosong
    test('TC-ST-05: Categories kosong (Statement S5)', () {
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: [],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      expect(result, false);
    });

    // S6: cek deskripsi < 50 karakter
    test('TC-ST-06: JobDescription kurang dari 50 karakter (Statement S6)', () {
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: 'Short',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      expect(result, false);
    });

    // S7: cek requirements kosong
    test('TC-ST-07: Requirements kosong (Statement S7)', () {
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: [],
        facilities: ['Health Insurance'],
        salary: 'IDR 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      expect(result, false);
    });

    // S8: cek salary kosong
    test('TC-ST-08: Salary kosong (Statement S8)', () {
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: '',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      expect(result, false);
    });

    // S9: cek startDate null
    test('TC-ST-09: StartDate null (Statement S9)', () {
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: null,
        endDate: validEndDate,
        showErrors: false,
      );
      expect(result, false);
    });

    // S10: cek website invalid
    test('TC-ST-10: Website invalid (Statement S10)', () {
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'invalid',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      expect(result, false);
    });

    // Uji BRANCH COVERAGE
    // B1: branch position kosong (TRUE)
    test('TC-BR-01: Branch position isEmpty = true', () {
      final result = jobController.validateJobRequiredFields(
        position: '',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      expect(result, false);
    });

    // B2: branch position tidak kosong (FALSE)
    test('TC-BR-02: Branch position isEmpty = false', () {
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      expect(result, true);
    });

    // B3: jobType tidak ada di daftar (TRUE)
    test('TC-BR-03: Branch invalid jobType = true', () {
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Internship',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      expect(result, false);
    });

    // B4: categories lebih dari 5 (TRUE)
    test('TC-BR-04: Branch categories > 5 = true', () {
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT', 'Mobile', 'Software', 'Development', 'Flutter', 'Dart'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      expect(result, false);
    });

    // B5: startDate sebelum hari ini (TRUE)
    test('TC-BR-05: Branch startDate before today = true', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: pastDate,
        endDate: validEndDate,
        showErrors: false,
      );
      expect(result, false);
    });

    // Tes lengkap semua validasi lolos
    test('TC-ALL-PASS: Semua validasi berhasil', () {
      final result = jobController.validateJobRequiredFields(
        position: 'Senior Flutter Developer',
        location: 'Jakarta Selatan',
        jobType: 'Full-time',
        categories: ['IT', 'Mobile Development'],
        jobDescription: 'We are seeking an experienced Flutter developer to join our team and build amazing applications',
        requirements: ['5+ years Flutter experience', 'Strong Dart knowledge'],
        facilities: ['Health Insurance', 'Remote Work'],
        salary: 'IDR 15,000,000 - 20,000,000',
        aboutCompany: 'Leading technology company focused on mobile innovation',
        industry: 'Information Technology',
        website: 'www.techcompany.com',
        companyGalleryPaths: ['office1.jpg', 'office2.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );
      expect(result, true);
    });
  });
}
