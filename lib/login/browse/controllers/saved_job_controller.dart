import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SavedJobController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxSet<String> savedJobs = <String>{}.obs;

  // Ambil email user saat ini
  String? get currentUserEmail => _auth.currentUser?.email;

  @override
  void onInit() {
    super.onInit();
    fetchSavedJobs();
  }

  // Fetch saved jobs dari Firestore
  Future<void> fetchSavedJobs() async {
    if (currentUserEmail == null) return;

    final doc = await _firestore.collection('savedjobs').doc(currentUserEmail).get();
    if (doc.exists) {
      final List<dynamic> jobs = doc.data()?['idjobs'] ?? [];
      savedJobs.assignAll(jobs.cast<String>());
    }
  }

  // Save or Unsave job
  Future<void> toggleSavedJob(String idjob) async {
    if (currentUserEmail == null) return;

    try {
      if (savedJobs.contains(idjob)) {
        // Unsave job
        await _firestore.collection('savedjobs').doc(currentUserEmail).set({
          'idjobs': FieldValue.arrayRemove([idjob]),
        }, SetOptions(merge: true));
        savedJobs.remove(idjob);
        Get.snackbar('Removed', 'Job removed from saved jobs.');
      } else {
        // Save job
        await _firestore.collection('savedjobs').doc(currentUserEmail).set({
          'idjobs': FieldValue.arrayUnion([idjob]),
        }, SetOptions(merge: true));
        savedJobs.add(idjob);
        Get.snackbar('Saved', 'Job added to saved jobs.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update saved jobs: $e');
    }
  }

  // Check apakah job disimpan
  bool isJobSaved(String idjob) {
    return savedJobs.contains(idjob);
  }

  // Bulk unsave jobs
  Future<void> unsaveMultiple(List<String> ids) async {
    if (currentUserEmail == null || ids.isEmpty) return;
    try {
      await _firestore.collection('savedjobs').doc(currentUserEmail).set({
        'idjobs': FieldValue.arrayRemove(ids),
      }, SetOptions(merge: true));
      savedJobs.removeAll(ids.toSet());
      Get.snackbar('Updated', 'Removed ${ids.length} job(s) from saved.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to unsave selected jobs: $e');
    }
  }

//   Future<List<Job>> fetchSavedJobs() async {
//   final email = currentUserEmail;
//   if (email == null) return [];

//   final doc = await _firestore.collection('savedjobs').doc(email).get();
//   if (doc.exists) {
//     final List<dynamic> savedJobIds = doc.data()?['idjobs'] ?? [];
//     return jobs.where((job) => savedJobIds.contains(job.idjob)).toList();
//   }
//   return [];
// }

}
