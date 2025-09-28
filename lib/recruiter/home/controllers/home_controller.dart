import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeControllerRecruiter extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var recruiterName = ''.obs; // Observable untuk nama lengkap recruiter
  var companyName = ''.obs; // Observable untuk nama perusahaan
  var jobCount = 0.obs; // Observable untuk jumlah pekerjaan
  var isLoading = false.obs; // Observable untuk status loading

    var allApplications = <Map<String, dynamic>>[].obs; // Tambahkan ini


  // Tambahkan fetch logic ke onInit
  @override
  void onInit() {
    super.onInit();
    fetchApplications();
  }


  /// Fetch data lamaran dari Firestore
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

  // Fungsi mengambil data recruiter dan jumlah pekerjaan
  Future<void> fetchHomeData() async {
    try {
      isLoading.value = true;

      final String? email = auth.currentUser?.email;
      if (email == null) {
        throw Exception("User not logged in.");
      }

      // Ambil data recruiter
      final recruiterDoc =
          await firestore.collection('Accounts').doc(email).get();

      if (recruiterDoc.exists) {
        // Gabungkan firstname dan lastname
        final String firstName = recruiterDoc.data()?['firstname'] ?? 'Unknown';
        final String lastName = recruiterDoc.data()?['lastname'] ?? 'User';
        recruiterName.value = '$firstName $lastName';

        companyName.value = recruiterDoc.data()?['company_name'] ?? 'Unknown Company';
      } else {
        throw Exception("Recruiter profile not found.");
      }

      // Ambil data jumlah pekerjaan
      final jobsDoc = await firestore.collection('Jobs').doc(email).get();
      if (jobsDoc.exists) {
        final jobsData = jobsDoc.data()?['jobs'] as List<dynamic>? ?? [];
        jobCount.value = jobsData.length;
      } else {
        jobCount.value = 0;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch home data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
