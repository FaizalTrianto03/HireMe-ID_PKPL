import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/job_data.dart';
import '../controllers/job_application_controller.dart';

class JobApplicationView extends StatelessWidget {
  final Job job; // Data pekerjaan dari Browse3View
  final String idjob; // ID pekerjaan dari Browse3View

  // Konstruktor menerima parameter dari Browse3View
  JobApplicationView({
    required this.job,
    required this.idjob,
  });

  // Menghubungkan dengan controller
  final JobApplicationController controller =
      Get.put(JobApplicationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Job Application',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menampilkan informasi pekerjaan
            Text(
              'Position: ${job.position}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Company Name: ${job.companyName}'),
            const SizedBox(height: 8),
            Text('Address: ${job.location}'),
            const SizedBox(height: 8),
            Text('Salary: ${job.salary}'),
            const SizedBox(height: 8),
            Text('Job Type: ${job.jobType}'),
            const SizedBox(height: 16),

            // Alasan melamar
            const Text(
              'Why are you applying for this job?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter your reason here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Upload CV
            const Text(
              'Upload CV (Max 3 files, PDF only):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => controller.pickCVFiles(),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child:
                      Text('Select CV Files', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
            Obx(() => Column(
                  children: controller.cvFiles.map((file) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(file.name)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => controller.removeCVFile(file),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )),
            const SizedBox(height: 16),

            // Upload Video
            const Text(
              'Upload Introduction Video (1 file):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => controller.pickVideoFile(),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child:
                      Text('Select Video File', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
            Obx(() => controller.videoFile.value != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(controller.videoFile.value!.name)),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.removeVideoFile(),
                        ),
                      ],
                    ),
                  )
                : const SizedBox()),

            const SizedBox(height: 16),

            // Tombol submit
            ElevatedButton(
              onPressed: () async {
                // Submit aplikasi
                await controller.submitApplication(
                  idjob,
                  job.position,
                );

                // Bersihkan form dan file yang diunggah
                controller.reasonController.clear();
                controller.cvFiles.clear();
                controller.videoFile.value = null;

                // Tampilkan modal bottom sheet dengan animasi yang lebih smooth
                showModalBottomSheet(
                  context: context,
                  isDismissible: false,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Success Animation Container
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8E0FF),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF6B34BE),
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Success Title with Emoji
                            RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Success ',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '🎉',
                                    style: TextStyle(
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Success Message
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: const Text(
                                'Yay! Congratulations, your application has been successfully submitted.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            // OK Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Tutup modal
                                  Get.back(); // Navigasi kembali
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6B34BE),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'OK, Great!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B34BE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.send_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Submit Application',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
