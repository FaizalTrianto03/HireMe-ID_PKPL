import 'package:flutter/material.dart';
import 'package:HireMe_Id/utils/webdav_service.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleDetailView extends StatelessWidget {
  final Map<String, dynamic> article;
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  final RxInt currentImageIndex = 0.obs;

  ArticleDetailView({Key? key, required this.article}) : super(key: key);

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('dd MMMM yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> media = article['media'] as List<dynamic>;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail Artikel',
          style: TextStyle(
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
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            if (media.isNotEmpty) ...[
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CarouselSlider.builder(
                    carouselController: _carouselController,
                    itemCount: media.length,
                    itemBuilder: (context, index, realIndex) {
                      return Image.network(
                        media[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        headers: WebDAVService.authHeaders(),
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 50,
                            ),
                          );
                        },
                      );
                    },
                    options: CarouselOptions(
                      height: 300,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      onPageChanged: (index, reason) {
                        currentImageIndex.value = index;
                      },
                    ),
                  ),
                  // Dots Indicator
                  if (media.length > 1)
                    Positioned(
                      bottom: 16,
                      child: Obx(() => DotsIndicator(
                            dotsCount: media.length,
                            position:
                                currentImageIndex.value, // Perbaikan di sini
                            decorator: DotsDecorator(
                              activeColor: const Color(0xFF6B34BE),
                              size: const Size.square(8),
                              activeSize: const Size(24, 8),
                              activeShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          )),
                    ),
                ],
              ),
            ],

            // Article Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimestamp(article['createdAt']),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Content
                  Text(
                    article['content'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
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
