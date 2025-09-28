import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:HireMe_Id/utils/webdav_service.dart';

class ArticleController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // kept for legacy deletions
  final WebDAVService _webdav = WebDAVService();

  var title = ''.obs;
  var content = ''.obs;
  var mediaFiles = <File>[].obs; // Media yang dipilih oleh user
  var mediaUrls = <String>[].obs; // URL media lama dari artikel

  // Untuk artikel
  var articles = <Map<String, dynamic>>[].obs;
  var filteredArticles = <Map<String, dynamic>>[].obs;

  // Gunakan TextEditingController untuk Search
  final TextEditingController searchController = TextEditingController();

  // State untuk loading
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Ensure Nextcloud app folder exists
    _webdav.testConnection().then((_) => true).catchError((e) {
      // Surface error but keep controller usable to avoid crashes
      Get.snackbar('WebDAV Error', 'Gagal inisialisasi WebDAV: $e');
      return false;
    });
    fetchArticles();

    // Listener untuk search input
    searchController.addListener(() {
      filterArticles(searchController.text);
    });
  }

  // Fungsi untuk mengambil data artikel dari Firestore
  Future<void> fetchArticles() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('article').get();
      articles.assignAll(
        snapshot.docs.map((doc) => {
              'id': doc.id,
              'title': doc['title'],
              'content': doc['content'],
              'media': doc['media'] ?? [],
              'createdAt': doc['createdAt'],
            }).toList(),
      );
      filteredArticles.assignAll(articles);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil data artikel: $e');
    }
  }

  /// Fetch single article by id. Returns the map or null.
  Future<Map<String, dynamic>?> fetchArticleById(String articleId) async {
    try {
      final doc = await _firestore.collection('article').doc(articleId).get();
      if (!doc.exists) return null;
      final data = {
        'id': doc.id,
        'title': doc['title'],
        'content': doc['content'],
        'media': doc['media'] ?? [],
        'createdAt': doc['createdAt'],
      };
      return data;
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil detail artikel: $e');
      return null;
    }
  }

  // Fungsi untuk filter artikel berdasarkan judul
  void filterArticles(String query) {
    if (query.isEmpty) {
      filteredArticles.assignAll(articles);
    } else {
      filteredArticles.assignAll(
        articles.where((article) => article['title']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase())),
      );
    }
  }

  // Fungsi untuk menyimpan artikel
  Future<void> saveArticle() async {
    try {
      isLoading.value = true;
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      List<String> mediaUrls = await _uploadMediaFiles();

      await _firestore.collection('article').add({
        'title': title.value,
        'content': content.value,
        'media': mediaUrls,
        'createdAt': FieldValue.serverTimestamp(),
      });

      fetchArticles();
      Get.back(); // Tutup loading dialog
      Get.snackbar('Sukses', 'Artikel berhasil disimpan');
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Gagal menyimpan artikel: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi untuk mengedit artikel
  Future<void> editArticle(String articleId) async {
    try {
      isLoading.value = true; // Set state ke loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Upload file baru ke WebDAV (Nextcloud)
      List<String> newMediaUrls = await _uploadMediaFiles();

      // Gabungkan media lama yang tidak dihapus (controller.mediaUrls) dengan media baru
      final List<String> currentMedia = List<String>.from(mediaUrls);
      List<String> updatedMediaUrls = [...currentMedia, ...newMediaUrls];

      // Update artikel di Firestore
      await _firestore.collection('article').doc(articleId).update({
        'title': title.value,
        'content': content.value,
        'media': updatedMediaUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state immediately so UI reflects changes without waiting for fetch
      mediaUrls.assignAll(updatedMediaUrls);
      mediaFiles.clear();

      // Refresh list to keep global view sync
      await fetchArticles();
      Get.back(); // Tutup loading dialog
      Get.snackbar('Sukses', 'Artikel berhasil diperbarui');
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Gagal memperbarui artikel: $e');
    } finally {
      isLoading.value = false; // Selesai loading
    }
  }

  // Fungsi untuk menghapus artikel
  Future<void> deleteArticle(String articleId) async {
    try {
      isLoading.value = true;

      DocumentSnapshot doc =
          await _firestore.collection('article').doc(articleId).get();
      List<String> mediaUrls = List<String>.from(doc['media'] ?? []);

      // Hapus file dari WebDAV (Nextcloud) atau Firebase Storage (legacy)
      for (var url in mediaUrls) {
        try {
          if (_isNextcloudUrl(url)) {
            final fileName = _extractFileName(url);
            await _webdav.deleteFile(fileName);
          } else {
            await _storage.refFromURL(url).delete();
          }
        } catch (e) {
          // Continue deleting others, but notify
          debugPrint('Gagal menghapus media $url: $e');
        }
      }

      await _firestore.collection('article').doc(articleId).delete();

      fetchArticles(); // Refresh data artikel
      Get.snackbar('Sukses', 'Artikel berhasil dihapus');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus artikel: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi untuk memilih file media
  Future<void> pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      mediaFiles.addAll(pickedFiles.map((file) => File(file.path)));
    }
  }

  /// Remove a media URL from an article immediately.
  /// If it's a Nextcloud URL, delete the file from WebDAV first.
  Future<void> removeMediaFromArticle(String articleId, String mediaUrl) async {
    try {
      isLoading.value = true;

      // Delete file from storage if necessary
      if (_isNextcloudUrl(mediaUrl)) {
        final fileName = _extractFileName(mediaUrl);
        await _webdav.deleteFile(fileName);
      } else {
        try {
          await _storage.refFromURL(mediaUrl).delete();
        } catch (e) {
          // ignore errors from legacy storage deletion
          debugPrint('Legacy delete failed: $e');
        }
      }

      // Remove URL from Firestore array
      await _firestore.collection('article').doc(articleId).update({
        'media': FieldValue.arrayRemove([mediaUrl])
      });

      // Update local state if present
      mediaUrls.remove(mediaUrl);

      // Refresh articles list locally
      await fetchArticles();

      Get.snackbar('Sukses', 'Media berhasil dihapus');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus media: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper: Upload file media ke WebDAV (Nextcloud)
  Future<List<String>> _uploadMediaFiles() async {
    List<String> uploadedUrls = [];
    for (var file in mediaFiles) {
      final base = file.path.split(Platform.pathSeparator).last;
      final fileName = 'article_${DateTime.now().millisecondsSinceEpoch}_$base';
      await _webdav.uploadFile(file.path, fileName);
      uploadedUrls.add(_webdav.buildFileUrl(fileName));
    }
    return uploadedUrls;
  }

  bool _isNextcloudUrl(String url) {
    return url.contains(WebDAVService.baseRoot);
  }

  String _extractFileName(String url) {
    // Expected: .../files/<username>/{appFolder}<fileName>
    final marker = WebDAVService.appFolder;
    final idx = url.indexOf(marker);
    if (idx == -1) return Uri.decodeComponent(url.split('/').last);
    final start = idx + marker.length;
    final fileName = url.substring(start);
    return Uri.decodeComponent(fileName);
  }
}
