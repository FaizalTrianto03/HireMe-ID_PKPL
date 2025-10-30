import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:HireMe_Id/utils/webdav_service.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class JobController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var jobs = <Map<String, dynamic>>[].obs;
  var recruiterData = {}.obs;
  var isLoading = false.obs;
  final RxList<String> galleryImageUrls = <String>[].obs;
  late final Directory tempDir;
  
  // FR-JOB-001: validasi field required dan format data
  // FR-JOB-002: pencegahan data duplikat dan integritas data

  @override
  void onInit() {
    super.onInit();
    initTemporaryDirectory();
  }

  Future<void> initTemporaryDirectory() async {
    try {
      tempDir = await getTemporaryDirectory();
      print("Temporary directory initialized: ${tempDir.path}");
    } catch (e) {
      print("Error initializing temporary directory: $e");
    }
  }
  
  // validasi field satu per satu secara sequential
  bool validateJobRequiredFields({
    required String position,
    required String location,
    required String jobType,
    required List<String> categories,
    required String jobDescription,
    required List<dynamic> requirements,
    required String salary,
    required String aboutCompany,
    required String industry,
    required String website,
    required List<String> facilities,
    required List<String> companyGalleryPaths,
  }) {
    // Validasi 1: Job Position
    if (position.trim().isEmpty) {
      _showValidationError("Job position is required");
      return false;
    }
    if (position.trim().length < 3) {
      _showValidationError("Job position must be at least 3 characters");
      return false;
    }
    
    // Validasi 2: Location
    if (location.trim().isEmpty) {
      _showValidationError("Location is required");
      return false;
    }
    if (location.trim().length < 3) {
      _showValidationError("Location must be at least 3 characters");
      return false;
    }
    
    // Validasi 3: Job Type
    final allowedJobTypes = ['Full-time', 'Part-time', 'Contract', 'Freelance'];
    if (jobType.isEmpty) {
      _showValidationError("Job type is required");
      return false;
    }
    if (!allowedJobTypes.contains(jobType)) {
      _showValidationError("Invalid job type. Must be Full-time, Part-time, Contract, or Freelance");
      return false;
    }
    
    // Validasi 4: Categories
    if (categories.isEmpty) {
      _showValidationError("At least one job category is required");
      return false;
    }
    if (categories.length > 5) {
      _showValidationError("Maximum 5 job categories allowed");
      return false;
    }
    
    // Validasi 5: Job Description
    if (jobDescription.trim().isEmpty) {
      _showValidationError("Job description is required");
      return false;
    }
    if (jobDescription.trim().length < 50) {
      _showValidationError("Job description must be at least 50 characters");
      return false;
    }
    if (jobDescription.trim().length > 300) {
      _showValidationError("Job description must not exceed 300 characters");
      return false;
    }
    
    // Validasi 6: Requirements
    if (requirements.isEmpty) {
      _showValidationError("At least one job requirement is required");
      return false;
    }
    for (var i = 0; i < requirements.length; i++) {
      String reqText = '';
      if (requirements[i] is String) {
        reqText = requirements[i];
      } else if (requirements[i] is Map && requirements[i]['text'] != null) {
        reqText = requirements[i]['text'];
      }
      
      if (reqText.trim().isEmpty) {
        _showValidationError("Requirement ${i + 1} cannot be empty");
        return false;
      }
      if (reqText.trim().length < 5) {
        _showValidationError("Requirement ${i + 1} must be at least 5 characters");
        return false;
      }
    }
    
    // Validasi 7: Facilities
    if (facilities.isEmpty || (facilities.length == 1 && facilities[0].trim().isEmpty)) {
      _showValidationError("At least one benefit/facility is required");
      return false;
    }
    
    // Validasi 8: Salary
    if (salary.trim().isEmpty) {
      _showValidationError("Salary range is required");
      return false;
    }
    if (salary.trim().length < 5) {
      _showValidationError("Please provide a valid salary range (e.g., IDR 5,000,000 - 10,000,000)");
      return false;
    }
    
    // Validasi 9: About Company
    if (aboutCompany.trim().isEmpty) {
      _showValidationError("Company description is required");
      return false;
    }
    if (aboutCompany.trim().length < 30) {
      _showValidationError("Company description must be at least 30 characters");
      return false;
    }
    if (aboutCompany.trim().length > 150) {
      _showValidationError("Company description must not exceed 150 characters");
      return false;
    }
    
    // Validasi 10: Industry
    if (industry.trim().isEmpty) {
      _showValidationError("Industry is required");
      return false;
    }
    
    // Validasi 11: Website
    if (website.trim().isEmpty) {
      _showValidationError("Company website is required");
      return false;
    }
    final urlPattern = RegExp(
      r'^(https?:\/\/)?(www\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}',
      caseSensitive: false,
    );
    if (!urlPattern.hasMatch(website.trim())) {
      _showValidationError("Invalid website URL format. Must include domain (e.g., www.company.com)");
      return false;
    }
    
    // Validasi 12: Company Gallery
    if (companyGalleryPaths.isEmpty) {
      _showValidationError("At least one company gallery image is required");
      return false;
    }
    if (companyGalleryPaths.length > 10) {
      _showValidationError("Maximum 10 company gallery images allowed");
      return false;
    }
    
    return true;
  }
  
  void _showValidationError(String message) {
    Get.snackbar(
      'Validation Failed',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[700],
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
  
  // cek duplicate job position (case insensitive)
  bool validateJobUniqueness(String position, {int? excludeJobIndex}) {
    final normalizedPosition = position.trim().toLowerCase();
    
    for (var i = 0; i < jobs.length; i++) {
      if (excludeJobIndex != null && i == excludeJobIndex) {
        continue;
      }
      
      final existingPosition = (jobs[i]['position'] ?? '').toString().toLowerCase();
      if (existingPosition == normalizedPosition) {
        _showValidationError('A job with the position "$position" already exists. Please use a different position title.');
        return false;
      }
    }
    
    return true;
  }
  
  // validasi index dan struktur data job sebelum update/delete
  bool validateJobDataIntegrity(int jobIndex) {
    if (jobIndex < 0) {
      _showValidationError('Job index cannot be negative');
      return false;
    }
    
    if (jobIndex >= jobs.length) {
      _showValidationError('The selected job no longer exists. Please refresh the job list.');
      return false;
    }
    
    final job = jobs[jobIndex];
    if (job['idjob'] == null || job['idjob'].toString().isEmpty) {
      _showValidationError('Job data is corrupted (missing ID). Please contact support.');
      return false;
    }
    
    return true;
  }

  Future<bool> addJob({
    required String position,
    required String location,
    required String jobType,
    required List<String> categories,
    required String jobDescription,
    required List<dynamic> requirements,
    required List<String> facilities,
    required String salary,
    required String aboutCompany,
    required String industry,
    required String website,
    required List<String> companyGalleryPaths,
  }) async {
    isLoading.value = true;

    try {
      // Step 1: Cek user login
      final String? email = auth.currentUser?.email;
      if (email == null) {
        _showValidationError('User not logged in. Please login again.');
        isLoading.value = false;
        return false;
      }

      // Step 2: Load data jobs jika belum ada
      if (jobs.isEmpty) {
        await fetchJobs();
      }
      
      // Step 3: Load data recruiter jika belum ada
      if (recruiterData.isEmpty) {
        await fetchRecruiterData();
      }

      // Step 4: Validasi semua field required (sequential)
      final isValidFields = validateJobRequiredFields(
        position: position,
        location: location,
        jobType: jobType,
        categories: categories,
        jobDescription: jobDescription,
        requirements: requirements,
        salary: salary,
        aboutCompany: aboutCompany,
        industry: industry,
        website: website,
        facilities: facilities,
        companyGalleryPaths: companyGalleryPaths,
      );
      
      if (!isValidFields) {
        isLoading.value = false;
        return false;
      }

      // Step 5: Cek duplikat job position
      if (!validateJobUniqueness(position)) {
        isLoading.value = false;
        return false;
      }

      // Step 6: Ambil data company dari recruiter
      final companyName = recruiterData['company_name'] ?? 'Unknown Company';
      final companyLogoPath = recruiterData['profile_image'] ?? '';

      // Step 7: Generate ID job
      final random = Random();
      final String idjob =
          List.generate(10, (_) => String.fromCharCode(65 + random.nextInt(26)))
              .join();

      // Step 8: Buat struktur job baru
      final newJob = {
        'idjob': idjob,
        'position': position,
        'companyName': companyName,
        'location': location,
        'companyLogoPath': companyLogoPath,
        'jobType': jobType,
        'categories': categories,
        'jobDetails': {
          'jobDescription': jobDescription,
          'requirements': requirements,
          'location': location,
          'facilities': facilities,
          'companyDetails': {
            'aboutCompany': aboutCompany,
            'website': website,
            'industry': industry,
            'companyGalleryPaths': companyGalleryPaths,
          },
        },
        'salary': salary,
        'isApplied': false,
        'applyStatus': 'inProcess',
        'isRecommended': false,
        'isSaved': false,
      };

      // Step 9: Simpan ke Firestore
      final jobsDocRef = firestore.collection('Jobs').doc(email);
      await jobsDocRef.set(
        {
          'jobs': FieldValue.arrayUnion([newJob]),
        },
        SetOptions(merge: true),
      );

      // Step 10: Update local jobs list
      jobs.add(newJob);

      // Step 11: Cleanup unused gallery images
      await _cleanUnusedGalleryImages(email);

      // Step 12: SEMUA SUKSES - Tampilkan success message
      Get.snackbar(
        'Success',
        'Job has been posted successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[700],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
      
      isLoading.value = false;
      return true;
    } catch (e) {
      _showValidationError('Failed to add job: ${e.toString()}');
      print("Error in addJob: $e");
      isLoading.value = false;
      return false;
    }
  }

  Future<void> fetchJobs() async {
    try {
      isLoading.value = true;

      final String? email = auth.currentUser?.email;
      if (email == null) {
        throw Exception("User not logged in.");
      }

      final jobsDoc = await firestore.collection('Jobs').doc(email).get();
      if (!jobsDoc.exists) {
        jobs.value = [];
      } else {
        final jobsData = jobsDoc.data()?['jobs'] as List<dynamic>? ?? [];
        jobs.value = jobsData.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch jobs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  final progressValue = ValueNotifier<double>(0.0);

  Future<bool> updateJob(int jobIndex, Map<String, dynamic> updatedFields) async {
    isLoading.value = true;
    
    try {
      // Step 1: Cek user login
      final String? email = auth.currentUser?.email;
      if (email == null) {
        _showValidationError('User not logged in.');
        isLoading.value = false;
        return false;
      }

      // Step 2: Ambil data jobs dari Firestore
      final jobsDocRef = firestore.collection('Jobs').doc(email);
      final jobsSnapshot = await jobsDocRef.get();
      if (!jobsSnapshot.exists) {
        _showValidationError('No jobs found');
        isLoading.value = false;
        return false;
      }

      // Step 3: Cek index valid
      final List<dynamic> allJobs = jobsSnapshot.data()?['jobs'] ?? [];
      if (jobIndex < 0 || jobIndex >= allJobs.length) {
        _showValidationError('Cannot update job. The job index ($jobIndex) is invalid. Available jobs: ${allJobs.length}');
        isLoading.value = false;
        return false;
      }
      
      // Step 4: Ambil data job yang akan diupdate
      final Map<String, dynamic> jobData = Map<String, dynamic>.from(allJobs[jobIndex]);
      
      // Step 5: Extract semua field dari updatedFields untuk validasi
      String position = jobData['position'] ?? '';
      String location = jobData['location'] ?? '';
      String jobType = jobData['jobType'] ?? '';
      List<String> categories = List<String>.from(jobData['categories'] ?? []);
      String salary = jobData['salary'] ?? '';
      
      Map<String, dynamic> jobDetails = Map<String, dynamic>.from(jobData['jobDetails'] ?? {});
      String jobDescription = jobDetails['jobDescription'] ?? '';
      List<dynamic> requirements = jobDetails['requirements'] ?? [];
      List<String> facilities = List<String>.from(jobDetails['facilities'] ?? []);
      
      Map<String, dynamic> companyDetails = Map<String, dynamic>.from(jobDetails['companyDetails'] ?? {});
      String aboutCompany = companyDetails['aboutCompany'] ?? '';
      String industry = companyDetails['industry'] ?? '';
      String website = companyDetails['website'] ?? '';
      List<String> companyGalleryPaths = List<String>.from(companyDetails['companyGalleryPaths'] ?? []);
      
      // Step 6: Apply updated fields ke variabel lokal
      if (updatedFields.containsKey('position')) {
        position = updatedFields['position'] as String;
      }
      if (updatedFields.containsKey('location')) {
        location = updatedFields['location'] as String;
      }
      if (updatedFields.containsKey('jobType')) {
        jobType = updatedFields['jobType'] as String;
      }
      if (updatedFields.containsKey('categories')) {
        categories = List<String>.from(updatedFields['categories']);
      }
      if (updatedFields.containsKey('salary')) {
        salary = updatedFields['salary'] as String;
      }
      if (updatedFields.containsKey('jobDetails.jobDescription')) {
        jobDescription = updatedFields['jobDetails.jobDescription'] as String;
      }
      if (updatedFields.containsKey('jobDetails.requirements')) {
        requirements = updatedFields['jobDetails.requirements'];
      }
      if (updatedFields.containsKey('jobDetails.facilities')) {
        facilities = List<String>.from(updatedFields['jobDetails.facilities']);
      }
      if (updatedFields.containsKey('jobDetails.companyDetails.aboutCompany')) {
        aboutCompany = updatedFields['jobDetails.companyDetails.aboutCompany'] as String;
      }
      if (updatedFields.containsKey('jobDetails.companyDetails.industry')) {
        industry = updatedFields['jobDetails.companyDetails.industry'] as String;
      }
      if (updatedFields.containsKey('jobDetails.companyDetails.website')) {
        website = updatedFields['jobDetails.companyDetails.website'] as String;
      }
      if (updatedFields.containsKey('jobDetails.companyDetails.companyGalleryPaths')) {
        companyGalleryPaths = List<String>.from(updatedFields['jobDetails.companyDetails.companyGalleryPaths']);
      }
      
      // Step 7: Validasi semua field (sequential)
      final isValidFields = validateJobRequiredFields(
        position: position,
        location: location,
        jobType: jobType,
        categories: categories,
        jobDescription: jobDescription,
        requirements: requirements,
        salary: salary,
        aboutCompany: aboutCompany,
        industry: industry,
        website: website,
        facilities: facilities,
        companyGalleryPaths: companyGalleryPaths,
      );
      
      if (!isValidFields) {
        isLoading.value = false;
        return false;
      }
      
      // Step 8: Cek uniqueness jika position berubah
      if (updatedFields.containsKey('position')) {
        if (!validateJobUniqueness(position, excludeJobIndex: jobIndex)) {
          isLoading.value = false;
          return false;
        }
      }
      
      // Step 9: Apply perubahan ke jobData
      updatedFields.forEach((key, value) {
        if (key.contains('.')) {
          final keys = key.split('.');
          var currentMap = jobData;
          for (var i = 0; i < keys.length - 1; i++) {
            currentMap = currentMap[keys[i]] as Map<String, dynamic>;
          }
          currentMap[keys.last] = value;
        } else {
          jobData[key] = value;
        }
      });

      // Step 10: Update ke Firestore
      allJobs[jobIndex] = jobData;
      await jobsDocRef.update({'jobs': allJobs});

      // Step 11: SEMUA SUKSES - Tampilkan success message
      Get.snackbar(
        'Success',
        'Job updated successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[700],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
      
      isLoading.value = false;
      return true;
    } catch (e) {
      _showValidationError('Failed to update job: ${e.toString()}');
      print("Error in updateJob: $e");
      isLoading.value = false;
      return false;
    }
  }


  Future<void> updateJob2(
      int jobIndex, Map<String, dynamic> updatedFields) async {
    try {
      isLoading.value = true;

      final String? email = auth.currentUser?.email;
      if (email == null) {
        Get.snackbar(
          'Error',
          'User not logged in.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[700],
          colorText: Colors.white,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
        isLoading.value = false;
        return;
      }

      final jobsDocRef = firestore.collection('Jobs').doc(email);

      final jobsDoc = await jobsDocRef.get();
      if (!jobsDoc.exists) {
        throw Exception("No jobs found for this recruiter.");
      }

      final jobsData = jobsDoc.data()?['jobs'] as List<dynamic>? ?? [];
      if (jobIndex >= jobsData.length) {
        throw Exception("Invalid job index.");
      }

      final originalJob = jobsData[jobIndex];

      final updatedJob = <String, dynamic>{
        ...originalJob,
        ...updatedFields,
        'jobDetails': <String, dynamic>{
          ...originalJob['jobDetails'] ?? {},
          ...updatedFields['jobDetails'] ?? {},
          'companyDetails': <String, dynamic>{
            ...originalJob['jobDetails']?['companyDetails'] ?? {},
            ...updatedFields['jobDetails']?['companyDetails'] ?? {},
          },
        },
      };

      final Map<String, dynamic> partialUpdate = {
        'jobs.$jobIndex': updatedJob,
      };
      await jobsDocRef.update(partialUpdate);

      print("Partial firestore update success");

      Get.snackbar(
        'Success',
        'Job updated successfully.',
        icon: const Icon(Icons.check_circle, color: Colors.white),
        backgroundColor: Colors.green[700],
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print("Error during partial update: $e");
      Get.snackbar(
        'Error',
        'Failed to update job: $e',
        icon: const Icon(Icons.error_outline, color: Colors.white),
        backgroundColor: Colors.red[700],
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteJob(int jobIndex) async {
    try {
      isLoading.value = true;

      final String? email = auth.currentUser?.email;
      if (email == null) {
        Get.snackbar(
          'Error',
          'User not logged in.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[700],
          colorText: Colors.white,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
        isLoading.value = false;
        return;
      }

      final jobsDocRef = firestore.collection('Jobs').doc(email);
      final jobsDoc = await jobsDocRef.get();

      if (!jobsDoc.exists) {
        Get.snackbar(
          'No Jobs Found',
          'You don\'t have any jobs posted yet.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[700],
          colorText: Colors.white,
          icon: const Icon(Icons.info_outline, color: Colors.white),
        );
        isLoading.value = false;
        return;
      }

      final jobsData = jobsDoc.data()?['jobs'] as List<dynamic>? ?? [];
      final List<Map<String, dynamic>> updatedJobs =
          jobsData.cast<Map<String, dynamic>>();

      if (jobIndex < 0 || jobIndex >= updatedJobs.length) {
        Get.snackbar(
          'Invalid Job Index',
          'Cannot delete job. The job index ($jobIndex) is invalid. You only have ${updatedJobs.length} job(s) posted.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[700],
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
        isLoading.value = false;
        return;
      }
      
      final deletedJobTitle = updatedJobs[jobIndex]['position'] ?? 'Unknown';
      print("Deleting job: $deletedJobTitle");

      updatedJobs.removeAt(jobIndex);

      await jobsDocRef.update({'jobs': updatedJobs});
      jobs.value = updatedJobs;

      Get.snackbar(
        'Success',
        'Job deleted successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[700],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete job: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[700],
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      print("Error in deleteJob: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRecruiterData() async {
    try {
      isLoading.value = true;

      final String? email = auth.currentUser?.email;
      if (email == null) {
        throw Exception("User not logged in.");
      }

      final recruiterDoc =
          await firestore.collection('Accounts').doc(email).get();

      if (recruiterDoc.exists) {
        recruiterData.value = recruiterDoc.data() ?? {};
      } else {
        recruiterData.value = {};
        throw Exception("Recruiter profile not found.");
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch recruiter data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi memilih dan mengunggah gambar
  Future<String?> pickAndUploadImage({
    required String email,
    int? jobIndex, // Argumen opsional untuk menentukan pekerjaan
  }) async {
    try {
      // Pilih file gambar dari galeri
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        return null; // User batal memilih gambar
      }

      final File file = File(pickedFile.path);

      final String uniqueFileName = '${email}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final webdav = WebDAVService();
      await webdav.uploadFile(file.path, uniqueFileName);
      final String downloadUrl = webdav.buildFileUrl(uniqueFileName);

      print("Image uploaded to WebDAV for $email: $downloadUrl");

      if (jobIndex != null) {
        print("Updating galleryPaths for job at index $jobIndex");

        final jobsDocRef = firestore.collection('Jobs').doc(email);
        final jobsDoc = await jobsDocRef.get();

        if (!jobsDoc.exists) {
          throw Exception("Jobs document not found.");
        }

        final jobsData = jobsDoc.data()?['jobs'] as List<dynamic>? ?? [];
        final List<Map<String, dynamic>> jobs =
            jobsData.cast<Map<String, dynamic>>();

        if (jobIndex >= jobs.length) {
          throw Exception("Invalid job index.");
        }

    final List<dynamic> currentGalleryPathsDyn = jobs[jobIndex]['jobDetails']
          ['companyDetails']['companyGalleryPaths'] ??
      [];
    final List<String> currentGalleryPaths = currentGalleryPathsDyn
      .map((e) {
        if (e is String) return e;
        if (e is Map && e.containsKey('text')) return e['text'].toString();
        return e.toString();
      })
      .cast<String>()
      .toList();

    final updatedGalleryPaths = [...currentGalleryPaths, downloadUrl];

        jobs[jobIndex]['jobDetails']['companyDetails']['companyGalleryPaths'] =
            updatedGalleryPaths;

        await jobsDocRef.update({'jobs': jobs});

        print("Gallery paths updated successfully for job at index $jobIndex");
      }

      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _cleanUnusedGalleryImages(String email) async {
    try {

      final List<String> usedFileNames = await _fetchUsedGalleryFileNames(email);

      final webdav = WebDAVService();
      final allFiles = await webdav.listFiles();
      for (final remoteName in allFiles) {
        if (!remoteName.startsWith('${email}_')) continue;
        if (!usedFileNames.contains(remoteName)) {
         
          await webdav.deleteFile(remoteName);
        } else {
     ;
        }
      }

    } catch (e) {
      print("Error during cleaning: $e");
    }
  }

// Fungsi untuk mengambil semua URL gambar yang digunakan dari Firestore
  /// Returns list of WebDAV file names currently referenced in Jobs for [email].
  /// It will extract filenames from WebDAV URLs and ignore non-WebDAV entries.
  Future<List<String>> _fetchUsedGalleryFileNames(String email) async {
    final List<String> usedNames = [];

    try {
      final jobsDoc = await firestore.collection('Jobs').doc(email).get();

      if (jobsDoc.exists) {
        final jobsData = jobsDoc.data()?['jobs'] as List<dynamic>? ?? [];
        for (final job in jobsData) {
          final List<dynamic> galleryPaths = job['jobDetails']
                  ?['companyDetails']?['companyGalleryPaths'] ??
              [];
          for (final g in galleryPaths) {
            if (g is String) {
              final name = _extractWebDavFileNameFromUrl(g);
              if (name != null) usedNames.add(name);
            } else if (g is Map && g.containsKey('text')) {
              final name = _extractWebDavFileNameFromUrl(g['text'].toString());
              if (name != null) usedNames.add(name);
            }
          }
        }
      }

      if (usedNames.isEmpty) {
        print("No used WebDAV filenames found for email: $email in Jobs");
      }
    } catch (e) {
      print("Error fetching used names: $e");
    }

    return usedNames;
  }

  String? _extractWebDavFileNameFromUrl(String url) {
    try {
      final marker = '/remote.php/dav/files/';
      final idx = url.indexOf(marker);
      if (idx == -1) return null;
      final appMarker = '/HireMe_Id_App/';
      final appIdx = url.indexOf(appMarker, idx);
      if (appIdx == -1) return null;
      final name = url.substring(appIdx + appMarker.length);
      return Uri.decodeComponent(name);
    } catch (_) {
      return null;
    }
  }

  String? extractWebDavFileNameFromUrl(String url) => _extractWebDavFileNameFromUrl(url);
}
