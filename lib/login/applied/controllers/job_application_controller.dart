import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart'; // Tambahkan ini di bagian atas file

class JobApplicationController extends GetxController {
  final reasonController = TextEditingController(); // Alasan melamar
  final cvFiles = <PlatformFile>[].obs; // List file CV
  final videoFile = Rxn<PlatformFile>(); // File video
  final firestore = FirebaseFirestore.instance;
  final firebaseAuth = FirebaseAuth.instance; // Instance FirebaseAuth

  final appliedJobs =
      <Map<String, dynamic>>[].obs; // List untuk menyimpan aplikasi kerja

  @override
  void onInit() {
    super.onInit();
    loadApplications();
  }

  /// Fungsi untuk memilih file CV (maksimal 3 file, format PDF)
  Future<void> pickCVFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        final selectedFiles = result.files;
        if (selectedFiles.length + cvFiles.length > 3) {
          Get.snackbar('Error', 'You can only upload up to 3 CV files.',
              snackPosition: SnackPosition.TOP);
        } else {
          cvFiles.addAll(selectedFiles);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick files: $e',
          snackPosition: SnackPosition.TOP);
    }
  }

  /// Fungsi untuk menghapus file CV
  void removeCVFile(PlatformFile file) {
    cvFiles.remove(file);
  }

  /// Fungsi untuk memilih file video (hanya 1 file)
  Future<void> pickVideoFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null) {
        videoFile.value = result.files.first;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick video file: $e',
          snackPosition: SnackPosition.TOP);
    }
  }

  /// Fungsi untuk menghapus file video
  void removeVideoFile() {
    videoFile.value = null;
  }

  /// Fungsi untuk memuat data aplikasi kerja pelamar
  /// Fungsi untuk memuat data aplikasi kerja pelamar
  Future<void> loadApplications() async {
    final currentUser = firebaseAuth.currentUser;

    if (currentUser == null) {
      Get.snackbar('Error', 'You need to be logged in to view applications.',
          snackPosition: SnackPosition.TOP);
      return;
    }

    final userEmail = currentUser.email;
    try {
      final docSnapshot =
          await firestore.collection('AppliedJobs').doc(userEmail).get();

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        appliedJobs.clear();
        return;
      }

      // Ambil array `applied` dan update `appliedJobs`
      final appliedData = docSnapshot.get('applied') as List<dynamic>;
      appliedJobs.value = appliedData.cast<Map<String, dynamic>>();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load applications: $e',
          snackPosition: SnackPosition.TOP);
    }
  }

  /// Fungsi untuk submit aplikasi kerja


Future<void> submitApplication(String idjob, String position) async {
  final currentUser = firebaseAuth.currentUser;

  // Pastikan user sudah login
  if (currentUser == null) {
    Get.snackbar('Error', 'You need to be logged in to apply for this job.',
        snackPosition: SnackPosition.TOP);
    return;
  }

  // Ambil email user dari FirebaseAuth
  final userEmail = currentUser.email;

  if (reasonController.text.isEmpty) {
    Get.snackbar('Error', 'Please fill in the reason for applying.',
        snackPosition: SnackPosition.TOP);
    return;
  }
  if (cvFiles.isEmpty) {
    Get.snackbar('Error', 'Please upload at least one CV.',
        snackPosition: SnackPosition.TOP);
    return;
  }
  if (videoFile.value == null) {
    Get.snackbar('Error', 'Please upload an introduction video.',
        snackPosition: SnackPosition.TOP);
    return;
  }

  try {
    // Cari email recruiter berdasarkan `idjob`
    final recruiterEmail = await findRecruiterEmail(idjob);

    // Validasi jika email recruiter tidak ditemukan
    if (recruiterEmail == null) {
      Get.snackbar('Error', 'Job not found.',
          snackPosition: SnackPosition.TOP);
      return;
    }

    // Generate ID unik menggunakan UUID
    final String applicationId = Uuid().v4();

    // Data aplikasi baru dengan waktu lokal
    final applicationData = {
      'id': applicationId, // Tambahkan ID unik
      'reason': reasonController.text,
      'cvFiles': cvFiles.map((file) => file.name).toList(),
      'videoFile': videoFile.value?.name ?? '',
      'applicantEmail': userEmail,
      'recruiterEmail': recruiterEmail,
      'position': position,
      'idjob': idjob,
      'status': 'Pengajuan', // Status default
      'timestamp': DateTime.now().toIso8601String(), // Waktu lokal dalam ISO 8601
    };

    // Simpan aplikasi baru ke dalam array `applied`
    final userDocRef = firestore.collection('AppliedJobs').doc(userEmail);

    await userDocRef.set({
      'applied': FieldValue.arrayUnion([applicationData]),
    }, SetOptions(merge: true));

    Get.snackbar('Success', 'Application submitted successfully!',
        snackPosition: SnackPosition.TOP);
  } catch (e) {
    Get.snackbar('Error', 'Failed to submit application: $e',
        snackPosition: SnackPosition.TOP);
  }
}





// Cari dokumen berdasarkan kondisi `idjob`
  Future<String?> findRecruiterEmail(String idjob) async {
    try {
      final jobsCollection = await firestore.collection('Jobs').get();

      // Iterasi setiap dokumen di koleksi Jobs
      for (var doc in jobsCollection.docs) {
        final jobsArray = doc.get('jobs') as List<dynamic>?;

        // Validasi jika `jobs` ada dan merupakan list
        if (jobsArray != null && jobsArray.isNotEmpty) {
          for (var job in jobsArray) {
            // Cek apakah `idjob` cocok
            if (job['idjob'] == idjob) {
              return doc.id; // Nama dokumen adalah email recruiter
            }
          }
        }
      }

      // Jika tidak ditemukan, kembalikan null
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to search job: $e',
          snackPosition: SnackPosition.TOP);
      return null;
    }
  }

  /// Fungsi untuk menghapus aplikasi kerja
  Future<void> deleteApplication(int index) async {
    final currentUser = firebaseAuth.currentUser;

    if (currentUser == null) {
      Get.snackbar('Error', 'You need to be logged in to delete applications.',
          snackPosition: SnackPosition.TOP);
      return;
    }

    final userEmail = currentUser.email;

    try {
      // Ambil dokumen pengguna
      final docSnapshot =
          await firestore.collection('AppliedJobs').doc(userEmail).get();

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        Get.snackbar('Error', 'Application not found.',
            snackPosition: SnackPosition.TOP);
        return;
      }

      // Ambil array `applied`
      final appliedData = docSnapshot.get('applied') as List<dynamic>;

      if (index < 0 || index >= appliedData.length) {
        Get.snackbar('Error', 'Invalid application index.',
            snackPosition: SnackPosition.TOP);
        return;
      }

      // Hapus aplikasi berdasarkan indeks
      appliedData.removeAt(index);

      // Update array `applied` di Firestore
      await firestore.collection('AppliedJobs').doc(userEmail).update({
        'applied': appliedData,
      });

      // Update state lokal
      appliedJobs.removeAt(index);

      Get.snackbar('Success', 'Application deleted successfully!',
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete application: $e',
          snackPosition: SnackPosition.TOP);
    }
  }
}
