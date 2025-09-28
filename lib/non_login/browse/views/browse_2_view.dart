import 'package:HireMe_Id/utils/setup_mic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:HireMe_Id/utils/webdav_service.dart';
import '../../../data/job_data.dart';
import 'browse_3_view.dart';

class Browse2View extends StatefulWidget {
  final String categoryName;

  Browse2View({required this.categoryName});

  @override
  _Browse2ViewState createState() => _Browse2ViewState();
}

class _Browse2ViewState extends State<Browse2View> {
  final TextEditingController _searchController = TextEditingController();
  List<Job> filteredJobs = [];

  @override
  void initState() {
    super.initState();
    _filterJobs(); // Filter pekerjaan berdasarkan kategori saat inisialisasi
  }

  // Filter pekerjaan berdasarkan kategori dan pencarian
  void _filterJobs() {
    final jobs = widget.categoryName == 'All'
        ? jobList
        : jobList
            .where((job) => job.categories.contains(widget.categoryName))
            .toList();

    setState(() {
      if (_searchController.text.isEmpty) {
        filteredJobs = jobs;
      } else {
        final query = _searchController.text.toLowerCase();
        filteredJobs = jobs
            .where((job) => job.position.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  // Reset pencarian
  void _resetSearch() {
    _searchController.clear();
    _filterJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.categoryName} Jobs',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // Bagian Pencarian
            Material(
              elevation: 3,
              shadowColor: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => _filterJobs(),
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
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: _resetSearch,
                        child: const Icon(Icons.close,
                            color: Colors.grey, size: 20),
                      ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () async {
                        final mic = SpeechService(); // Panggil SpeechService
                        if (mic.isListening) {
                          mic.stopListening();
                        } else {
                          await mic.startListening((result) {
                            setState(() {
                              _searchController.text =
                                  result; // Masukkan hasil suara ke TextField
                              _filterJobs(); // Jalankan pencarian otomatis
                            });
                          });
                        }
                        setState(() {}); // Perbarui UI untuk status mic
                      },
                      child: Icon(
                        SpeechService().isListening
                            ? Icons.mic
                            : Icons.mic_none,
                        color: SpeechService().isListening
                            ? Colors.red
                            : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Daftar pekerjaan berdasarkan kategori dan pencarian
            Expanded(
              child: filteredJobs.isEmpty
                  ? const Center(
                      child: Text(
                        'No jobs found.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredJobs.length,
                      itemBuilder: (context, index) {
                        final job = filteredJobs[index];
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => Browse3View(job: job));
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
                            child: Padding(
                              padding: const EdgeInsets.all(16),
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
                                                child: const Icon(Icons.help_outline, color: Colors.grey, size: 24),
                                              );
                                            },
                                          )
                                        : Container(
                                            height: 50,
                                            width: 50,
                                            color: Colors.grey.shade200,
                                            alignment: Alignment.center,
                                            child: const Icon(Icons.help_outline, color: Colors.grey, size: 24),
                                          ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Detail Pekerjaan
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          job.position,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${job.companyName}, ${job.location}',
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
                                              job.jobType,
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
                                            Text(
                                              job.categories.join(", "),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
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
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
