import 'package:HireMe_Id/admin/event/views/edit_event.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:HireMe_Id/utils/webdav_service.dart';
import '../controllers/event_controller.dart';
import 'create_event.dart';
import 'detail_event.dart';

class PageEvent extends StatefulWidget {
  const PageEvent({Key? key}) : super(key: key);

  @override
  State<PageEvent> createState() => _PageEventState();
}

class _PageEventState extends State<PageEvent> {
  final EventController _eventController = EventController();

  bool? _globalStatus; // Bisa null sampai di-fetch dari Firestore

// ✅ Ambil statusGlobal dari Firestore
Future<void> _loadGlobalStatus() async {
  setState(() => _isLoading = true);
  try {
    List<Map<String, dynamic>> events = await _eventController.loadEvents();
    
    // Hitung jumlah true dan false
    int trueCount = events.where((event) => event['statusGlobal'] == true).length;
    int falseCount = events.length - trueCount; // Sisa dari total event
    
    bool finalStatus = trueCount >= falseCount; // Mayoritas true atau false

    // Update status global di Firestore berdasarkan mayoritas
    await _eventController.updateGlobalStatus(finalStatus);

    setState(() {
      _globalStatus = finalStatus; // Set nilai final ke _globalStatus
    });
  } catch (e) {
    print('Error loading global status: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal memuat status global: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}


  List<Map<String, dynamic>> _events = []; // List event
  bool _isLoading = true;

  @override
 @override
void initState() {
  super.initState();
  _loadEvents(); 
  _loadGlobalStatus(); // Muat status global saat halaman dimuat
}


  // ✅ Memuat data event dari Controller
  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      List<Map<String, dynamic>> events = await _eventController.loadEvents();
      setState(() {
        _events = events;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat event: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ Toggle Global Status
  Future<void> _toggleGlobalStatus(bool value) async {
    setState(() => _globalStatus = value);
    await _eventController.updateGlobalStatus(value);
    await _loadEvents();
  }

  // ✅ Toggle Event Status
  Future<void> _toggleEventStatus(String eventId, bool value) async {
    await _eventController.updateEventStatus(eventId, value);
    await _loadEvents();
  }

  // ✅ Tampilkan dialog konfirmasi hapus
  void _confirmDeleteEvent(String eventId) {
  showDialog(
    context: context,
    builder: (ctx) {
      return Theme(
        // 1. Override tema khusus untuk dialog
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: const Color(0xFF6B34BE), // Warna tombol, dsb
              ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6B34BE), // Warna teks tombol "Batal"
            ),
          ),
        ),
        child: AlertDialog(
          // 2. Style AlertDialog
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Sudut membulat
          ),
          title: const Text(
            'Konfirmasi Hapus',
            style: TextStyle(
              color: Color(0xFF6B34BE), 
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus event ini?\n'
            'Data yang terhapus tidak dapat dikembalikan!',
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
          actions: [
            // Tombol Batal
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            // Tombol Hapus (dengan style warna merah)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); 
                _deleteEvent(eventId);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, 
              ),
              child: const Text('Hapus'),
            ),
          ],
        ),
      );
    },
  );
}


  // ✅ Hapus Event
  Future<void> _deleteEvent(String eventId) async {
    await _eventController.deleteEvent(eventId);
    await _loadEvents();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event berhasil dihapus!')),
    );
  }

  // ✅ Navigate ke CreateEventPage
  void _navigateToCreateEvent() {
    Get.to(() => const CreateEventPage())?.then((_) => _loadEvents());
  }

  // ✅ Navigate ke DetailEventPage
  void _navigateToDetailEvent(String eventId) {
    Get.to(() => DetailEventPage(eventId: eventId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar mirip style EditEvent
      appBar: AppBar(
        title: const Text(
          'Manajemen Event',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6B34BE)),
            onPressed: _loadEvents,
            tooltip: 'Muat Ulang Event',
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Stack(
        children: [
          // 1. Background gradient menutupi seluruh layar
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFD6C5FF), Color(0xFF6B34BE)],
              ),
            ),
          ),

          // 2. Konten di atas gradient
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Container untuk global status
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Status Global Event',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B34BE),
                            ),
                          ),
                          subtitle: const Text(
                            'Aktifkan atau Nonaktifkan Semua Event',
                            style: TextStyle(fontSize: 14),
                          ),
                          trailing: _globalStatus == null
    ? SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B34BE)),
        ),
      )
    : Switch(
        value: _globalStatus ?? false, // Default false jika null (jaga-jaga)
        onChanged: (value) => _toggleGlobalStatus(value),
        activeColor: const Color(0xFF6B34BE),
      ),

                        ),
                      ),

                      const SizedBox(height: 20),

                      // Card Container untuk list event
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Daftar Event',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B34BE),
                              ),
                            ),
                            const SizedBox(height: 8),

                            _events.isEmpty
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 30),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Belum ada event yang tersedia',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: _events.map((event) {
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(top: 16.0),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: InkWell(
                                          onTap: () => _navigateToDetailEvent(
                                            event['id'] ?? '',
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Bagian gambar (height lebih kecil, misal 120)
                                              SizedBox(
                                                height: 120,
                                                width: double.infinity,
                                                child: Stack(
                                                  children: [
                                                    // Preview Gambar
                                                    ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(12),
                                                        topRight:
                                                            Radius.circular(12),
                                                      ),
                              child: (event['images'] !=
                                    null &&
                                  event['images']
                                    .isNotEmpty)
                              ? Image.network(
                                event['images']
                                  [0],
                                fit: BoxFit.cover,
                                width: double
                                  .infinity,
                                height:
                                  double.infinity,
                                headers:
                                  WebDAVService.authHeaders(),
                              )
                                                          : Container(
                                                              color: Colors
                                                                  .grey[300],
                                                              child: const Center(
                                                                child: Text(
                                                                  'No Image',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                    ),
                                                    // Switch di pojok kanan atas
                                                    Positioned(
                                                      top: 8,
                                                      right: 8,
                                                      child: Switch(
                                                        value:
                                                            event['statusEvent'] ??
                                                                true,
                                                        onChanged: (value) =>
                                                            _toggleEventStatus(
                                                          event['id'] ?? '',
                                                          value,
                                                        ),
                                                        activeColor:
                                                            const Color(
                                                                0xFF6B34BE),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Nama Event di bawah gambar
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    16, 12, 16, 0),
                                                child: Text(
                                                  event['title'] ??
                                                      'Tanpa Judul',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),

                                              // Tombol Edit & Hapus
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        16, 8, 16, 12),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    TextButton.icon(
                                                      onPressed: () {
                                                        Get.to(
                                                          () => EditEventPage(
                                                            eventId:
                                                                event['id'] ??
                                                                    '',
                                                          ),
                                                        );
                                                      },
                                                      icon:
                                                          const Icon(Icons.edit),
                                                      label: const Text('Edit'),
                                                      style:
                                                          TextButton.styleFrom(
                                                        foregroundColor:
                                                            const Color(
                                                                0xFF6B34BE),
                                                      ),
                                                    ),
                                                    TextButton.icon(
                                                      onPressed: () {
                                                        _confirmDeleteEvent(
                                                            event['id'] ?? '');
                                                      },
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      label: const Text(
                                                        'Hapus',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),

      // FloatingActionButton putih + border ungu
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateEvent,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF6B34BE), width: 2),
        ),
        child: const Icon(
          Icons.add,
          color: Color(0xFF6B34BE),
        ),
        tooltip: 'Tambah Event Baru',
      ),
    );
  }
}
