import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/applied_controller.dart';

class AppliedView extends StatelessWidget {
  final AppliedController controller = Get.put(AppliedController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          title: const Text(
            'Applied Status',
            style: TextStyle(
              fontFamily: 'RedHatDisplay',
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(135),
            child: Obx(() {
              final newTodayCount = controller.countNewTodayApplications();
              final inReviewCount =
                  controller.countApplicationsByStatus('Review');
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildStatCard(
                            'Total Applicants',
                            controller.allApplications.length.toString(),
                            Colors.purple),
                        _buildStatCard(
                            'New Today', newTodayCount.toString(), Colors.blue),
                        _buildStatCard('In Review', inReviewCount.toString(),
                            Colors.orange),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border:
                          Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
                    ),
                    child: TabBar(
                      isScrollable: true,
                      indicatorColor: const Color(0xFF6B34BE),
                      indicatorWeight: 3,
                      labelColor: const Color(0xFF6B34BE),
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        _buildTab('Pengajuan'),
                        _buildTab('Review'),
                        _buildTab('Proses'),
                        _buildTab('Diterima'),
                        _buildTab('Ditolak'),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent('Pengajuan'),
            _buildTabContent('Review'),
            _buildTabContent('Proses'),
            _buildTabContent('Diterima'),
            _buildTabContent('Ditolak'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label) {
  return Tab(
    child: Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
  );
}

Widget _buildTabContent(String status) {
  return Obx(() {
    final filteredList = controller.filterApplicationsByStatus(status);
    if (filteredList.isEmpty) {
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
                Icons.folder_open_rounded,
                size: 48,
                color: Color(0xFF6B34BE),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada lamaran di status "$status"',
              style: const TextStyle(
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
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        var application = filteredList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
            padding: const EdgeInsets.all(16),
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
                        Icons.account_circle_rounded,
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
                            application['position'],
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
                              'Status: ${application['status']}',
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
                        if (value == 'edit') {
                          if (application['id'] != null && application['status'] != null) {
                            await _showStatusUpdateDialog(
                              context,
                              application['id'],
                              application['status'],
                            );
                          } else {
                            Get.snackbar('Error', 'Data tidak lengkap untuk edit status.');
                          }
                        } else if (value == 'download') {
                          final url = application['uploadedCV'];
                          if (url != null && url.isNotEmpty) {
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            } else {
                              Get.snackbar('Error', 'Gagal membuka dokumen CV.');
                            }
                          } else {
                            Get.snackbar('Error', 'CV tidak tersedia.');
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: const [
                              Icon(
                                Icons.edit_rounded,
                                color: Color(0xFF6B34BE),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Edit Status',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'download',
                          child: Row(
                            children: const [
                              Icon(
                                Icons.download_rounded,
                                color: Color(0xFF6B34BE),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Download CV',
                                style: TextStyle(
                                  color: Colors.black87,
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
                  'Pelamar: ${application['applicantEmail']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Applied At: ${application['timestamp']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  });
}

Future<void> _showStatusUpdateDialog(
  BuildContext context,
  String id,
  String currentStatus,
) async {
  final statuses = ['Pengajuan', 'Review', 'Proses', 'Diterima', 'Ditolak'];
  String? selectedStatus = currentStatus;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text(
              'Update Status Lamaran',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 20,
              ),
            ),
            content: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                value: selectedStatus,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6B34BE)),
                underline: const SizedBox(),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                items: statuses.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  controller.updateApplicationStatus(id, selectedStatus!);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    color: Color(0xFF6B34BE),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
}
