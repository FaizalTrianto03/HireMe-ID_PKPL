import 'dart:io';
import 'package:HireMe_Id/recruiter/explore/controllers/job_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Removed Firebase Storage in favor of WebDAV for media uploads
import 'package:HireMe_Id/utils/webdav_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';


class ProfileController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Observable untuk menyimpan data profil
  var profileData = {}.obs;

  // Status untuk memantau apakah data sedang dimuat
  var isLoading = false.obs;

  // Observable untuk menyimpan URL gambar profil
  var profileImage = ''.obs;

  // Observable untuk menyimpan lokasi yang dipilih user
  var selectedAddress = ''.obs;

  // Method untuk mengambil profil dari Firestore berdasarkan email
  Future<void> fetchProfile(String email) async {
    try {
      isLoading.value = true;

      // Ambil dokumen dari Firestore
      DocumentSnapshot doc = await _firestore.collection('Accounts').doc(email).get();

      if (doc.exists) {
        // Simpan data untuk role recruiter
        final data = doc.data() as Map<String, dynamic>;
        profileData.value = {
          'firstname': data['firstname'] ?? '',
          'lastname': data['lastname'] ?? '',
          'phone_number': data['phone_number'] ?? '',
          'address': data['address'] ?? '',
          'email_address': data['email_address'] ?? auth.currentUser?.email ?? email,
          'company_name': data['company_name'] ?? '',
          'company_position': data['company_position'] ?? '',
          'profile_image': data['profile_image'] ?? '',
          'created_at': data['created_at'] ?? Timestamp.now(),
        };
        profileImage.value = profileData['profile_image'] ?? '';
        selectedAddress.value = profileData['address'] ?? '';
      } else {
        // Jika dokumen tidak ditemukan, buat dokumen default untuk recruiter
        await _firestore.collection('Accounts').doc(email).set({
          'firstname': '',
          'lastname': '',
          'phone_number': '',
          'address': '',
          'email_address': auth.currentUser?.email ?? email,
          'company_name': '',
          'company_position': '',
          'profile_image': '',
          'created_at': FieldValue.serverTimestamp(),
          'role': 'recruiter',
        });

        // Ambil ulang data yang baru dibuat
        await fetchProfile(email);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk memilih gambar dari galeri
  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        File imageFile = File(image.path);

  // Upload image via WebDAV and get URL
  String imageUrl = await _uploadImageToWebDAV(imageFile);

        // Update URL gambar di Firestore
        await _updateProfileImageInFirestore(imageUrl);

        // Update UI dengan URL baru
        profileImage.value = imageUrl;

        Get.snackbar('Success', 'Profile image updated successfully.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick and upload image: $e');
    }
  }

  Future<String> _uploadImageToWebDAV(File imageFile) async {
    try {
      final String email = profileData['email_address'] ?? auth.currentUser?.email ?? '';
      if (email.isEmpty) {
        throw Exception("Email address is missing in profile data");
      }

      final webdav = WebDAVService();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final safeEmail = email.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final String ext = () {
        final parts = imageFile.path.split('.');
        if (parts.length > 1) {
          final e = parts.last.toLowerCase();
          if (e.length <= 5) return e; // jpg, jpeg, png, webp, etc
        }
        return 'jpg';
      }();
      final fileName = 'profile_${safeEmail}_$ts.$ext';

      await webdav.uploadFile(imageFile.path, fileName);
      return webdav.buildFileUrl(fileName);
    } catch (e) {
      throw Exception('Failed to upload image to WebDAV: $e');
    }
  }

Future<void> _updateProfileImageInFirestore(String imageUrl) async {
  final progressValue = 0.0.obs; // Objek untuk memantau progress

  // Tampilkan dialog progress
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
            Obx(() {
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressValue.value,
                      color: const Color(0xFF6750A4),
                      backgroundColor: const Color(0xFF6750A4).withOpacity(0.1),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(progressValue.value * 100).toInt()}%',
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
            }),
            const SizedBox(height: 24),
            const Text(
              'Updating profile image, please wait...',
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
    final String email = profileData['email_address'] ?? auth.currentUser?.email ?? '';
    if (email.isEmpty) {
      throw Exception("Email address is missing in profile data");
    }

    progressValue.value = 0.1;

    // Update field `profile_image` di Firestore (Accounts)
    await _firestore.collection('Accounts').doc(email).update({'profile_image': imageUrl});

    progressValue.value = 0.3;

    // Update juga local data agar sinkron
    profileData['profile_image'] = imageUrl;

    progressValue.value = 0.5;

    // Update companyLogoPath di Jobs
    final DocumentReference jobsDocRef = _firestore.collection('Jobs').doc(email);
    final DocumentSnapshot jobsDoc = await jobsDocRef.get();

    if (jobsDoc.exists) {
      final data = jobsDoc.data() as Map<String, dynamic>? ?? {};
      final List<dynamic> jobsData = data['jobs'] ?? [];

      final List<Map<String, dynamic>> updatedJobs = jobsData.map((job) {
        final Map<String, dynamic> jobMap = Map<String, dynamic>.from(job);
        jobMap['companyLogoPath'] = imageUrl; // Set companyLogoPath baru
        return jobMap;
      }).toList();

      progressValue.value = 0.7;

      await jobsDocRef.update({'jobs': updatedJobs});
    }

    progressValue.value = 0.9;

    // Pastikan controller selalu tersedia dengan Get.put()
    final JobController jobController =
        Get.isRegistered<JobController>()
            ? Get.find<JobController>()
            : Get.put(JobController());

    // Fetch jobs untuk memicu UI update
    await jobController.fetchJobs();

    progressValue.value = 1.0;
    Get.back(); // Tutup dialog setelah selesai
    Get.snackbar('Success', 'Profile image updated successfully.');
  } catch (e) {
    Get.back(); // Tutup dialog jika ada error
    throw Exception('Failed to update profile image and jobs: $e');
  }
}



  // Method untuk memperbarui profil di Firestore
  Future<void> updateProfile(String firstName, String lastName, String phoneNumber, String address, String companyName, String companyPosition) async {
  try {
    if (firstName.trim().isEmpty || lastName.trim().isEmpty || phoneNumber.trim().isEmpty || address.trim().isEmpty || companyName.trim().isEmpty || companyPosition.trim().isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields before saving.');
      return;
    }

    isLoading.value = true;

    final String email = profileData['email_address'] ?? auth.currentUser?.email ?? '';
    if (email.isEmpty) {
      throw Exception("Email address is missing.");
    }

    // Update profile di Accounts
    final updatedData = {
      'firstname': firstName.trim(),
      'lastname': lastName.trim(),
      'phone_number': phoneNumber.trim(),
      'address': address.trim(),
      'company_name': companyName.trim(),
      'company_position': companyPosition.trim(),
      'profile_image': profileImage.value,
    };

    await _firestore.collection('Accounts').doc(email).update(updatedData);

    // Update jobs di Firestore
    final DocumentSnapshot jobsDoc = await _firestore.collection('Jobs').doc(email).get();
    if (jobsDoc.exists) {
      final data = jobsDoc.data() as Map<String, dynamic>? ?? {};
      final List<dynamic> jobsData = data['jobs'] ?? [];

      final List<Map<String, dynamic>> updatedJobs = jobsData.map((job) {
        final Map<String, dynamic> jobMap = Map<String, dynamic>.from(job);

        // Update hanya companyName
        jobMap['companyName'] = companyName.trim();

        // Pastikan companyLogoPath tetap ada
        if (jobMap['companyLogoPath'] == null || jobMap['companyLogoPath'].isEmpty) {
          jobMap['companyLogoPath'] = job['companyLogoPath'];
        }

        return jobMap;
      }).toList();

      // Simpan kembali jobs yang diperbarui
      await _firestore.collection('Jobs').doc(email).update({'jobs': updatedJobs});
    }

    // Update local profileData
    profileData.assignAll(updatedData);
    selectedAddress.value = address;

    // Fetch ulang data pekerjaan
    final JobController jobController = Get.isRegistered<JobController>() ? Get.find<JobController>() : Get.put(JobController());
    await jobController.fetchJobs();

    Get.snackbar('Success', 'Profile and related jobs updated successfully.');
  } catch (e) {
    Get.snackbar('Error', 'Failed to update profile and jobs: $e');
  } finally {
    isLoading.value = false;
  }
}



  // Method untuk menyimpan lokasi yang dipilih user
  Future<void> saveSelectedLocation(String address) async {
    try {
      selectedAddress.value = address;

      final String email = profileData['email_address'] ?? auth.currentUser?.email ?? '';
      if (email.isEmpty) {
        throw Exception("Email address is missing.");
      }

      await _firestore.collection('Accounts').doc(email).update({'address': address});

      profileData['address'] = address;

      Get.snackbar('Success', 'Address updated successfully.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save location: $e');
    }
  }
}
