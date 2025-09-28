import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AppliedController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var recruiterApplications =
      <Map<String, dynamic>>[].obs; // Data lamaran untuk recruiter
  var isLoading = false.obs; // Indikator loading
  var allApplications = <Map<String, dynamic>>[].obs; // Semua data lamaran

  @override
  void onInit() {
    super.onInit();
    fetchApplications();
  }

  /// Mengambil data lamaran dari Firestore
  Future<void> fetchApplications() async {
    isLoading.value = true;
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'You need to log in to view applications.');
        isLoading.value = false;
        return;
      }

      final recruiterEmail = currentUser.email;

      // Ambil dokumen dari Firestore
      FirebaseFirestore.instance
          .collection('AppliedJobs')
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        List<Map<String, dynamic>> applications = [];
        for (var doc in snapshot.docs) {
          final appliedArray = doc.get('applied') as List<dynamic>;
          for (var app in appliedArray) {
            if (app is Map<String, dynamic> &&
                app['recruiterEmail'] == recruiterEmail) {
              applications.add({
                ...app,
                'applicantDocId': doc.id, // Tambahkan ID dokumen pelamar
              });
            }
          }
        }
        allApplications.value = applications; // Update data lokal
        isLoading.value = false;
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch applications: $e');
      isLoading.value = false;
    }
  }

  /// Menghitung jumlah lamaran baru hari ini
  int countNewTodayApplications() {
    final today = DateTime.now();
    return allApplications.where((application) {
      final timestamp = application['timestamp'];
      if (timestamp == null) return false;
      final appliedDate = DateTime.tryParse(timestamp);
      return appliedDate != null &&
          appliedDate.year == today.year &&
          appliedDate.month == today.month &&
          appliedDate.day == today.day;
    }).length;
  }

  /// Menghitung jumlah lamaran berdasarkan status
  int countApplicationsByStatus(String status) {
    return allApplications.where((application) {
      return application['status'] == status;
    }).length;
  }

  /// Mengambil data lamaran berdasarkan status
  List<Map<String, dynamic>> filterApplicationsByStatus(String status) {
    return allApplications.where((application) {
      return application['status'] == status;
    }).toList();
  }

  /// Mengubah status lamaran pekerjaan
Future<void> updateApplicationStatus(String id, String newStatus) async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Get.snackbar('Error', 'You need to log in to update application status.');
      return;
    }

    final recruiterEmail = currentUser.email;

    // Ambil semua dokumen dari koleksi `AppliedJobs`
    final querySnapshot = await firestore.collection('AppliedJobs').get();

    bool statusUpdated = false; // Indikator apakah status berhasil diperbarui
    for (var doc in querySnapshot.docs) {
      final appliedArray = doc.data()['applied'] as List<dynamic>;

      // Cari data yang cocok dengan ID dan recruiterEmail
      for (var app in appliedArray) {
        if (app['id'] == id && app['recruiterEmail'] == recruiterEmail) {
          final oldStatus = app['status']; // Status lama sebelum diubah
          app['status'] = newStatus; // Ubah status ke yang baru

          // Debugging log perubahan status
          print('DEBUG: Found Application');
          print('DEBUG: ID: $id, Old Status: $oldStatus, New Status: $newStatus');
          print('DEBUG: Document ID (Applicant Email): ${doc.id}');

          statusUpdated = true; // Tandai bahwa status berhasil diubah
          break; // Keluar dari loop karena sudah ditemukan
        }
      }

      if (statusUpdated) {
        // Update array `applied` kembali ke Firestore
        await firestore.collection('AppliedJobs').doc(doc.id).update({
          'applied': appliedArray,
        });
        break; // Keluar dari loop dokumen karena sudah diupdate
      }
    }

    if (statusUpdated) {
      Get.snackbar('Success', 'Application status updated successfully!');
    } else {
      Get.snackbar('Error', 'Application not found or invalid ID.');
      print('DEBUG: No application found with ID: $id for recruiter: $recruiterEmail');
    }
  } catch (e) {
    Get.snackbar('Error', 'Failed to update application status: $e');
    print('DEBUG: Error occurred - $e');
  }
}



}
