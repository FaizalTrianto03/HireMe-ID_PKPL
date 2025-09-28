import 'package:HireMe_Id/utils/setup_mic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:HireMe_Id/utils/webdav_service.dart';
import '../../../data/job_categories.dart';
import '../../../data/job_data.dart';
import 'browse_2_view.dart';
import 'browse_3_view.dart';

class BrowseView extends StatefulWidget {
  @override
  _BrowseViewState createState() => _BrowseViewState();
}

class _BrowseViewState extends State<BrowseView> {
  final TextEditingController _jobController = TextEditingController();
  List<Job> searchResults = [];
  bool isSearching = false;
  List<Job> recommendedJobs = [];
  List<Map<String, dynamic>> dynamicCategories = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeDynamicCategories();
    });

    recommendedJobs = jobList.where((job) => job.isRecommended).toList();
  }

  // Tambahkan fungsi refreshJobList
  Future<void> refreshJobList() async {
    try {
      // Ambil data dari Firebase
      QuerySnapshot snapshot = await _firestore.collection('Jobs').get();

      List<Job> updatedList =
          List.from(jobList); // Buat copy dari list yang ada

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('jobs')) {
          List<dynamic> firebaseJobs = data['jobs'];
          for (var jobData in firebaseJobs) {
            Job newJob = Job(
              idjob: jobData['id'] ?? '',
              position: jobData['position'] ?? '',
              companyName: jobData['companyName'] ?? '',
              location: jobData['location'] ?? '',
              companyLogoPath: jobData['companyLogoPath'] ?? '',
              jobType: jobData['jobType'] ?? '',
              categories: List<String>.from(jobData['categories'] ?? []),
              jobDetails: JobDetails(
                jobDescription: jobData['jobDetails']['jobDescription'] ?? '',
                requirements: List<String>.from(
                    jobData['jobDetails']['requirements'] ?? []),
                location: jobData['jobDetails']['location'] ?? '',
                facilities: List<String>.from(
                    jobData['jobDetails']['facilities'] ?? []),
                companyDetails: CompanyDetails(
                  aboutCompany: jobData['jobDetails']['companyDetails']
                          ['aboutCompany'] ??
                      '',
                  website:
                      jobData['jobDetails']['companyDetails']['website'] ?? '',
                  industry:
                      jobData['jobDetails']['companyDetails']['industry'] ?? '',
                  companyGalleryPaths: List<String>.from(
                    jobData['jobDetails']['companyDetails']
                            ['companyGalleryPaths'] ??
                        [],
                  ),
                ),
              ),
              salary: jobData['salary'] ?? '',
              isApplied: jobData['isApplied'] ?? false,
              applyStatus: jobData['applyStatus'] ?? 'inProcess',
              isRecommended: jobData['isRecommended'] ?? false,
              isSaved: jobData['isSaved'] ?? false,
            );

            // Cek duplikasi sebelum menambahkan
            if (!updatedList.any((job) =>
                job.position.toLowerCase() == newJob.position.toLowerCase())) {
              updatedList.add(newJob);
            }
          }
        }
      }

      // Update state
      setState(() {
        jobList = updatedList;
        recommendedJobs = jobList.where((job) => job.isRecommended).toList();
      });
    } catch (e) {
      print('Error refreshing jobs: $e');
      // Bisa tambahkan showing error message ke user disini
    }
  }

  Future<void> _initializeDynamicCategories() async {
    await refreshJobList();

    // Buat map untuk menghitung jobs per kategori
    Map<String, int> categoryJobCount = {};

    // Hitung total jobs untuk setiap kategori
    for (var job in jobList) {
      for (var category in job.categories) {
        categoryJobCount[category] = (categoryJobCount[category] ?? 0) + 1;
      }
    }

    setState(() {
      dynamicCategories = [
        {
          'name': 'All',
          'icon': Icons.grid_view,
          'iconPath': null,
          // Total jobs dari initialList
          'availableJobs': jobList.length,
        },
        ...jobCategoriesData.map((category) {
          return {
            'name': category.name,
            'icon': null,
            'iconPath': category.iconPath,
            // Ambil count dari map, default 0 jika tidak ada
            'availableJobs': categoryJobCount[category.name] ?? 0,
          };
        }).toList(),
      ];
    });
  }

  void handleSearch() {
    String jobQuery = _jobController.text.toLowerCase();
    setState(() {
      searchResults = jobList.where((job) {
        return job.position.toLowerCase().contains(jobQuery);
      }).toList();
      isSearching = true;
    });
  }

  void resetSearch() {
    setState(() {
      _jobController.clear();
      searchResults = [];
      isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Discover Jobs',
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
                  Tab(text: 'Categories'),
                  Tab(text: 'Recommendations'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Job Categories
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Box
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _jobController,
                            onChanged: (value) => handleSearch(),
                            decoration: const InputDecoration(
                              hintText: 'Search by job title...',
                              hintStyle:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                        ),
                        if (isSearching)
                          GestureDetector(
                            onTap: resetSearch,
                            child: const Icon(Icons.close,
                                color: Colors.grey, size: 20),
                          ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () async {
                            final mic =
                                SpeechService(); // Panggil SpeechService
                            if (mic.isListening) {
                              mic.stopListening();
                            } else {
                              await mic.startListening((result) {
                                setState(() {
                                  _jobController.text =
                                      result; // Masukkan hasil suara ke TextField
                                  handleSearch(); // Jalankan pencarian otomatis
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
                  const SizedBox(height: 24),
                  // Search Results or Job Categories Grid
                  Expanded(
                    child: isSearching
                        ? searchResults.isEmpty
                            ? const Center(
                                child: Text(
                                  'No results found.',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                itemCount: searchResults.length,
                                itemBuilder: (context, index) {
                                  final job = searchResults[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Get.to(() => Browse3View(
                                          job: job, idjob: job.idjob));
                                    },
                                    child: Card(
                                      color: Colors
                                          .white, // Pure warna putih untuk background card
                                      margin: const EdgeInsets.only(bottom: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: job.companyLogoPath
                                                      .startsWith('http')
                                                  ? Image.network(
                                                      job.companyLogoPath,
                                                      height: 50,
                                                      width: 50,
                                                      fit: BoxFit.cover,
                                                      headers: job.companyLogoPath.contains('/remote.php/dav/files/')
                                                          ? WebDAVService.authHeaders()
                                                          : null,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
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
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    job.position,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${job.companyName} • ${job.location}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade600,
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
                                },
                              )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 3 / 2.5,
                            ),
                            itemCount: dynamicCategories.length,
                            itemBuilder: (context, index) {
                              final category = dynamicCategories[index];
                              return GestureDetector(
                                onTap: () {
                                  Get.to(() => Browse2View(
                                      categoryName: category['name']));
                                },
                                child: Container(
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
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        category['icon'] != null
                                            ? Icon(
                                                category['icon'],
                                                size: 40,
                                                color: const Color(0xFF6B34BE),
                                              )
                                            : Image.asset(
                                                category['iconPath'] ??
                                                    'assets/icons/default.png',
                                                height: 40,
                                                color: const Color(0xFF6B34BE),
                                              ),
                                        const SizedBox(height: 12),
                                        Text(
                                          category['name'],
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${category['availableJobs']} Jobs',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  )
                ],
              ),
            ),
            // Tab 2: Recommended Jobs
            ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              itemCount: recommendedJobs.length,
              itemBuilder: (context, index) {
                final job = recommendedJobs[index];
                return GestureDetector(
                  onTap: () {
                    Get.to(() => Browse3View(job: job, idjob: job.idjob));
                  },
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
