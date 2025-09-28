import 'package:HireMe_Id/admin/event/views/detail_event.dart';
import 'package:HireMe_Id/utils/setup_mic.dart';
import 'package:flutter/material.dart';
import 'package:HireMe_Id/utils/webdav_service.dart';
import 'package:get/get.dart';
import '../controllers/home_controller_login.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../data/job_data.dart'; // Import untuk data pekerjaan
import '../../browse/views/browse_3_view.dart'; // Import halaman Browse3View

class HomeViewLoggedIn extends StatefulWidget {
  @override
  _HomeViewLoggedInState createState() => _HomeViewLoggedInState();
}

class _HomeViewLoggedInState extends State<HomeViewLoggedIn> {
  final HomeControllerLogin controller = Get.put(HomeControllerLogin());
  final AuthController authController = Get.put(AuthController());

  final TextEditingController _searchController = TextEditingController();
  List<Job> searchResults = [];
  bool isSearching = false;

  void initState() {
    super.initState();
    // Memanggil fetchEventData untuk memuat event dari Firestore
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchEventData();
    });
  }

  void handleSearch(String query) {
    if (query.isNotEmpty) {
      setState(() {
        searchResults = jobList
            .where((job) =>
                job.position.toLowerCase().contains(query.toLowerCase()))
            .toList();
        isSearching = true;
      });
    } else {
      resetSearch();
    }
  }

  void resetSearch() {
    setState(() {
      _searchController.clear();
      searchResults = [];
      isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD6C5FF), Color(0xFF6B34BE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Content Area
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Text
                  const Text(
                    "HireMe.id",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Find Your Dream Job Here!",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Search Box
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            size: 30, color: Color(0xFF6B34BE)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: handleSearch,
                            decoration: const InputDecoration(
                              hintText: "Search for jobs...",
                              hintStyle:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
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
                                SpeechService(); // Memanggil SpeechService
                            if (mic.isListening) {
                              mic.stopListening();
                            } else {
                              await mic.startListening((result) {
                                setState(() {
                                  _searchController.text = result;
                                  handleSearch(
                                      result); // Proses pencarian otomatis
                                });
                              });
                            }
                            setState(() {}); // Untuk update UI status icon mic
                          },
                          child: Icon(
                            SpeechService().isListening
                                ? Icons.mic
                                : Icons.mic_none,
                            size: 30,
                            color: SpeechService().isListening
                                ? Colors.red
                                : const Color(0xFF6B34BE),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

// 🔄 Slider Event
                  Obx(() {
                   
                    if (controller.eventList.isEmpty) {
                      return const Center(
                        child: Text(
                          "",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        SizedBox(
                          height: 80, // Tinggi slider dikurangi
                          child: PageView.builder(
                            controller: PageController(viewportFraction: 1),
                            onPageChanged: (index) {
                              controller.currentPage.value = index;
                            },
                            itemCount: controller.eventList.length,
                            itemBuilder: (context, index) {
                              final event = controller.eventList[index];
                              final String imageUrl =
                                  (event['images'] != null &&
                                          (event['images'] as List).isNotEmpty)
                                      ? event['images'][0]
                                      : 'https://via.placeholder.com/150';

                              return GestureDetector(
                                onTap: () {
                                  Get.to(() =>
                                      DetailEventPage(eventId: event['id']));
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 3,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Stack(
                                      children: [
                                        // Gambar Event
                                        Positioned.fill(
                                          child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              alignment: Alignment.center,
                                              width: double.infinity,
                                              height: double.infinity,
                                              headers: WebDAVService.authHeaders(),
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const Center(
                                                  child: Icon(
                                                      Icons.image_not_supported,
                                                      size: 24,
                                                      color: Colors.grey),
                                                );
                                              },
                                            ),
                                        ),

                                        // Overlay hitam transparan
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withOpacity(0.7),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Judul Event
                                        Positioned(
                                          bottom: 8,
                                          left: 8,
                                          right: 8,
                                          child: Text(
                                            event['title'] ?? 'Tanpa Judul',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
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
                        // Dots indicator
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            controller.eventList.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: controller.currentPage.value == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 30),

                  // Content based on Search
                  if (isSearching)
                    searchResults.isEmpty
                        ? const Center(
                            child: Text(
                              "No jobs found.",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final job = searchResults[index];
                              return GestureDetector(
                                onTap: () {
                                  Get.to(() =>
                                      Browse3View(job: job, idjob: job.idjob));
                                },
                                child: Card(
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
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Image.asset(
                                                      'assets/images/default_logo.png', // gambar default jika error
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
                                                "${job.companyName} • ${job.location}",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
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
                  else
                    Column(
                      children: [
                        // Image with Shadow
                        Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.25,
                              maxWidth: MediaQuery.of(context).size.width,
                            ),
                            child: Image.asset(
                              'assets/images/homepage-image.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Subtitle Text
                        const Text(
                          "Explore thousands of job offers from top companies.",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),

                        // Popular Jobs Image
                        Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.25,
                              maxWidth: MediaQuery.of(context).size.width,
                            ),
                            child: Image.asset(
                              'assets/images/most-popular-job.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
