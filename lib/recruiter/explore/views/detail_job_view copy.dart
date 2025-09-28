import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart'; // Untuk membuka website

class DetailJobView extends StatelessWidget {
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
    final List<String> requirements =
        (jobDetails['requirements'] as List<dynamic>? ?? []).cast<String>();
    final List<String> facilities =
        (jobDetails['facilities'] as List<dynamic>? ?? []).cast<String>();

    final Map<String, dynamic> companyDetails =
        jobDetails['companyDetails'] ?? {};
    final String aboutCompany = companyDetails['aboutCompany'] ?? 'No Details';
    final List<String> companyGalleryPaths =
        (companyDetails['companyGalleryPaths'] as List<dynamic>? ?? [])
            .cast<String>();
    final String website = companyDetails['website'] ?? 'No Website';
    final String industry = companyDetails['industry'] ?? 'Unknown Industry';

    return Scaffold(
      appBar: AppBar(
        title: Text(position),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: companyLogoPath.isNotEmpty
                      ? Image.network(
                          companyLogoPath,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 60,
                              width: 60,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.business,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 60,
                          width: 60,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.business,
                            color: Colors.grey,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                // Job Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        position,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        companyName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Job Type and Salary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Job Type: $jobType',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Salary: $salary',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Job Description
            const Text(
              'Job Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              jobDescription,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Categories
            if (categories.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories
                        .map(
                          (category) => Chip(
                            label: Text(category),
                            backgroundColor: Colors.grey.shade200,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Requirements
            const Text(
              'Requirements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: requirements
                  .map((req) => Text(
                        '- $req',
                        style: const TextStyle(fontSize: 14),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Facilities
            const Text(
              'Facilities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: facilities
                  .map((facility) => Text(
                        '- $facility',
                        style: const TextStyle(fontSize: 14),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            // About Company
            const Text(
              'About Company',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              aboutCompany,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Company Gallery
            if (companyGalleryPaths.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Company Gallery',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: companyGalleryPaths
                          .map((imageUrl) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return Container(
                                        height: 100,
                                        width: 100,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Website and Industry
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Industry: $industry',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _launchURL(website);
                  },
                  child: Text(
                    website,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
}
