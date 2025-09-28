import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeController extends GetxController {
  // ✅ State Management
  var isLoading = false.obs; // Loading state
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

    // Cek jumlah dokumen yang diambil
    print("Jumlah event yang diambil: ${querySnapshot.docs.length}");

    // Mapping data event ke dalam eventList
    eventList.value = querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();

    // Debug: Print event data
    for (var event in eventList) {
      print("Event ID: ${event['id']}");
      print("Title: ${event['title']}");
      print("Global Status: ${event['statusGlobal']}");
      print("Event Status: ${event['statusEvent']}");
    }

    print("Event data berhasil diambil (Non-Login)");
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
