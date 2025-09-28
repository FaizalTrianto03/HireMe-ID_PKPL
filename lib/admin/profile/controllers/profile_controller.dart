import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Removed Firebase Storage in favor of WebDAV for media uploads
import 'package:HireMe_Id/utils/webdav_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Image picker instance
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
        // Hanya simpan field yang relevan untuk jobseeker
        final data = doc.data() as Map<String, dynamic>;
        profileData.value = {
          'firstname': data['firstname'] ?? '',
          'lastname': data['lastname'] ?? '',
          'phone_number': data['phone_number'] ?? '',
          'address': data['address'] ?? '',
          'email_address': data['email_address'] ?? auth.currentUser?.email ?? email,
          'profile_image': data['profile_image'] ?? '',
          'created_at': data['created_at'] ?? Timestamp.now(),
        };
        profileImage.value = profileData['profile_image'] ?? '';
        selectedAddress.value = profileData['address'] ?? '';
      } else {
        // Jika dokumen tidak ditemukan, buat dokumen default
        await _firestore.collection('Accounts').doc(email).set({
          'firstname': '',
          'lastname': '',
          'phone_number': '',
          'address': '',
          'email_address': auth.currentUser?.email ?? email,
          'profile_image': '',
          'created_at': FieldValue.serverTimestamp(),
          'role': 'admin',
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
    try {
      final String email = profileData['email_address'] ?? auth.currentUser?.email ?? '';
      if (email.isEmpty) {
        throw Exception("Email address is missing in profile data");
      }

      // Update field `profile_image` di Firestore
      await _firestore.collection('Accounts').doc(email).update({'profile_image': imageUrl});

      // Update juga local data agar sinkron
      profileData['profile_image'] = imageUrl;
    } catch (e) {
      throw Exception('Failed to update profile image in Firestore: $e');
    }
  }

  // Method untuk memperbarui profil di Firestore
  Future<void> updateProfile(String firstName, String lastName, String phoneNumber, String address) async {
    try {
      // Validasi apakah semua field terisi (tidak termasuk email karena read-only)
      if (firstName.trim().isEmpty || lastName.trim().isEmpty || phoneNumber.trim().isEmpty || address.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please fill in all fields before saving.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return; // Hentikan proses jika ada field kosong
      }

      isLoading.value = true;

      // Validasi email
      final String email = profileData['email_address'] ?? auth.currentUser?.email ?? '';
      if (email.isEmpty) {
        throw Exception("Email address is missing.");
      }

      final updatedData = {
        'firstname': firstName.trim(),
        'lastname': lastName.trim(),
        'phone_number': phoneNumber.trim(),
        'address': address.trim(),
        'profile_image': profileImage.value,
      };

      await _firestore.collection('Accounts').doc(email).update(updatedData);

      // Update local profileData
      profileData.assignAll(updatedData);
      selectedAddress.value = address;

      Get.snackbar(
        'Success',
        'Profile updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
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
