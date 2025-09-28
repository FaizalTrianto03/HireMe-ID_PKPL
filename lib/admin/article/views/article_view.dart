import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_article.dart';
import 'article_detail.dart';
import 'edit_article.dart';
import '../controllers/article_controller.dart';
import 'package:intl/intl.dart';
import 'package:HireMe_Id/utils/webdav_service.dart';

class ArticleView extends StatelessWidget {
  final ArticleController _controller = Get.put(ArticleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Artikel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6B34BE)),
            onPressed: () async {
              await _controller.fetchArticles();
              Get.snackbar('Di-refresh', 'Daftar artikel berhasil diperbarui');
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF6B34BE)),
            onPressed: () {
              Get.to(() => AddArticle());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // Search Bar dengan style yang diperbarui
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
                        controller: _controller.searchController,
                        onChanged: (value) => _controller.filterArticles(value),
                        decoration: const InputDecoration(
                          hintText: 'Cari artikel berdasarkan judul...',
                          hintStyle:
                              TextStyle(fontSize: 14, color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                    if (_controller.searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _controller.searchController.clear();
                          _controller.filterArticles('');
                        },
                        child: const Icon(Icons.close,
                            color: Colors.grey, size: 20),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // List Artikel dengan style yang diperbarui
            Expanded(
              child: Obx(() {
                if (_controller.articles.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada artikel ditemukan.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => await _controller.fetchArticles(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _controller.articles.length,
                    itemBuilder: (context, index) {
                      final article = _controller.articles[index];
                      final media = article['media'] as List<dynamic>;

                      return InkWell(
                        onTap: () {
                          Get.to(() => ArticleDetailView(articleId: article['id']));
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Foto Artikel dengan Menu
                              Stack(
                                children: [
                                  // Foto Artikel
                                  Center(
                                    // Tambahkan Center di sini
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: media.isNotEmpty
                                          ? Image.network(
                                              media[0],
                                              headers: WebDAVService.authHeaders(),
                                              height: 150,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  height: 150,
                                                  width: double.infinity,
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                    size: 40,
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              height: 150,
                                              width: double.infinity,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                                size: 40,
                                              ),
                                            ),
                                    ),
                                  ),
                                  // Menu Actions di pojok kanan atas
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: PopupMenuButton<String>(
                                        icon: const Icon(
                                          Icons.more_vert,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        elevation: 3,
                                        position: PopupMenuPosition.under,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            Get.to(() => EditArticle(
                                                articleId: article['id']));
                                          } else if (value == 'delete') {
                                            _showDeleteDialog(
                                                context, article['id']);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: const [
                                                Icon(
                                                  Icons.edit_outlined,
                                                  color: Colors.blue,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: const [
                                                Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Konten tetap sama
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      article['title'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatTimestamp(article['createdAt']),
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
                      );
                    },
                  ),
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id) {
    Get.defaultDialog(
      title: "Hapus Artikel",
      middleText: "Apakah Anda yakin ingin menghapus artikel ini?",
      textConfirm: "Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        _controller.deleteArticle(id);
        Get.back();
      },
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('dd MMMM yyyy').format(dateTime);
  }
}
