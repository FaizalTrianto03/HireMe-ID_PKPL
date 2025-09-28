import 'package:HireMe_Id/recruiter/explore/views/detail_job_view.dart';
import 'package:HireMe_Id/recruiter/explore/views/edit_job_view.dart';
import 'package:HireMe_Id/utils/setup_mic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart';
import 'package:HireMe_Id/utils/webdav_service.dart';
import 'add_job_view.dart';
import '../controllers/job_controller.dart';

class ExploreView extends StatelessWidget {
  final JobController jobController = Get.put(JobController());
  final HomeControllerRecruiter controller = Get.put(HomeControllerRecruiter());

  final RxString searchQuery = ''.obs;


  @override
  Widget build(BuildContext context) {
    // Pastikan `fetchJobs` dipanggil saat halaman dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
  if (jobController.jobs.isEmpty) {
    jobController.fetchJobs(); // Ambil daftar pekerjaan
  }
  if (jobController.recruiterData.isEmpty) {
    jobController.fetchRecruiterData(); // Ambil data recruiter
  }
});


    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'Manage Jobs',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),
  backgroundColor: Colors.white,
  elevation: 1,
  actions: [
    // Refresh Button
    IconButton(
      icon: const Icon(Icons.refresh, color: Color(0xFF6B34BE)),
      tooltip: 'Refresh Data',
      onPressed: () async {
        try {
          // Tampilkan loading dialog
          Get.dialog(
            Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF6B34BE),
              ),
            ),
            barrierDismissible: false,
          );

          // Panggil fetch data recruiter dan jobs
          final jobController = Get.find<JobController>();
          await jobController.fetchRecruiterData();
          await jobController.fetchJobs();

          // Tutup loading dialog
          Get.back();

          Get.snackbar(
            'Success',
            'Data successfully refreshed.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green[100],
            colorText: Colors.black,
            icon: const Icon(Icons.check_circle, color: Colors.green),
          );
        } catch (e) {
          Get.back(); // Tutup loading dialog jika error
          Get.snackbar(
            'Error',
            'Failed to refresh data: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100],
            colorText: Colors.black,
            icon: const Icon(Icons.error_outline, color: Colors.red),
          );
        }
      },
    ),

    // Add Job Button
    IconButton(
      icon: const Icon(Icons.add, color: Color(0xFF6B34BE)),
      tooltip: 'Add Job',
      onPressed: () {
        if (controller.recruiterName.value.isEmpty ||
            controller.companyName.value.isEmpty) {
          Get.snackbar(
            'Incomplete Information',
            'Harap lengkapi informasi di menu pengaturan profile sebelum menambahkan pekerjaan.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.yellow[100],
            colorText: Colors.black,
            icon: Icon(Icons.info_outline, color: Colors.yellow[800]),
          );
        } else {
          Get.to(() => AddJobView());
        }
      },
    ),
  ],
),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Obx(() {
                final micService =
                    SpeechService(); // Inisialisasi SpeechService
                return Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller:
                            TextEditingController(text: searchQuery.value),
                        onChanged: (value) {
                          searchQuery.value = value;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search by job title...',
                          hintStyle:
                              TextStyle(fontSize: 14, color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                    if (searchQuery.value.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          searchQuery.value = '';
                        },
                        child: const Icon(Icons.close,
                            color: Colors.grey, size: 20),
                      ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () async {
                        if (micService.isListening) {
                          micService.stopListening();
                        } else {
                          await micService.startListening((result) {
                            searchQuery.value =
                                result; // Masukkan hasil suara ke TextField
                          });
                        }
                      },
                      child: Icon(
                        micService.isListening ? Icons.mic : Icons.mic_none,
                        color:
                            micService.isListening ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 16),

            // Job List
            Expanded(
              child: Obx(() {
                if (jobController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6B34BE),
                    ),
                  );
                }

                if (jobController.jobs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.work_off_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No jobs posted yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Validasi data recruiterName dan companyName
                            if ((controller.recruiterName.value.isEmpty ||
                                    controller.recruiterName.value ==
                                        'Unknown User') ||
                                (controller.companyName.value.isEmpty ||
                                    controller.companyName.value ==
                                        'Unknown Company')) {
                              Get.snackbar(
                                'Incomplete Information',
                                'Harap lengkapi informasi di menu pengaturan profile sebelum menambahkan pekerjaan.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.yellow[100],
                                colorText: Colors.black,
                                icon: Icon(Icons.info_outline,
                                    color: Colors.yellow[800]),
                                duration: Duration(seconds: 3),
                              );
                            } else {
                              Get.to(() => AddJobView());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B34BE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Post a Job',
                            style: TextStyle(
                              color: Colors.white, // Warna teks putih
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = filteredJobs[index];
                    // Validasi data dan tampilkan item
                    final position = job['position'] ?? 'Unknown Position';
                    final companyName = job['companyName'] ?? 'Unknown Company';
                    final location = job['location'] ?? 'Unknown Location';
                    final jobType = job['jobType'] ?? 'N/A';
                    final categories = (job['categories'] as List<dynamic>?)
                            ?.cast<String>()
                            .join(", ") ??
                        'No Categories';
                    final companyLogoPath = job['companyLogoPath'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        // Navigasi ke DetailJobView dan kirim data job sebagai argument
                        Get.to(() => DetailJobView(), arguments: {'job': job});
                        print(
                            'Arguments sent to DetailJobView: ${Get.arguments}');
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Job Info Section
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Company Logo (hint: change company image in Profile -> Detail Profile)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: companyLogoPath.isNotEmpty
                                        ? Image.network(
                                            companyLogoPath,
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.cover,
                                            // provide Basic Auth header for WebDAV-hosted images
                                            headers: companyLogoPath.contains('/remote.php/dav/files/')
                                                ? WebDAVService.authHeaders()
                                                : null,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                height: 50,
                                                width: 50,
                                                color: const Color(0xFF6B34BE),
                                                child: const Icon(
                                                  Icons.business,
                                                  color: Colors.white,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            height: 50,
                                            width: 50,
                                            color: const Color(0xFF6B34BE),
                                            child: const Icon(
                                              Icons.business,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Job Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          position,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$companyName, $location',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.work_outline,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              jobType,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.category_outlined,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                categories,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Action Buttons
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Delete Button
                                  TextButton.icon(
                                    onPressed: () {
                                      Get.dialog(
                                        AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          title: const Row(
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                color: Colors.red,
                                                size: 28,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Delete Job',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Are you sure you want to delete this job posting?',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'This action cannot be undone.',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Get.back(),
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 12),
                                              ),
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: Colors.grey[800],
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                jobController.deleteJob(index);
                                                Get.back();
                                                Get.snackbar(
                                                  'Success',
                                                  'Job has been deleted successfully',
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  backgroundColor: Colors.green
                                                      .withOpacity(0.9),
                                                  colorText: Colors.white,
                                                  duration: const Duration(
                                                      seconds: 2),
                                                  margin:
                                                      const EdgeInsets.all(16),
                                                  borderRadius: 12,
                                                  icon: const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.white),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          actionsPadding:
                                              const EdgeInsets.fromLTRB(
                                                  16, 0, 16, 16),
                                        ),
                                        barrierDismissible: false,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    label: const Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),

                                  // Edit Button
                                  TextButton.icon(
                                    onPressed: () {
                                      Get.to(() => EditJobView(), arguments: {
                                        'index': index,
                                        'job': job
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Color(0xFF6B34BE),
                                      size: 20,
                                    ),
                                    label: const Text(
                                      'Edit',
                                      style: TextStyle(
                                        color: Color(0xFF6B34BE),
                                        fontSize: 14,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get filteredJobs {
    if (searchQuery.isEmpty) {
      return jobController.jobs;
    }
    return jobController.jobs
        .where((job) => (job['position'] ?? '')
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase()))
        .toList();
  }
}
