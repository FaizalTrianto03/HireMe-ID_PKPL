import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeControllerLogin extends GetxController {
  // State untuk loading dan data event
  var isLoading = false.obs;
  final currentPage = 0.obs;
  var eventList = <Map<String, dynamic>>[].obs; // List untuk menyimpan event

  // ✅ Fungsi untuk Fetch Data Umum
  void fetchData() async {
    isLoading.value = true;
    try {
      await Future.delayed(Duration(seconds: 2)); // Simulasi delay fetching data
      print("Data berhasil diambil");
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Fungsi untuk Fetch Event Data
  Future<void> fetchEventData() async {
    isLoading.value = true;
    try {
      // Fetch event dengan kondisi statusGlobal & statusEvent bernilai true
      var querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('statusGlobal', isEqualTo: true)
          .where('statusEvent', isEqualTo: true)
          .get();

      // Mapping data event ke dalam eventList
      eventList.value = querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      print("Event data berhasil diambil");
    } catch (e) {
      print("Error fetching event data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Fungsi untuk Refresh Event Data
  Future<void> refreshEventData() async {
    print("Menyegarkan data event...");
    await fetchEventData();
  }
}
