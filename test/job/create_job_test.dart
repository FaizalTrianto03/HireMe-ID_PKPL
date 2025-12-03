import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:HireMe_Id/recruiter/explore/controllers/job_controller.dart';
import 'package:mocktail/mocktail.dart';

// Kelas mock Firebase (hanya komentar diterjemahkan)
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockUser extends Mock implements User {}
// Mock sealed DocumentReference & DocumentSnapshot dihapus: tidak diperlukan untuk validasi field

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

  group('Create Job - Field Validation Tests', () {
    late JobController jobController;
    late DateTime validStartDate;
    late DateTime validEndDate;

    setUp(() {
      Get.reset();
      jobController = buildJobController();
      
      // Siapkan tanggal valid untuk lowongan
      final now = DateTime.now();
      validStartDate = DateTime(now.year, now.month, now.day + 1);
      validEndDate = DateTime(now.year, now.month, now.day + 30);
    });

    tearDown(() {
      Get.reset();
    });

    test('TC-CREATE-001: Create job dengan semua field valid', () {
      // Data lengkap semua field valid
      final jobData = {
        'position': 'Senior Flutter Developer',
        'location': 'Jakarta, Indonesia',
        'jobType': 'Full-time',
        'categories': ['IT', 'Software Development'],
        'jobDescription': 'We are looking for an experienced Flutter developer to join our dynamic team and work on exciting mobile projects.',
        'requirements': ['3+ years Flutter experience', 'Strong Dart knowledge', 'Experience with Firebase'],
        'facilities': ['Health Insurance', 'Remote Work', 'Annual Bonus'],
        'salary': 'IDR 10,000,000 - 15,000,000',
        'aboutCompany': 'Leading tech company focused on mobile innovation and solutions',
        'industry': 'Information Technology',
        'website': 'www.techcompany.com',
        'companyGalleryPaths': ['path/to/image1.jpg', 'path/to/image2.jpg'],
        'startDate': validStartDate,
        'endDate': validEndDate,
      };

      // Panggil fungsi validasi
      final result = jobController.validateJobRequiredFields(
        position: jobData['position'] as String,
        location: jobData['location'] as String,
        jobType: jobData['jobType'] as String,
        categories: jobData['categories'] as List<String>,
        jobDescription: jobData['jobDescription'] as String,
        requirements: jobData['requirements'] as List<dynamic>,
        facilities: jobData['facilities'] as List<String>,
        salary: jobData['salary'] as String,
        aboutCompany: jobData['aboutCompany'] as String,
        industry: jobData['industry'] as String,
        website: jobData['website'] as String,
        companyGalleryPaths: jobData['companyGalleryPaths'] as List<String>,
        startDate: jobData['startDate'] as DateTime,
        endDate: jobData['endDate'] as DateTime,
        showErrors: false,
      );

      // Verifikasi sukses
      expect(result, true, reason: 'All valid fields should pass validation');
    });

    test('TC-CREATE-002: Create job dengan position kosong (negative)', () {
      // Position kosong
      const position = '';

      // Validasi
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

      // Harus gagal
      expect(result, false, reason: 'Empty position should be invalid');
    });

    test('TC-CREATE-003: Create job dengan position kurang dari 3 karakter (negative)', () {
      // Position terlalu pendek
      const position = 'AB';

      // Validasi
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

      // Harus gagal
      expect(result, false, reason: 'Position with less than 3 characters should be invalid');
    });

    test('TC-CREATE-004: Create job dengan location kosong (negative)', () {
      // Location kosong
      const location = '';

      // Validasi
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: location,
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

      // Harus gagal
      expect(result, false, reason: 'Empty location should be invalid');
    });

    test('TC-CREATE-005: Create job dengan jobType invalid (negative)', () {
      // jobType tidak termasuk daftar diizinkan
      const jobType = 'Internship'; // Not in allowed types

      // Validasi
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: jobType,
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

      // Harus gagal
      expect(result, false, reason: 'Invalid job type should be rejected');
    });

    test('TC-CREATE-006: Create job dengan categories kosong (negative)', () {
      // Daftar kategori kosong
      final categories = <String>[];

      // Validasi
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: categories,
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

      // Harus gagal
      expect(result, false, reason: 'Empty categories should be invalid');
    });

    test('TC-CREATE-007: Create job dengan jobDescription kurang dari 50 karakter (negative)', () {
      // Deskripsi terlalu pendek
      const jobDescription = 'Short description'; // Less than 50 characters

      // Validasi
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

      // Harus gagal
      expect(result, false, reason: 'Job description with less than 50 characters should be invalid');
    });

    test('TC-CREATE-008: Create job dengan requirements kosong (negative)', () {
      // Requirements kosong
      final requirements = <String>[];

      // Validasi
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: requirements,
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

      // Harus gagal
      expect(result, false, reason: 'Empty requirements should be invalid');
    });

    test('TC-CREATE-009: Create job dengan salary kosong (negative)', () {
      // Salary kosong
      const salary = '';

      // Validasi
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: salary,
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: 'www.company.com',
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );

      // Harus gagal
      expect(result, false, reason: 'Empty salary should be invalid');
    });

    test('TC-CREATE-010: Create job dengan website format invalid (negative)', () {
      // Website tidak sesuai pola URL
      const website = 'invalid-url';

      // Validasi
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: ['IT'],
        jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
        requirements: ['Flutter experience'],
        facilities: ['Health Insurance'],
        salary: 'IDR 5,000,000 - 10,000,000',
        aboutCompany: 'Innovative tech company building future',
        industry: 'Technology',
        website: website,
        companyGalleryPaths: ['image1.jpg'],
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );

      // Harus gagal
      expect(result, false, reason: 'Invalid website URL should be rejected');
    });

    test('TC-CREATE-011: Create job dengan startDate sebelum hari ini (negative)', () {
      // startDate lampau
      final invalidStartDate = DateTime.now().subtract(const Duration(days: 1));

      // Validasi
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
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
        startDate: invalidStartDate,
        endDate: validEndDate,
        showErrors: false,
      );

      // Harus gagal
      expect(result, false, reason: 'Start date before today should be invalid');
    });

    test('TC-CREATE-012: Create job dengan endDate sebelum startDate (negative)', () {
      // endDate lebih awal dari startDate
      final invalidEndDate = validStartDate.subtract(const Duration(days: 1));

      // Validasi
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
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
        endDate: invalidEndDate,
        showErrors: false,
      );

      // Harus gagal
      expect(result, false, reason: 'End date before start date should be invalid');
    });

    test('TC-CREATE-013: Create job dengan companyGalleryPaths kosong (negative)', () {
      // Galeri kosong
      final companyGalleryPaths = <String>[];

      // Validasi
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
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
        companyGalleryPaths: companyGalleryPaths,
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );

      // Harus gagal
      expect(result, false, reason: 'Empty company gallery should be invalid');
    });
  });

  group('Create Job - Uniqueness Validation Tests', () {
    late JobController jobController;
    late DateTime validStartDate;
    late DateTime validEndDate;

    setUp(() {
      Get.reset();
      jobController = buildJobController();
      
      final now = DateTime.now();
      validStartDate = DateTime(now.year, now.month, now.day + 1);
      validEndDate = DateTime(now.year, now.month, now.day + 30);
      
      // Tambah satu job awal untuk uji duplikasi
      jobController.jobs.add({
        'position': 'Existing Flutter Developer',
        'idjob': 'TESTJOB001',
      });
    });

    tearDown(() {
      Get.reset();
    });

    test('TC-UNIQUE-001: Create job dengan position yang sudah ada (negative)', () {
      // Position duplikat
      const position = 'Existing Flutter Developer';

      // Validasi unik
      final result = jobController.validateJobUniqueness(position, showErrors: false);

      // Harus gagal
      expect(result, false, reason: 'Duplicate job position should be rejected');
    });

    test('TC-UNIQUE-002: Create job dengan position berbeda (positive)', () {
      // Position baru
      const position = 'Senior Backend Developer';

      // Validasi unik
      final result = jobController.validateJobUniqueness(position, showErrors: false);

      // Harus lolos
      expect(result, true, reason: 'Unique job position should be accepted');
    });

    test('TC-UNIQUE-003: Create job dengan position case insensitive duplicate (negative)', () {
      // Duplikat beda kapital
      const position = 'EXISTING FLUTTER DEVELOPER'; // Same but uppercase

      // Validasi unik
      final result = jobController.validateJobUniqueness(position, showErrors: false);

      // Harus gagal
      expect(result, false, reason: 'Case insensitive duplicate should be rejected');
    });

    test('TC-UNIQUE-004: Create job dengan position yang memiliki spasi ekstra (negative)', () {
      // Duplikat dengan spasi
      const position = '  Existing Flutter Developer  '; // With spaces

      // Validasi unik
      final result = jobController.validateJobUniqueness(position, showErrors: false);

      // Harus gagal
      expect(result, false, reason: 'Position with extra spaces should be trimmed and detected as duplicate');
    });
  });

  group('Create Job - Edge Cases Tests', () {
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

    test('TC-EDGE-001: Create job dengan jobDescription tepat 50 karakter (boundary)', () {
      // Panjang deskripsi tepat batas minimum
      const jobDescription = '12345678901234567890123456789012345678901234567890'; // Exactly 50 chars

      // Validasi
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

      // Harus lolos
      expect(result, true, reason: 'Job description with exactly 50 characters should be valid');
    });

    test('TC-EDGE-002: Create job dengan categories maksimal 5 item (boundary)', () {
      // Jumlah kategori di batas atas
      final categories = ['IT', 'Software', 'Mobile', 'Development', 'Flutter'];

      // Validasi
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: categories,
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

      // Harus lolos
      expect(result, true, reason: '5 categories should be valid (max limit)');
    });

    test('TC-EDGE-003: Create job dengan categories lebih dari 5 item (negative)', () {
      // Jumlah kategori melebihi batas
      final categories = ['IT', 'Software', 'Mobile', 'Development', 'Flutter', 'Dart'];

      // Validasi
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
        location: 'Jakarta',
        jobType: 'Full-time',
        categories: categories,
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

      // Harus gagal
      expect(result, false, reason: 'More than 5 categories should be invalid');
    });

    test('TC-EDGE-004: Create job dengan duration tepat 90 hari (boundary)', () {
      // Durasi maksimum yang diizinkan
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day + 1);
      final end = start.add(const Duration(days: 90));

      // Validasi
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
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
        startDate: start,
        endDate: end,
        showErrors: false,
      );

      // Harus lolos
      expect(result, true, reason: '90 days duration should be valid (max limit)');
    });

    test('TC-EDGE-005: Create job dengan duration lebih dari 90 hari (negative)', () {
      // Durasi melebihi batas
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day + 1);
      final end = start.add(const Duration(days: 91));

      // Validasi
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
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
        startDate: start,
        endDate: end,
        showErrors: false,
      );

      // Harus gagal
      expect(result, false, reason: 'Duration more than 90 days should be invalid');
    });

    test('TC-EDGE-006: Create job dengan website berbagai format valid', () {
      // Beragam format URL valid
      final validWebsites = [
        'www.company.com',
        'https://www.company.com',
        'http://company.com',
        'company.co.id',
      ];

      // Validasi tiap website
      for (final website in validWebsites) {
        final result = jobController.validateJobRequiredFields(
          position: 'Flutter Developer',
          location: 'Jakarta',
          jobType: 'Full-time',
          categories: ['IT'],
          jobDescription: 'A great opportunity for Flutter developers to work on cutting-edge mobile applications',
          requirements: ['Flutter experience'],
          facilities: ['Health Insurance'],
          salary: 'IDR 5,000,000 - 10,000,000',
          aboutCompany: 'Innovative tech company building future',
          industry: 'Technology',
          website: website,
          companyGalleryPaths: ['image1.jpg'],
          startDate: validStartDate,
          endDate: validEndDate,
        showErrors: false,
        );
        expect(result, true, reason: 'Website "$website" should be valid');
      }
    });

    test('TC-EDGE-007: Create job dengan companyGalleryPaths maksimal 10 item', () {
      // Galeri di batas atas 10
      final galleryPaths = List.generate(10, (i) => 'image$i.jpg');

      // Validasi
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
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
        companyGalleryPaths: galleryPaths,
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );

      // Harus lolos
      expect(result, true, reason: '10 gallery images should be valid (max limit)');
    });

    test('TC-EDGE-008: Create job dengan companyGalleryPaths lebih dari 10 (negative)', () {
      // Galeri melebihi batas 10
      final galleryPaths = List.generate(11, (i) => 'image$i.jpg');

      // Validasi
      final result = jobController.validateJobRequiredFields(
        position: 'Flutter Developer',
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
        companyGalleryPaths: galleryPaths,
        startDate: validStartDate,
        endDate: validEndDate,
        showErrors: false,
      );

      // Harus gagal
      expect(result, false, reason: 'More than 10 gallery images should be invalid');
    });
  });
}
