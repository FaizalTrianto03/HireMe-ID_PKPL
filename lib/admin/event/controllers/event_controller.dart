import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:HireMe_Id/utils/webdav_service.dart';
import 'dart:io';

class EventController {
  final CollectionReference _eventCollection = FirebaseFirestore.instance.collection('events');
  final WebDAVService _webdav = WebDAVService();

  // PICK IMAGE FUNCTION (MULTI-IMAGE)
  Future<List<XFile>> pickImages() async {
    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> images = await picker.pickMultiImage();
      return images;
    } catch (e) {
      print('Error picking images: $e');
      rethrow;
    }
  }

  // 8️⃣ LOAD EVENTS (AMBIL SEMUA EVENT)
Future<List<Map<String, dynamic>>> loadEvents() async {
  try {
    QuerySnapshot querySnapshot = await _eventCollection.get();
    List<Map<String, dynamic>> events = querySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>, // Menggabungkan data dengan ID dokumen
      };
    }).toList();

    return events;
  } catch (e) {
    print('Error loading events: $e');
    rethrow;
  }
}


  // 1️⃣ UPLOAD IMAGES TO WEBDAV (Nextcloud)
  Future<List<String>> uploadImages(List<XFile> images, String eventId) async {
    List<String> imageUrls = [];
    try {
      for (var image in images) {
        final base = image.path.split(Platform.pathSeparator).last;
        final fileName = 'event_${eventId}_${DateTime.now().millisecondsSinceEpoch}_$base';
        // writeFromFile expects local path; ensure XFile is saved
        await _webdav.uploadFile(image.path, fileName);
        imageUrls.add(_webdav.buildFileUrl(fileName));
      }
      return imageUrls;
    } catch (e) {
      print('Error uploading images: $e');
      rethrow;
    }
  }

  // 2️⃣ DELETE IMAGE FROM WEBDAV (if Nextcloud) or ignore otherwise
  Future<void> deleteImage(String imageUrl) async {
    try {
      if (imageUrl.contains(WebDAVService.baseRoot)) {
        final fileName = _extractFileName(imageUrl);
        await _webdav.deleteFile(fileName);
      } else {
        // Not a Nextcloud URL - nothing to do here (legacy storage not supported here)
        print('deleteImage: URL not in Nextcloud base, skipping physical delete');
      }
    } catch (e) {
      print('Error deleting image: $e');
      rethrow;
    }
  }

  // 3️⃣ SAVE EVENT (WITH IMAGES)
  Future<void> saveEvent({
    required String title,
    required String description,
    required List<XFile> images,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      DocumentReference eventRef = await _eventCollection.add({
        'statusGlobal': true, // Default aktif
        'statusEvent': true, // Default aktif
        'title': title,
        'description': description,
        'images': [],
        'createdAt': Timestamp.now(),
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
      });

      // Upload images after creating the event to WebDAV
      List<String> imageUrls = [];
      if (images.isNotEmpty) {
        imageUrls = await uploadImages(images, eventRef.id);
        // Update event with image URLs
        await eventRef.update({'images': imageUrls});
      }
    } catch (e) {
      print('Error saving event with images: $e');
      rethrow;
    }
  }

  // 4️⃣ EDIT EVENT (UPDATE IMAGES)
  Future<void> editEvent({
  required String eventId,
  String? title,
  String? description,
  List<XFile>? newImages,
  List<String>? deletedImages,
  DateTime? startDate,
  DateTime? endDate,
}) async {
  try {
    Map<String, dynamic> updates = {};

    // Update text fields
    if (title != null) updates['title'] = title;
    if (description != null) updates['description'] = description;
    if (startDate != null) updates['startDate'] = Timestamp.fromDate(startDate);
    if (endDate != null) updates['endDate'] = Timestamp.fromDate(endDate);

    // Ambil data event dari DB (misalnya Firestore)
    DocumentSnapshot eventSnapshot = await _eventCollection.doc(eventId).get();
    if (!eventSnapshot.exists) {
      throw Exception('Event tidak ditemukan.');
    }

    // Dapatkan list images lama
    List<String> existingImages = List<String>.from(eventSnapshot['images'] ?? []);

    // 1. Proses penghapusan foto lama
    if (deletedImages != null && deletedImages.isNotEmpty) {
      for (var imageUrl in deletedImages) {
        // Hapus file fisik di WebDAV (Nextcloud) if applicable
        await deleteImage(imageUrl);

        // Hapus URL dari existingImages
        existingImages.remove(imageUrl);
      }
    }

    // 2. Upload foto baru
    if (newImages != null && newImages.isNotEmpty) {
      // Misalnya fungsi uploadImages() mengembalikan list of URL
  List<String> newImageUrls = await uploadImages(newImages, eventId);
      // Tambahkan URL baru ke existingImages
      existingImages.addAll(newImageUrls);
    }

    // 3. Update field 'images' dengan data terbaru
    updates['images'] = existingImages;

    // 4. Lakukan update ke DB
    await _eventCollection.doc(eventId).update(updates);
    
  } catch (e) {
    print('Error editing event: $e');
    rethrow;
  }
}


  // 5️⃣ DELETE EVENT (AND IMAGES)
  Future<void> deleteEvent(String eventId) async {
    try {
      DocumentSnapshot eventSnapshot = await _eventCollection.doc(eventId).get();
      List<String> imageUrls = List<String>.from(eventSnapshot['images']);

      // Delete all images associated with the event
      for (var imageUrl in imageUrls) {
        await deleteImage(imageUrl);
      }

      // Delete the event document
      await _eventCollection.doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }

  // 6️⃣ UPDATE GLOBAL STATUS
  Future<void> updateGlobalStatus(bool status) async {
    try {
      QuerySnapshot querySnapshot = await _eventCollection.get();
      for (var doc in querySnapshot.docs) {
        await _eventCollection.doc(doc.id).update({'statusGlobal': status});
      }
    } catch (e) {
      print('Error updating global status: $e');
      rethrow;
    }
  }

  // 7️⃣ UPDATE EVENT STATUS (SPECIFIC EVENT)
  Future<void> updateEventStatus(String eventId, bool status) async {
    try {
      await _eventCollection.doc(eventId).update({'statusEvent': status});
    } catch (e) {
      print('Error updating event status: $e');
      rethrow;
    }
  }




  // // 9️⃣ GET EVENT DETAILS (DETAIL EVENT)
Future<Map<String, dynamic>> getEventDetails(String eventId) async {
  try {
    DocumentSnapshot docSnapshot = await _eventCollection.doc(eventId).get();

    if (!docSnapshot.exists) {
      throw Exception('Event tidak ditemukan');
    }

    return {
      'id': docSnapshot.id,
      ...docSnapshot.data() as Map<String, dynamic>,
    };
  } catch (e) {
    print('Error fetching event details: $e');
    rethrow;
  }
}

  String _extractFileName(String url) {
    final marker = WebDAVService.appFolder;
    final idx = url.indexOf(marker);
    if (idx == -1) return Uri.decodeComponent(url.split('/').last);
    final start = idx + marker.length;
    final fileName = url.substring(start);
    return Uri.decodeComponent(fileName);
  }

}
