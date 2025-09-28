import 'package:HireMe_Id/login/browse/views/browse_3_view.dart';
import 'package:HireMe_Id/login/browse/controllers/saved_job_controller.dart';
import 'package:HireMe_Id/login/applied/controllers/job_application_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:HireMe_Id/utils/webdav_service.dart';
import '../../../data/job_data.dart';

class AppliedView extends StatefulWidget {
  @override
  State<AppliedView> createState() => _AppliedViewState();
}

class _AppliedViewState extends State<AppliedView> {
  final SavedJobController _savedJobController = Get.put(SavedJobController());
  final JobApplicationController _jobApplicationController =
      Get.put(JobApplicationController());

  bool bulkMode = false;
  final RxSet<String> selectedIds = <String>{}.obs;

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
            Obx(() {
  if (_jobApplicationController.appliedJobs.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E0FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.list_alt,
              size: 48,
              color: Color(0xFF6B34BE),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada pekerjaan yang dilamar.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  return ListView.builder(
    padding: const EdgeInsets.all(16.0),
    itemCount: _jobApplicationController.appliedJobs.length,
    itemBuilder: (context, index) {
      var job = _jobApplicationController.appliedJobs[index];
      return GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Application Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailSection(
                            'Position',
                            job['position'] ?? 'Unknown Position',
                            Icons.work_rounded,
                          ),
                          _buildDetailSection(
                            'Status',
                            job['status'] ?? 'Unknown Status',
                            Icons.pending_actions_rounded,
                          ),
                          _buildDetailSection(
                            'Applicant Email',
                            job['applicantEmail'] ?? 'Unknown Email',
                            Icons.email_rounded,
                          ),
                          _buildDetailSection(
                            'Recruiter Email',
                            job['recruiterEmail'] ?? 'Unknown Email',
                            Icons.business_center_rounded,
                          ),
                          _buildDetailSection(
                            'Application Reason',
                            job['reason'] ?? 'No reason provided',
                            Icons.description_rounded,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Uploaded Files',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (job['cvFiles'] != null && (job['cvFiles'] as List).isNotEmpty)
                            ...(job['cvFiles'] as List).map((file) => _buildFileItem(
                                  file.toString(),
                                  Icons.file_present_rounded,
                                  const Color(0xFFE8E0FF),
                                  const Color(0xFF6B34BE),
                                )),
                          if (job['videoFile'] != null)
                            _buildFileItem(
                              job['videoFile'].toString(),
                              Icons.video_file_rounded,
                              const Color(0xFFFFE8E0),
                              const Color(0xFFBE3434),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E0FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.work_outline,
                        color: Color(0xFF6B34BE),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['position'] ?? 'Unknown Position',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6C5FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Status: ${job['status'] ?? 'Pengajuan'}',
                              style: const TextStyle(
                                color: Color(0xFF6B34BE),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.grey,
                      ),
                      onSelected: (value) async {
                        if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                'Cancel Application',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              content: const Text(
                                'Are you sure you want to cancel this application? This action cannot be undone.',
                                style: TextStyle(color: Colors.black54),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text(
                                    'No',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Yes',
                                    style: TextStyle(
                                      color: Color(0xFF6B34BE),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await _jobApplicationController.deleteApplication(index);
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: const [
                              Icon(
                                Icons.cancel_outlined,
                                color: Colors.red,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Cancel Application',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Applied At: ${job['timestamp'] != null ? _formatTimestamp(job['timestamp']) : 'Unknown'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}),

            // Tab 2: Saved Job
            Obx(() {
              final savedJobIds = _savedJobController.savedJobs.toList();
              final savedJobs = jobList
                  .where((job) => savedJobIds.contains(job.idjob))
                  .toList();

              if (savedJobs.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.bookmark_border,
                  message: 'Belum ada pekerjaan yang disimpan.',
                );
              }

              return Column(
                children: [
                  // Bulk action bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        if (!bulkMode)
                          OutlinedButton.icon(
                            onPressed: () => setState(() => bulkMode = true),
                            icon: const Icon(Icons.checklist),
                            label: const Text('Bulk Edit'),
                          )
                        else ...[
                          TextButton(
                            onPressed: () {
                              setState(() {
                                bulkMode = false;
                                selectedIds.clear();
                              });
                            },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              if (selectedIds.length == savedJobs.length) {
                                selectedIds.clear();
                              } else {
                                selectedIds
                                    .assignAll(savedJobs.map((e) => e.idjob));
                              }
                            },
                            child: Obx(() => Text(
                                  selectedIds.length == savedJobs.length
                                      ? 'Unselect All'
                                      : 'Select All (${savedJobs.length})',
                                )),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: selectedIds.isEmpty
                                ? null
                                : () async {
                                    final ids = selectedIds.toList();
                                    await _savedJobController.unsaveMultiple(ids);
                                    setState(() {
                                      selectedIds.clear();
                                      bulkMode = false;
                                    });
                                  },
                            icon: const Icon(Icons.bookmark_remove),
                            label: Obx(() => Text('Unsave Selected (${selectedIds.length})')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B34BE),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: savedJobs.length,
                      itemBuilder: (context, index) {
                        final job = savedJobs[index];
                        final isSelected = selectedIds.contains(job.idjob);
                        return GestureDetector(
                          onTap: () {
                            if (bulkMode) {
                              setState(() {
                                if (isSelected) {
                                  selectedIds.remove(job.idjob);
                                } else {
                                  selectedIds.add(job.idjob);
                                }
                              });
                            } else {
                              Get.to(() => Browse3View(job: job, idjob: job.idjob));
                            }
                          },
                          child: Stack(
                            children: [
                              _buildJobCard(job),
                              if (bulkMode)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Checkbox(
                                    value: isSelected,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          selectedIds.add(job.idjob);
                                        } else {
                                          selectedIds.remove(job.idjob);
                                        }
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Fungsi untuk memformat timestamp menjadi string yang dapat dibaca
  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
    } catch (e) {
      return "Invalid date";
    }
  }

  // Placeholder untuk List Job
  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
                        headers: job.companyLogoPath.contains('/remote.php/dav/files/')
                            ? WebDAVService.authHeaders()
                            : null,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 50,
                            width: 50,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.help_outline,
                              color: Colors.grey,
                              size: 24,
                            ),
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
  
 
Widget _buildDetailSection(String label, String value, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: const Color(0xFF6B34BE),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildFileItem(String fileName, IconData icon, Color bgColor, Color iconColor) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            fileName,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}
}
