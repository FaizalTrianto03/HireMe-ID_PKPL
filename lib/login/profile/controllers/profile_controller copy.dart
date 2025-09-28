// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:url_launcher/url_launcher.dart';

// class ProfileController extends GetxController {
//   // Firestore instance
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Image picker instance
//   final ImagePicker _picker = ImagePicker();

//   // Observable untuk menyimpan data profil
//   var profileData = {}.obs;

//   // Status untuk memantau apakah data sedang dimuat
//   var isLoading = false.obs;

//   // Observable untuk menyimpan base64 gambar profil
//   var profileImage = ''.obs;

//   // Observable untuk menyimpan lokasi yang dipilih user
//   var selectedAddress = ''.obs;

//   // Method untuk mengambil profil dari Firestore berdasarkan email
//   Future<void> fetchProfile(String email) async {
//     try {
//       isLoading.value = true;

//       // Ambil dokumen dari Firestore
//       DocumentSnapshot doc =
//           await _firestore.collection('Accounts').doc(email).get();

//       if (doc.exists) {
//         // Jika dokumen ditemukan, simpan ke dalam observable map
//         profileData.value = doc.data() as Map<String, dynamic>;
//         profileImage.value = profileData['profile_image'] ?? '';
//         selectedAddress.value = profileData['address'] ?? '';
//       } else {
//         // Jika dokumen tidak ditemukan
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           Get.snackbar('Error', 'Profile not found for $email');
//         });
//         profileData.clear(); // Kosongkan data jika tidak ada
//       }
//     } catch (e) {
//       // Tangani error jika ada masalah dengan Firestore
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Get.snackbar('Error', 'Failed to fetch profile: $e');
//       });
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // Method untuk memilih gambar dari galeri atau file
//   Future<void> pickProfileImage() async {
//     try {
//       final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

//       if (image != null) {
//         File imageFile = File(image.path);

//         // Unggah gambar ke Firebase Storage
//         String imageUrl = await _uploadImageToStorage(imageFile);

//         // Simpan URL gambar ke Firestore
//         await _updateProfileImage(imageUrl);

//         profileImage.value = imageUrl;

//         Get.snackbar('Success', 'Profile image updated successfully.');
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to pick image: $e');
//     }
//   }

//   Future<String> _uploadImageToStorage(File imageFile) async {
//     try {
//       // Buat referensi ke Firebase Storage
//       final Reference storageRef = FirebaseStorage.instance
//           .ref()
//           .child('profile_images/${profileData['email_address']}.jpg');

//       // Unggah file
//       final UploadTask uploadTask = storageRef.putFile(imageFile);
//       final TaskSnapshot snapshot = await uploadTask;

//       // Ambil URL unduhan gambar
//       return await snapshot.ref.getDownloadURL();
//     } catch (e) {
//       throw Exception('Failed to upload image: $e');
//     }
//   }

//   // Method untuk memperbarui gambar profil di Firestore
//   Future<void> _updateProfileImage(String imageUrl) async {
//     try {
//       await _firestore
//           .collection('Accounts')
//           .doc(profileData['email_address'])
//           .update({'profile_image': imageUrl});

//       profileData['profile_image'] = imageUrl; // Perbarui data lokal
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to update profile image: $e');
//     }
//   }

//   // Method untuk memperbarui profil di Firestore
//   Future<void> updateProfile(
//     String firstName,
//     String lastName,
//     String phoneNumber,
//     String address,
//     String companyName,
//     String companyPosition,
//     String profileImageUrl,
//   ) async {
//     try {
//       isLoading.value = true;

//       final updatedData = {
//         'firstname': firstName,
//         'lastname': lastName,
//         'phone_number': phoneNumber,
//         'address': address,
//         'company_name': companyName,
//         'company_position': companyPosition,
//         'profile_image': profileImageUrl,
//       };

//       await _firestore
//           .collection('Accounts')
//           .doc(profileData['email_address'])
//           .update(updatedData);

//       profileData.assignAll(updatedData);
//       selectedAddress.value = address;

//       // Use addPostFrameCallback to safely display the snackbar after the build is complete
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Get.snackbar('Success', 'Profile updated successfully.');
//       });
//     } catch (e) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Get.snackbar('Error', 'Failed to update profile: $e');
//       });
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // Method untuk membuka Google Maps untuk memilih lokasi
//   Future<void> selectLocation() async {
//     const String googleMapsUrl = 'https://www.google.com/maps';
//     if (await canLaunch(googleMapsUrl)) {
//       await launch(googleMapsUrl);
//     } else {
//       Get.snackbar('Error', 'Could not open Google Maps');
//     }
//   }

//   // Method untuk menyimpan lokasi yang dipilih user
//   Future<void> saveSelectedLocation(String address) async {
//     try {
//       selectedAddress.value = address;

//       await _firestore
//           .collection('Accounts')
//           .doc(profileData['email_address'])
//           .update({'address': address});

//       profileData['address'] = address;

//       Get.snackbar('Success', 'Address updated successfully.');
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to save location: $e');
//     }
//   }

//   // Method untuk logout
//   Future<void> logout() async {
//     // Logika logout bisa ditambahkan di sini
//     Get.snackbar('Logout', 'User has been logged out.');
//   }

//   void viewProfileImage() {
//   if (profileImage.value.isNotEmpty) {
//     Get.dialog(
//       Dialog(
//         backgroundColor: Colors.transparent,
//         child: Stack(
//           children: [
//             // Close button di pojok kanan atas
//             Positioned(
//               right: 0,
//               top: 0,
//               child: GestureDetector(
//                 onTap: () => Get.back(),
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.black45,
//                     shape: BoxShape.circle,
//                   ),
//                   padding: const EdgeInsets.all(8),
//                   child: const Icon(
//                     Icons.close,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                 ),
//               ),
//             ),
//             // Image container
//             Container(
//               width: Get.width * 0.9,
//               height: Get.width * 0.9,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 image: DecorationImage(
//                   image: NetworkImage(profileImage.value),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       barrierColor: Colors.black.withOpacity(0.85), // Background gelap
//       barrierDismissible: true, // Bisa tutup dengan tap di luar
//       useSafeArea: true,
//     );
//   }
// }
// }
