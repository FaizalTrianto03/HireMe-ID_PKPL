import 'package:HireMe_Id/login/browse/views/browse_3_view.dart';
import 'package:HireMe_Id/login/browse/controllers/saved_job_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/job_data.dart';

class AppliedView extends StatelessWidget {
  final SavedJobController _savedJobController = Get.put(SavedJobController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Applications',
            style: TextStyle(
              fontFamily: 'RedHatDisplay',
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              child: const TabBar(
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 4, color: Color(0xFF6B34BE)),
                  insets: EdgeInsets.symmetric(horizontal: 40),
                ),
                labelColor: Color(0xFF6B34BE),
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(text: 'List Job'),
                  Tab(text: 'Saved Job'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: List Job
            _buildListJobPlaceholder(),

            // Tab 2: Saved Job
            Obx(() {
  final savedJobIds = _savedJobController.savedJobs.toList();
  final savedJobs = jobList
      .where((job) => savedJobIds.contains(job.idjob))
      .toList();

  if (savedJobs.isEmpty) {
    return const Center(
      child: Text(
        'No saved jobs.',
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.only(top: 20), // Padding atas sebelum ListView
    child: ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16), // Padding kiri-kanan
      itemCount: savedJobs.length,
      itemBuilder: (context, index) {
        final job = savedJobs[index];

        return GestureDetector(
          onTap: () {
            Get.to(() => Browse3View(job: job, idjob: job.idjob));
          },
          child: _buildJobCard(job),
        );
      },
    ),
  );
})

          ],
        ),
      ),
    );
  }

  // Placeholder untuk List Job
  Widget _buildListJobPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'Seharusnya di sini muncul card untuk\nmelihat proses apply job.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Job Card Widget
 Widget _buildJobCard(Job job) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2), // Padding kiri-kanan
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo Perusahaan
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: job.companyLogoPath.startsWith('http')
                  ? Image.network(
                      job.companyLogoPath,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/default_logo.png',
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      job.companyLogoPath,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 16),

            // Detail Job
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.position,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${job.companyName} • ${job.location}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.jobType,
                    style: const TextStyle(
                      color: Color(0xFF6B34BE),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}
