import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:HireMe_Id/admin/article/controllers/article_controller.dart';
import 'package:HireMe_Id/utils/webdav_service.dart';

class EditArticle extends StatefulWidget {
  final String articleId;

  const EditArticle({Key? key, required this.articleId}) : super(key: key);

  @override
  State<EditArticle> createState() => _EditArticleState();
}

class _EditArticleState extends State<EditArticle> {
  final ArticleController _controller = Get.put(ArticleController());
  bool _loading = true;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _checkLoginAndLoad();
  }

  Future<void> _checkLoginAndLoad() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // redirect to login
      Get.offAllNamed('/login');
      return;
    }

    final data = await _controller.fetchArticleById(widget.articleId);
    if (data != null) {
      _controller.title.value = data['title'] ?? '';
      _controller.content.value = data['content'] ?? '';
      _controller.mediaUrls.assignAll(List<String>.from(data['media'] ?? []));
      _controller.mediaFiles.clear();
    }

    _titleController = TextEditingController(text: _controller.title.value);
    _contentController = TextEditingController(text: _controller.content.value);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Artikel',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1,
          bottom: const TabBar(
            indicatorColor: Color(0xFF6B34BE),
            labelColor: Color(0xFF6B34BE),
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(icon: Icon(Icons.text_fields), text: 'Konten'),
              Tab(icon: Icon(Icons.photo_library), text: 'Media'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Input Konten Artikel
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      elevation: 3,
                      shadowColor: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Judul Artikel',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _titleController,
                                onChanged: (value) => _controller.title.value = value,
                              decoration: const InputDecoration(
                                hintText: 'Masukkan judul artikel...',
                                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Material(
                      elevation: 3,
                      shadowColor: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Isi Artikel',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _contentController,
                                onChanged: (value) => _controller.content.value = value,
                              maxLines: 10,
                              decoration: const InputDecoration(
                                hintText: 'Masukkan isi artikel...',
                                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tab 2: Input Media (Foto)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    elevation: 3,
                    shadowColor: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lampirkan Foto',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await _controller.pickMedia();
                            },
                            icon: const Icon(Icons.add_photo_alternate, size: 20),
                            label: const Text(
                              'Tambah Foto',
                              style: TextStyle(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B34BE),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Obx(
                      () {
                        final allMedia = [
                          ..._controller.mediaUrls.map((url) => url),
                          ..._controller.mediaFiles,
                        ];

                        if (allMedia.isEmpty) {
                          return Center(
                            child: Text(
                              'Belum ada foto yang dipilih.',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }

                        return GridView.builder(
                          itemCount: allMedia.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            final media = allMedia[index];

                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: media is String
                                            ? (Image.network(
                                                media,
                                                headers: WebDAVService.authHeaders(),
                                              ).image)
                                            : FileImage(media as File) as ImageProvider<Object>,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () async {
                                        if (media is String) {
                                          // delete remote media from storage and Firestore
                                          await _controller.removeMediaFromArticle(widget.articleId, media);
                                        } else if (media is File) {
                                          _controller.mediaFiles.remove(media);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () async {
              // Ensure controller values are up-to-date from the local text controllers
              _controller.title.value = _titleController.text;
              _controller.content.value = _contentController.text;
              await _controller.editArticle(widget.articleId);
              _controller.title.value = '';
              _controller.content.value = '';
              _controller.mediaFiles.clear();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B34BE),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Update Artikel',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}