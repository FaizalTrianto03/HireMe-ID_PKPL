import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:HireMe_Id/utils/webdav_service.dart';

class DetailJobView extends StatefulWidget {
  @override
  _DetailJobViewState createState() => _DetailJobViewState();
}

class _DetailJobViewState extends State<DetailJobView> {
  bool showDescription = true;

  @override
  Widget build(BuildContext context) {
    // Terima data dari arguments
    final Map<String, dynamic> job = Get.arguments['job'] ?? {};

    // Parsing data utama
    final String position = job['position'] ?? 'Unknown Position';
    final String companyName = job['companyName'] ?? 'Unknown Company';
    final String location = job['location'] ?? 'Unknown Location';
    final String jobType = job['jobType'] ?? 'N/A';
    final String salary = job['salary'] ?? 'N/A';
    final String companyLogoPath = job['companyLogoPath'] ?? '';
    final List<String> categories = 
        (job['categories'] as List<dynamic>? ?? []).cast<String>();

    // Parsing data nested
    final Map<String, dynamic> jobDetails = job['jobDetails'] ?? {};
    final String jobDescription = 
        jobDetails['jobDescription'] ?? 'No Description';
    // Normalize requirements: support legacy List<String> and new List<Map>
    final List<dynamic> rawRequirements =
        jobDetails['requirements'] as List<dynamic>? ?? [];
    final List<String> requirements = rawRequirements.map((r) {
      if (r is String) return r;
      if (r is Map && r.containsKey('text')) return r['text']?.toString() ?? '';
      return r.toString();
    }).where((s) => s.isNotEmpty).toList();

    // Normalize facilities similarly (in case stored as objects)
    final List<dynamic> rawFacilities = jobDetails['facilities'] as List<dynamic>? ?? [];
    final List<String> facilities = rawFacilities.map((f) {
      if (f is String) return f;
      if (f is Map && f.containsKey('text')) return f['text']?.toString() ?? '';
      return f.toString();
    }).where((s) => s.isNotEmpty).toList();

    final Map<String, dynamic> companyDetails =
        jobDetails['companyDetails'] ?? {};
    final String aboutCompany = companyDetails['aboutCompany'] ?? 'No Details';
    // Normalize gallery paths: entries can be String or Map{text: url}
    final List<dynamic> rawGallery = companyDetails['companyGalleryPaths'] as List<dynamic>? ?? [];
    final List<String> companyGalleryPaths = rawGallery.map((g) {
      if (g is String) return g;
      if (g is Map && g.containsKey('text')) return g['text']?.toString() ?? '';
      if (g is Map && g.containsKey('url')) return g['url']?.toString() ?? '';
      return g.toString();
    }).where((s) => s.isNotEmpty).toList();
    final String website = companyDetails['website'] ?? 'No Website';
    final String industry = companyDetails['industry'] ?? 'Unknown Industry';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          position,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Company Header
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                      child: companyLogoPath.isNotEmpty
                            ? Image.network(
                                companyLogoPath,
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                          headers: companyLogoPath.contains('/remote.php/dav/files/')
                            ? WebDAVService.authHeaders()
                            : null,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 70,
                                    width: 70,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.business,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                height: 70,
                                width: 70,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.business,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    companyName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
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
                                    jobType,
                                    style: const TextStyle(
                                      color: Color(0xFF6B34BE),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  location,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4E5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                salary,
                                style: const TextStyle(
                                  color: Color(0xFFFF9800),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                            const SizedBox(height: 12),
                            const Text(
                              'To change the company image, edit your profile in Profile -> Detail Profile.',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            const SizedBox(height: 8),
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tab Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => showDescription = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: showDescription ? const Color(0xFF6B34BE) : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        border: Border.all(color: const Color(0xFF6B34BE)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Description',
                        style: TextStyle(
                          color: showDescription ? Colors.white : const Color(0xFF6B34BE),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => showDescription = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !showDescription ? const Color(0xFF6B34BE) : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        border: Border.all(color: const Color(0xFF6B34BE)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Company',
                        style: TextStyle(
                          color: !showDescription ? Colors.white : const Color(0xFF6B34BE),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Content Container
            Container(
              padding: const EdgeInsets.all(16),
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
              child: showDescription
                  ? _buildJobDescription(jobDescription, requirements, facilities)
                  : _buildCompanyDetails(aboutCompany, industry, website, companyGalleryPaths),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobDescription(String jobDescription, List<String> requirements, List<String> facilities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Job Description:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(jobDescription),
        const SizedBox(height: 16),
        const Text(
          'Requirements:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...requirements
            .map((req) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(child: Text(req)),
                    ],
                  ),
                ))
            .toList(),
        const SizedBox(height: 16),
        const Text(
          'Facilities & Benefits:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: facilities
              .map((facility) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E0FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF6B34BE), width: 0.5),
                    ),
                    child: Text(
                      facility,
                      style: const TextStyle(
                        color: Color(0xFF6B34BE),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
  Widget _buildCompanyDetails(String aboutCompany, String industry, String website, List<String> companyGalleryPaths) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About Company:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(aboutCompany),
        const SizedBox(height: 16),
        
        const Text(
          'Industry:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(industry),
        const SizedBox(height: 16),

        const Text(
          'Website:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _launchURL(website),
          child: Text(
            website,
            style: const TextStyle(
              color: Color(0xFF6B34BE),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        if (companyGalleryPaths.isNotEmpty) Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Company Gallery',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${companyGalleryPaths.length} Photos',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: companyGalleryPaths.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showImagePreview(context, index, companyGalleryPaths),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              companyGalleryPaths[index],
                              width: 140,
                              height: 180,
                              fit: BoxFit.cover,
                            headers: companyGalleryPaths[index].contains('/remote.php/dav/files/')
                              ? WebDAVService.authHeaders()
                              : null,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 140,
                                  height: 180,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.5),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${index + 1}/${companyGalleryPaths.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not open the website',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
  void _showImagePreview(BuildContext context, int initialIndex, List<String> images) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Stack(
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    controller: PageController(initialPage: initialIndex),
                    onPageChanged: (index) {
                      setState(() {
                        initialIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Center(
                            child: InteractiveViewer(
                              minScale: 0.5,
                              maxScale: 3.0,
                              child: Image.network(
                                images[index],
                                fit: BoxFit.contain,
                                headers: images[index].contains('/remote.php/dav/files/')
                                    ? WebDAVService.authHeaders()
                                    : null,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                      size: 50,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${initialIndex + 1}/${images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}