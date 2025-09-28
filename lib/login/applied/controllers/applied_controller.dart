 
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
class AppliedLoginController extends GetxController {
  var appliedJobs = <Map<String, dynamic>>[].obs;
  @override
  void onInit() {
    super.onInit();
    fetchAppliedJobs();
  }
  // Fungsi untuk membaca data lamaran dari Firestore
  void fetchAppliedJobs() {
    FirebaseFirestore.instance
        .collection('applications')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      appliedJobs.value = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'email': doc['email'] ?? '',
          'position': doc['position'] ?? '',
          'company': doc['company'] ?? '',
          'status': doc['status'] ?? 'Pengajuan',
          'information': doc['information'] ?? '',
          'uploadedCV': doc['uploadedCV'] ?? '',
          'appliedAt': doc['appliedAt'] != null
              ? doc['appliedAt'].toDate().toString().split(' ')[0]
              : 'Unknown',
        };
      }).toList();
    });
  }
  // Fungsi untuk memilih file CV baru
  Future<String> pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = 'resumes/${DateTime.now().millisecondsSinceEpoch}.pdf';
      TaskSnapshot snapshot = await FirebaseStorage.instance.ref(fileName).putFile(file);
      return await snapshot.ref.getDownloadURL();
    }
    return '';
  }
  // Fungsi untuk mengedit lamaran
  Future<void> editApplication(String id, String newInformation) async {
  try {
    String newFileUrl = await pickAndUploadFile();
    Map<String, dynamic> updateData = {'information': newInformation};
    if (newFileUrl != '') {
      updateData['uploadedCV'] = newFileUrl;
    }
    await FirebaseFirestore.instance.collection('applications').doc(id).update(updateData);
    Get.snackbar('Sukses', 'Lamaran berhasil diperbarui.');
  } catch (e) {
    Get.snackbar('Error', 'Gagal memperbarui lamaran: $e');
  }
}
  // Fungsi untuk membatalkan lamaran
  Future<void> deleteApplication(String id) async {
    try {
      await FirebaseFirestore.instance.collection('applications').doc(id).delete();
      Get.snackbar('Sukses', 'Lamaran berhasil dibatalkan.');
    } catch (e) {
      Get.snackbar('Error', 'Gagal membatalkan lamaran: $e');
    }
  }
  
}