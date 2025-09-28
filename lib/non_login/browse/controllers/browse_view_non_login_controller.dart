import 'package:get/get.dart';
import '../../../data/job_data.dart';

class BrowseViewNonLoginController extends GetxController {
  var searchQuery = ''.obs; // Query pencarian
  var searchResults = <Job>[].obs; // Hasil pencarian

  // Fungsi untuk melakukan pencarian
  void searchJobs(String query) {
    searchQuery.value = query;
    searchResults.value = jobList.where((job) {
      return job.position.toLowerCase().contains(query.toLowerCase()) ||
          job.companyName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
