import 'dart:io';
import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';
import 'package:HireMe_Id/utils/webdav_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditEventPage extends StatefulWidget {
  final String eventId;

  const EditEventPage({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final EventController _eventController = EventController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _existingImages = [];
  List<String> _deletedImages = [];
  List<XFile> _newImages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    try {
      var eventSnapshot =
          await _eventController.getEventDetails(widget.eventId);
      setState(() {
        _titleController.text = eventSnapshot['title'] ?? '';
        _descriptionController.text = eventSnapshot['description'] ?? '';
        _startDate = eventSnapshot['startDate']?.toDate();
        _endDate = eventSnapshot['endDate']?.toDate();
        _existingImages = List<String>.from(eventSnapshot['images'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      _showErrorSnackBar('Gagal memuat detail event: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImages() async {
    try {
      List<XFile> images = await _eventController.pickImages();
      setState(() => _newImages.addAll(images));
    } catch (e) {
      _showErrorSnackBar('Gagal memilih gambar: $e');
    }
  }

  void _deleteExistingImage(String imageUrl) {
    setState(() {
      _existingImages.remove(imageUrl);
      _deletedImages.add(imageUrl);
    });
  }

  void _deleteNewImage(XFile image) {
    setState(() => _newImages.remove(image));
  }

  Future<void> _saveEvent() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _startDate == null ||
        _endDate == null) {
      _showErrorSnackBar('Semua field harus diisi!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _eventController.editEvent(
        eventId: widget.eventId,
        title: _titleController.text,
        description: _descriptionController.text,
        newImages: _newImages,
        deletedImages: _deletedImages,
        startDate: _startDate,
        endDate: _endDate,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event berhasil diperbarui!'),
          backgroundColor: Color(0xFF6B34BE),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Gagal menyimpan perubahan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B34BE),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) _startDate = pickedDate;
        else _endDate = pickedDate;
      });
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B34BE),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: date == null
                      ? Colors.grey.shade400
                      : const Color(0xFF6B34BE),
                ),
                const SizedBox(width: 8),
                Text(
                  date == null
                      ? 'Pilih tanggal'
                      : DateFormat('dd MMM yyyy').format(date),
                  style: TextStyle(
                    fontSize: 14,
                    color: date == null ? Colors.grey.shade400 : Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF6B34BE)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Event',
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
          _isLoading
              ? Container(
                  margin: const EdgeInsets.all(14),
                  width: 24,
                  height: 24,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF6B34BE)),
                  ),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF6B34BE),
                    size: 28,
                  ),
                  onPressed: _saveEvent,
                ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD6C5FF), Color(0xFF6B34BE)],
          ),
        ),
        child: _isLoading
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
                    // Form Container
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
                          _buildLabel('Judul Event'),
                          TextField(
                            controller: _titleController,
                            style: const TextStyle(fontSize: 16),
                            decoration:
                                _inputDecoration('Masukkan judul event'),
                          ),
                          const SizedBox(height: 24),

                          _buildLabel('Deskripsi'),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 4,
                            style: const TextStyle(fontSize: 16),
                            decoration:
                                _inputDecoration('Tulis deskripsi event'),
                          ),
                          const SizedBox(height: 24),

                          _buildLabel('Periode Event'),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDateField(
                                  'Mulai',
                                  _startDate,
                                  () => _selectDate(true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDateField(
                                  'Selesai',
                                  _endDate,
                                  () => _selectDate(false),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Images Container
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
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLabel('Foto Event'),
                              TextButton.icon(
                                onPressed: _pickImages,
                                icon: const Icon(
                                  Icons.add_photo_alternate_rounded,
                                  color: Color(0xFF6B34BE),
                                ),
                                label: const Text(
                                  'Tambah Foto',
                                  style: TextStyle(
                                    color: Color(0xFF6B34BE),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF6B34BE)
                                          .withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Existing Images
                          if (_existingImages.isNotEmpty)
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _existingImages.map((imageUrl) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          headers: WebDAVService.authHeaders(),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: InkWell(
                                          onTap: () =>
                                              _deleteExistingImage(
                                                  imageUrl),
                                          child: Container(
                                            padding:
                                                const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withOpacity(0.5),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),

                          // New Images
                          if (_newImages.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _newImages.map((image) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: Image.file(
                                          File(image.path),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: InkWell(
                                          onTap: () =>
                                              _deleteNewImage(image),
                                          child: Container(
                                            padding:
                                                const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withOpacity(0.5),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],

                          // Empty State
                          if (_existingImages.isEmpty &&
                              _newImages.isEmpty)
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 30),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Belum ada foto dipilih',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
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
  }
}
