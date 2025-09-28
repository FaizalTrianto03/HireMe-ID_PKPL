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
  // Firebase Storage replaced by WebDAV for media storage

  var jobs = <Map<String, dynamic>>[].obs; // Observable untuk daftar pekerjaan
  var recruiterData = {}.obs; // Observable untuk data recruiter
  var isLoading = false.obs; // Observable untuk status loading
  final RxList<String> galleryImageUrls = <String>[].obs; // Daftar URL galeri
  late final Directory tempDir;

  @override
  void onInit() {
    super.onInit();
    initTemporaryDirectory();
  }

  Future<void> initTemporaryDirectory() async {
    try {
      tempDir = await getTemporaryDirectory();
      print("✅ Temporary directory initialized: ${tempDir.path}");
    } catch (e) {
      print("❗ Error initializing temporary directory: $e");
    }
  }

  // Fungsi menambahkan pekerjaan baru ke Firestore
  Future<void> addJob({
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
    progressValue.value = 0.0;

    Get.dialog(
      Center(
        child: Container(
          width: Get.width * 0.8,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<double>(
                valueListenable: progressValue,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: value,
                          color: const Color(0xFF6750A4),
                          backgroundColor:
                              const Color(0xFF6750A4).withOpacity(0.1),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${(value * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Color(0xFF6750A4),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Harap bersabar, ini memakan sedikit waktu...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Color(0xFF6750A4),
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      isLoading.value = true;

      // Dapatkan email pengguna saat ini
      final String? email = auth.currentUser?.email;
      if (email == null) {
        throw Exception("User not logged in.");
      }
      progressValue.value = 0.1;

      // Pastikan daftar pekerjaan sudah diambil
      if (jobs.isEmpty) {
        await fetchJobs();
      }
      progressValue.value = 0.2;

      // Validasi: Cek apakah job position sudah ada (case insensitive)
      final bool isDuplicate = jobs.any((job) =>
          (job['position'] ?? '').toString().toLowerCase() ==
          position.toLowerCase());
      if (isDuplicate) {
        throw Exception("Job position already exists.");
      }
      progressValue.value = 0.3;

      // Data recruiter harus tersedia
      if (recruiterData.isEmpty) {
        await fetchRecruiterData();
      }
      progressValue.value = 0.4;

      // Ambil data recruiter dari Firestore
      final companyName = recruiterData['company_name'] ?? 'Unknown Company';
      final companyLogoPath = recruiterData['profile_image'] ?? '';

      // Generate idjob
      final random = Random();
      final String idjob =
          List.generate(10, (_) => String.fromCharCode(65 + random.nextInt(26)))
              .join();

      // Buat data pekerjaan baru
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

      // Simpan pekerjaan ke Firestore
      final jobsDocRef = firestore.collection('Jobs').doc(email);
      await jobsDocRef.set(
        {
          'jobs': FieldValue.arrayUnion([newJob]),
        },
        SetOptions(merge: true),
      );
      progressValue.value = 0.5;

      // Tambahkan ke daftar jobs lokal
      jobs.add(newJob);

      // Proses cleaning file yang tidak digunakan
      print("🧹 Starting cleaning process...");
      await _cleanUnusedGalleryImages(email);
      progressValue.value = 1.0;

      Get.back(); // Tutup dialog
      Get.snackbar('Success', 'Job added successfully.');
    } catch (e) {
      Get.back(); // Tutup dialog jika terjadi error
      Get.snackbar('Error', 'Failed to add job: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi mengambil semua pekerjaan recruiter dari Firestore
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

  // Fungsi memperbarui pekerjaan tertentu
  final progressValue = ValueNotifier<double>(0.0);

  Future<void> updateJob(int jobIndex, Map<String, dynamic> updatedFields) async {
    progressValue.value = 0.0;
    Get.dialog(
      Center(
        child: Container(
          width: Get.width * 0.8,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<double>(
                valueListenable: progressValue,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: value,
                          color: const Color(0xFF6750A4),
                          backgroundColor: const Color(0xFF6750A4).withOpacity(0.1),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${(value * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Color(0xFF6750A4),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Harap bersabar, ini memakan sedikit waktu...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Color(0xFF6750A4),
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final String? email = auth.currentUser?.email;
      if (email == null) {
        throw Exception("User not logged in.");
      }
      progressValue.value = 0.1;

      final jobsDocRef = firestore.collection('Jobs').doc(email);
      final jobsSnapshot = await jobsDocRef.get();
      if (!jobsSnapshot.exists) {
        throw Exception("No jobs found for the current user.");
      }
      progressValue.value = 0.2;

      final List<dynamic> allJobs = jobsSnapshot.data()?['jobs'] ?? [];
      if (jobIndex < 0 || jobIndex >= allJobs.length) {
        throw Exception("Invalid job index.");
      }
      final Map<String, dynamic> jobData = Map<String, dynamic>.from(allJobs[jobIndex]);
      progressValue.value = 0.35;

      // Update hanya field yang diberikan tanpa mengganti seluruh struktur
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
      progressValue.value = 0.6;

      // Replace job yang diupdate di array lalu simpan
      allJobs[jobIndex] = jobData;
      await jobsDocRef.update({'jobs': allJobs});
      progressValue.value = 1.0;

      Get.back();
      Get.snackbar('Success', 'Job updated successfully.');
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Failed to update job: $e');
      rethrow;
    }
}


  Future<void> updateJob2(
      int jobIndex, Map<String, dynamic> updatedFields) async {
    progressValue.value = 0.0;

    Get.dialog(
      Center(
        child: Container(
          width: Get.width * 0.8,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<double>(
                valueListenable: progressValue,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: value,
                          color: const Color(0xFF6750A4),
                          backgroundColor:
                              const Color(0xFF6750A4).withOpacity(0.1),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${(value * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Color(0xFF6750A4),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Harap bersabar, ini memakan sedikit waktu...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Color(0xFF6750A4),
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      isLoading.value = true;

      final String? email = auth.currentUser?.email;
      if (email == null) {
        throw Exception("User not logged in.");
      }
      progressValue.value = 0.1;

      final jobsDocRef = firestore.collection('Jobs').doc(email);

      // Ambil data asli dari Firestore
      final jobsDoc = await jobsDocRef.get();
      if (!jobsDoc.exists) {
        throw Exception("No jobs found for this recruiter.");
      }

      final jobsData = jobsDoc.data()?['jobs'] as List<dynamic>? ?? [];
      if (jobIndex >= jobsData.length) {
        throw Exception("Invalid job index.");
      }

      final originalJob = jobsData[jobIndex];

      // Bangun data baru dengan struktur dari `addJob`
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

      // Debugging: Print data untuk memastikan hasil akhir
      print("🧐 ORIGINAL JOB AT INDEX $jobIndex BEFORE UPDATE:");
      print(originalJob);
      print("✏️ FINAL UPDATED JOB DATA TO APPLY:");
      print(updatedJob);

      // Update data di Firestore
      final Map<String, dynamic> partialUpdate = {
        'jobs.$jobIndex': updatedJob,
      };
      await jobsDocRef.update(partialUpdate);
      progressValue.value = 0.5;

      print("🔥 PARTIAL FIRESTORE UPDATE SUCCESS!");

      Get.back(); // Close loading dialog
      Get.snackbar(
        'Success',
        'Job updated successfully.',
        icon: const Icon(Icons.check_circle, color: Colors.white),
        backgroundColor: Colors.green[700],
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      print("❌ ERROR DURING PARTIAL UPDATE: $e");
      Get.snackbar(
        'Error',
        'Failed to update job: $e',
        icon: const Icon(Icons.error_outline, color: Colors.white),
        backgroundColor: Colors.red[700],
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // removed unused _mergeMaps helper

  // Fungsi menghapus pekerjaan tertentu
  Future<void> deleteJob(int jobIndex) async {
    try {
      isLoading.value = true;

      final String? email = auth.currentUser?.email;
      if (email == null) {
        throw Exception("User not logged in.");
      }

      final jobsDocRef = firestore.collection('Jobs').doc(email);
      final jobsDoc = await jobsDocRef.get();

      if (!jobsDoc.exists) {
        throw Exception("No jobs found for this recruiter.");
      }

      final jobsData = jobsDoc.data()?['jobs'] as List<dynamic>? ?? [];
      final List<Map<String, dynamic>> updatedJobs =
          jobsData.cast<Map<String, dynamic>>();

      if (jobIndex >= updatedJobs.length) {
        throw Exception("Invalid job index.");
      }

      updatedJobs.removeAt(jobIndex);

      await jobsDocRef.update({'jobs': updatedJobs});
      jobs.value = updatedJobs;

      Get.snackbar('Success', 'Job deleted successfully.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete job: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi mengambil data recruiter dari Firestore
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

      // Buat nama unik untuk file dan unggah ke WebDAV
      final String uniqueFileName = '${email}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final webdav = WebDAVService();
      await webdav.uploadFile(file.path, uniqueFileName);
      final String downloadUrl = webdav.buildFileUrl(uniqueFileName);

      print("✅ Image uploaded to WebDAV for $email: $downloadUrl");

      // Jika jobIndex diberikan, tambahkan URL ke galleryPaths pekerjaan tersebut
      if (jobIndex != null) {
        print("🔄 Updating galleryPaths for job at index $jobIndex...");

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

    // Ambil galleryPaths lama (dapat berupa URL string atau object list)
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

    // Tambahkan URL baru jika belum ada
    final updatedGalleryPaths = [...currentGalleryPaths, downloadUrl];

        // Perbarui jobs dengan galleryPaths terbaru
        jobs[jobIndex]['jobDetails']['companyDetails']['companyGalleryPaths'] =
            updatedGalleryPaths;

        await jobsDocRef.update({'jobs': jobs});

        print(
            "✅ Gallery paths updated successfully for job at index $jobIndex.");
      }

      // Kembalikan URL untuk kasus penggunaan lain
      return downloadUrl;
    } catch (e) {
      print("❗ Error uploading image: $e");
      return null;
    }
  }

// Fungsi untuk membersihkan file yang tidak terpakai
  Future<void> _cleanUnusedGalleryImages(String email) async {
    try {
      print("🧹 Cleaning started for email: $email");

      // Ambil semua URL yang digunakan dari Firestore
      final List<String> usedFileNames = await _fetchUsedGalleryFileNames(email);

      print("🔗 Used paths from Jobs:");
      for (final path in usedFileNames) {
        print("- $path");
      }

      // Hapus file yang tidak digunakan dari WebDAV (filter berdasarkan prefix email_)
      print("🔍 Checking and cleaning unused WebDAV files:");
      final webdav = WebDAVService();
      final allFiles = await webdav.listFiles();
      for (final remoteName in allFiles) {
        // only consider files uploaded for this email (we use prefix email_)
        if (!remoteName.startsWith('${email}_')) continue;
        if (!usedFileNames.contains(remoteName)) {
          print('❌ Deleting unused WebDAV file: $remoteName');
          await webdav.deleteFile(remoteName);
        } else {
          print('✅ Keeping WebDAV file: $remoteName');
        }
      }

      print("✅ Cleaning completed for email: $email");
    } catch (e) {
      print("❗ Error during cleaning: $e");
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
        print("❗ No used WebDAV filenames found for email: $email in Jobs.");
      }
    } catch (e) {
      print("❗ Error fetching used names: $e");
    }

    return usedNames;
  }

  /// If [url] is a Nextcloud/WebDAV URL under the app folder, return the filename
  /// as stored on the server (e.g. 'email_12345.jpg'). Otherwise return null.
  String? _extractWebDavFileNameFromUrl(String url) {
    try {
      final marker = '/remote.php/dav/files/';
      final idx = url.indexOf(marker);
      if (idx == -1) return null;
      // Find the '/HireMe_Id_App/' segment after the marker
      final appMarker = '/HireMe_Id_App/';
      final appIdx = url.indexOf(appMarker, idx);
      if (appIdx == -1) return null;
      final name = url.substring(appIdx + appMarker.length);
      // decode any percent-encoding
      return Uri.decodeComponent(name);
    } catch (_) {
      return null;
    }
  }

  /// Public wrapper so views can resolve WebDAV filenames from stored URLs.
  String? extractWebDavFileNameFromUrl(String url) => _extractWebDavFileNameFromUrl(url);
}
