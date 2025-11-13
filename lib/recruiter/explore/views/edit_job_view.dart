import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/job_controller.dart';
import 'package:HireMe_Id/data/job_categories.dart';
import 'package:HireMe_Id/utils/webdav_service.dart';

class EditJobView extends StatelessWidget {
  final JobController jobController = Get.put(JobController());

  // Controllers untuk form fields
  final TextEditingController positionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController jobDescriptionController = TextEditingController();
  final TextEditingController requirementsController = TextEditingController();
  final TextEditingController facilitiesController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController aboutCompanyController = TextEditingController();
  final TextEditingController industryController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  
  final RxString selectedJobType = ''.obs;
  final RxList<String> selectedCategories = <String>[].obs;
  final RxList<String> galleryImageUrls = <String>[].obs;
  final RxList<Map<String, dynamic>> requirementsList = <Map<String, dynamic>>[].obs;

  // Job index dari Get.arguments
  late final int jobIndex;
  late final Map<String, dynamic> jobData;

  EditJobView() {
    final arguments = Get.arguments;
    jobIndex = arguments['index'];
    jobData = arguments['job'];
    _initializeFields();
  }

  void _initializeFields() {
    positionController.text = jobData['position'] ?? '';
    locationController.text = jobData['location'] ?? '';
    jobDescriptionController.text = jobData['jobDetails']['jobDescription'] ?? '';
    
    final rawReqs = jobData['jobDetails']['requirements'] ?? [];
    final List<Map<String, dynamic>> mappedReqs = [];
    for (var r in rawReqs) {
      if (r is String) {
        mappedReqs.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString() + '_' + mappedReqs.length.toString(),
          'text': r,
          'isActive': false,
        });
      } else if (r is Map) {
        mappedReqs.add({
          'id': r['id'] ?? DateTime.now().millisecondsSinceEpoch.toString() + '_' + mappedReqs.length.toString(),
          'text': r['text'] ?? '',
          'isActive': r['isActive'] == true,
        });
      }
    }
    requirementsList.value = mappedReqs;
    
    facilitiesController.text = (jobData['jobDetails']['facilities'] ?? []).join(', ');
    salaryController.text = jobData['salary'] ?? '';
    aboutCompanyController.text = jobData['jobDetails']['companyDetails']['aboutCompany'] ?? '';
    industryController.text = jobData['jobDetails']['companyDetails']['industry'] ?? '';
    websiteController.text = jobData['jobDetails']['companyDetails']['website'] ?? '';
    selectedJobType.value = jobData['jobType'] ?? '';
    selectedCategories.value = List<String>.from(jobData['categories'] ?? <String>[]);
    galleryImageUrls.value = List<String>.from(jobData['jobDetails']['companyDetails']['companyGalleryPaths'] ?? []);
    if (jobData['startDate'] != null) {
      jobController.startDate.value = DateTime.tryParse(jobData['startDate'].toString());
    }
    if (jobData['endDate'] != null) {
      jobController.endDate.value = DateTime.tryParse(jobData['endDate'].toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (jobController.recruiterData.isEmpty) {
        jobController.fetchRecruiterData();
      }
    });

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          title: const Text(
            'Edit Job',
            style: TextStyle(
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
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF6B34BE)),
              tooltip: 'Refresh Data',
              onPressed: () async {
                try {
                  Get.dialog(
                    Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFF6B34BE),
                      ),
                    ),
                    barrierDismissible: false,
                  );

                  final jobController = Get.find<JobController>();
                  await jobController.fetchRecruiterData();
                  await jobController.fetchJobs();

                  Get.back();

                  Get.snackbar(
                    'Success',
                    'Data successfully refreshed.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green[100],
                    colorText: Colors.black,
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                  );
                } catch (e) {
                  Get.back();
                  Get.snackbar(
                    'Error',
                    'Failed to refresh data: $e',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red[100],
                    colorText: Colors.black,
                    icon: const Icon(Icons.error_outline, color: Colors.red),
                  );
                }
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFF6B34BE),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF6B34BE),
            tabs: [
              Tab(text: 'Company', icon: Icon(Icons.business)),
              Tab(text: 'Job Details', icon: Icon(Icons.work)),
              Tab(text: 'Additional', icon: Icon(Icons.more_horiz)),
            ],
          ),
        ),
        body: Obx(() {
          if (jobController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6B34BE),
              ),
            );
          }

          if (jobController.recruiterData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load recruiter data.',
                    style: TextStyle(fontSize: 16, color: Colors.redAccent),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            children: [
              _buildCompanyTab(),
              _buildJobDetailsTab(),
              _buildAdditionalTab(),
            ],
          );
        }),
        bottomNavigationBar: _buildSaveButton(),
      ),
    );
  }

  // Helper Widgets
  Widget _buildReadOnlyField({
    required String label,
    required String? value,
    required IconData icon,
  }) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: const Color(0xFF6B34BE)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      controller: TextEditingController(text: value),
      style: const TextStyle(color: Colors.black87, fontSize: 16),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: const Color(0xFF6B34BE)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6B34BE)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: const TextStyle(color: Colors.black87, fontSize: 16),
    );
  }

  String _formatDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  Widget _buildDatePickerBox(BuildContext context, String label, bool isStart) {
    return Obx(() {
      final date = isStart ? jobController.startDate.value : jobController.endDate.value;
      return InkWell(
        onTap: jobController.isLoading.value
            ? null
            : () async {
                final now = DateTime.now();
                final firstDate = isStart
                    ? DateTime(now.year, now.month, now.day)
                    : (jobController.startDate.value != null
                        ? DateTime(jobController.startDate.value!.year, jobController.startDate.value!.month, jobController.startDate.value!.day)
                        : DateTime(now.year, now.month, now.day));
                final initialDate = date ?? firstDate;
                final lastDate = DateTime(now.year + 2, now.month, now.day);
                final picked = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                );
                if (picked != null) {
                  if (isStart) {
                    jobController.startDate.value = picked;
                    if (jobController.endDate.value != null && jobController.endDate.value!.isBefore(picked)) {
                      jobController.endDate.value = null;
                    }
                  } else {
                    jobController.endDate.value = picked;
                  }
                }
              },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(Icons.date_range, color: const Color(0xFF6B34BE)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  date == null ? 'Select $label' : '$label: ${_formatDate(date)}',
                  style: TextStyle(
                    color: date == null ? Colors.grey[600] : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Company Tab
  Widget _buildCompanyTab() {
    final recruiterData = jobController.recruiterData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company Profile Card
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
              children: [
                // Company Logo/Image
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF6B34BE),
                  child: ClipOval(
                    child: (recruiterData['profile_image'] != null &&
                            recruiterData['profile_image'].isNotEmpty)
                        ? Image.network(
                            recruiterData['profile_image'],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            headers: (recruiterData['profile_image'] as String)
                                    .contains('/remote.php/dav/files/')
                                ? WebDAVService.authHeaders()
                                : null,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.business,
                                size: 50,
                                color: Colors.white,
                              );
                            },
                          )
                        : const Icon(
                            Icons.business,
                            size: 50,
                            color: Colors.white,
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Company Information Fields
                _buildReadOnlyField(
                  label: 'Company Name',
                  value: recruiterData['company_name'] ?? 'Unknown Company',
                  icon: Icons.business,
                ),
                const SizedBox(height: 16),

                _buildInputField(
                  label: 'Industry',
                  hintText: 'e.g., Technology, Healthcare, Finance',
                  controller: industryController,
                  icon: Icons.category,
                ),
                const SizedBox(height: 16),

                _buildInputField(
                  label: 'Website',
                  hintText: 'e.g., https://www.company.com',
                  controller: websiteController,
                  icon: Icons.language,
                ),
                const SizedBox(height: 16),

                _buildInputField(
                  label: 'About Company',
                  hintText: 'Describe your company, culture, and mission...',
                  controller: aboutCompanyController,
                  icon: Icons.info,
                  maxLines: 4,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Company Gallery Section
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
                const Text(
                  'Company Gallery',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B34BE),
                  ),
                ),
                const SizedBox(height: 16),
                _buildPickImage(
                  label: 'Add Company Images',
                  icon: Icons.image_outlined,
                  imageUrls: galleryImageUrls,
                  email: FirebaseAuth.instance.currentUser?.email ?? 'recruiter@example.com',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickImage({
    required String label,
    required IconData icon,
    required RxList<String> imageUrls,
    required String email,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B34BE),
          ),
        ),
        const SizedBox(height: 8),

        // Upload Button
        GestureDetector(
          onTap: () async {
            final imageUrl = await jobController.pickAndUploadImage(
              email: email,
              jobIndex: jobIndex,
            );

            if (imageUrl != null) {
              imageUrls.add(imageUrl);
            }
          },
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Center(
              child: Icon(Icons.add_photo_alternate_outlined,
                  size: 50, color: Color(0xFF6B34BE)),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Image Preview Grid
        Obx(() {
          if (imageUrls.isEmpty) {
            return const Text(
              'No images uploaded yet.',
              style: TextStyle(color: Colors.grey),
            );
          }

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: imageUrls.map((url) {
              return Stack(
                children: [
                  // Image Preview
                  GestureDetector(
                    onTap: () {
                      Get.dialog(
                        Dialog(
                          child: Container(
                            width: Get.width * 0.8,
                            height: Get.width * 0.8,
                            child: Image.network(
                              url,
                              fit: BoxFit.contain,
                              headers: url.contains('/remote.php/dav/files/')
                                  ? WebDAVService.authHeaders()
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          headers: url.contains('/remote.php/dav/files/')
                              ? WebDAVService.authHeaders()
                              : null,
                        ),
                      ),
                    ),
                  ),

                  // Delete Button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Delete Image'),
                            content: const Text('Are you sure you want to delete this image?'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final fname = jobController.extractWebDavFileNameFromUrl(url);
                                  if (fname != null) {
                                    final webdav = WebDAVService();
                                    await webdav.deleteFile(fname);
                                  }
                                  imageUrls.remove(url);
                                  Get.back();
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
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
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  // Job Details Tab
  Widget _buildJobDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                const Text(
                  'Basic Job Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B34BE),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Job Position',
                  hintText: 'e.g., Senior Software Engineer',
                  controller: positionController,
                  icon: Icons.work,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: 'Location',
                  hintText: 'e.g., Jakarta, Indonesia',
                  controller: locationController,
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDatePickerBox(Get.context!, 'Start Date', true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDatePickerBox(Get.context!, 'End Date', false)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: 'Salary Range',
                  hintText: 'e.g., IDR 15,000,000 - 25,000,000',
                  controller: salaryController,
                  icon: Icons.monetization_on,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Job Type',
                  items: ['Full-time', 'Part-time', 'Contract', 'Freelance'],
                  selectedItem: selectedJobType,
                ),
                const SizedBox(height: 16),
                _buildMultipleChoiceField(
                  label: 'Job Category',
                  items: jobCategoriesData.map((category) => category.name).toList(),
                  selectedItems: selectedCategories,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                const Text(
                  'Job Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B34BE),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Description',
                  hintText: 'Describe the role, responsibilities, and what the job entails...',
                  controller: jobDescriptionController,
                  icon: Icons.description,
                  maxLines: 6,
                ),
                const SizedBox(height: 24),

                // Requirements Section - Improved UI
                _buildRequirementsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Job Requirements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B34BE),
          ),
        ),
        const SizedBox(height: 16),

        // Add requirement input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              TextField(
                controller: requirementsController,
                decoration: const InputDecoration(
                  hintText: 'Type a requirement here...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(fontSize: 14),
                maxLines: null,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final text = requirementsController.text.trim();
                    if (text.isNotEmpty) {
                      requirementsList.add({
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'text': text,
                        'isActive': false,
                      });
                      requirementsController.clear();
                    }
                  },
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text('Add', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B34BE),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Requirements list
        Obx(() {
          if (requirementsList.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.list_alt, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No requirements added yet',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add requirements above to get started',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Requirements List (${requirementsList.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B34BE),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the circle to mark as priority requirement. Drag to reorder.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),

              // Proper ReorderableListView
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requirementsList.length,
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = requirementsList.removeAt(oldIndex);
                  requirementsList.insert(newIndex, item);
                },
                itemBuilder: (context, index) {
                  final item = requirementsList[index];

                  return Container(
                    key: ValueKey(item['id']),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: item['isActive'] == true
                            ? const Color(0xFF6B34BE).withOpacity(0.3)
                            : Colors.grey[300]!,
                        width: item['isActive'] == true ? 2 : 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Optional: tap to toggle priority
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Drag handle - ini yang bisa di-drag
                              ReorderableDragStartListener(
                                index: index,
                                child: Icon(
                                  Icons.drag_handle,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Priority toggle circle
                              GestureDetector(
                                onTap: () {
                                  final current = item['isActive'] == true;
                                  requirementsList[index] = {
                                    'id': item['id'],
                                    'text': item['text'],
                                    'isActive': !current,
                                  };
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: item['isActive'] == true
                                          ? const Color(0xFF6B34BE)
                                          : Colors.grey[400]!,
                                      width: 2,
                                    ),
                                    color: item['isActive'] == true
                                        ? const Color(0xFF6B34BE)
                                        : Colors.transparent,
                                  ),
                                  child: item['isActive'] == true
                                      ? const Icon(
                                          Icons.circle,
                                          size: 12,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Text content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['text'] ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: item['isActive'] == true
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: item['isActive'] == true
                                            ? const Color(0xFF6B34BE)
                                            : Colors.black87,
                                      ),
                                    ),
                                    if (item['isActive'] == true) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Priority Requirement',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: const Color(0xFF6B34BE).withOpacity(0.7),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Delete button
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                onPressed: () {
                                  Get.dialog(
                                    AlertDialog(
                                      title: const Text('Delete Requirement'),
                                      content: Text('Remove "${item['text']}" from requirements?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.back(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            requirementsList.removeAt(index);
                                            Get.back();
                                          },
                                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        }),
      ],
    );
  }

  // Additional Tab
  Widget _buildAdditionalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                const Text(
                  'Benefits & Facilities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B34BE),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Benefits',
                  hintText: 'e.g., Health Insurance, Annual Bonus, Training Program...',
                  controller: facilitiesController,
                  icon: Icons.card_giftcard,
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Save Button - UPDATED WITH PROGRESS INDICATOR
  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() => ElevatedButton(
            onPressed: jobController.isLoading.value ? null : () => _handleUpdate(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B34BE),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: jobController.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Update Job',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          )),
    );
  }

  // Dropdown Helper Widget
  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required RxString selectedItem,
  }) {
    return Obx(() => DropdownButtonFormField<String>(
          value: selectedItem.value.isNotEmpty ? selectedItem.value : null,
          decoration: InputDecoration(
            labelText: label,
            hintText: 'Choose $label',
            labelStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFF6B34BE)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6B34BE)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: jobController.isLoading.value ? null : (value) {
            selectedItem.value = value!;
          },
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6B34BE)),
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
        ));
  }

  Widget _buildMultipleChoiceField({
    required String label,
    required List<String> items,
    required RxList<String> selectedItems,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B34BE),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => GestureDetector(
          onTap: jobController.isLoading.value ? null : () {
            Get.dialog(
              AlertDialog(
                title: Text('Choose $label'),
                content: SingleChildScrollView(
                  child: Column(
                    children: items.map((item) {
                      return Obx(() => CheckboxListTile(
                            value: selectedItems.contains(item),
                            onChanged: (isSelected) {
                              if (isSelected ?? false) {
                                selectedItems.add(item);
                              } else {
                                selectedItems.remove(item);
                              }
                            },
                            title: Text(item),
                          ));
                    }).toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          },
          child: SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: jobController.isLoading.value ? Colors.grey[100] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Obx(() {
                if (selectedItems.isEmpty) {
                  return Text(
                    'Choose $label',
                    style: TextStyle(
                      color: jobController.isLoading.value ? Colors.grey[500] : Colors.grey[600], 
                      fontSize: 16
                    ),
                  );
                } else {
                  return Text(
                    selectedItems.join(', '),
                    style: TextStyle(
                      color: jobController.isLoading.value ? Colors.grey[600] : Colors.black87, 
                      fontSize: 16
                    ),
                  );
                }
              }),
            ),
          ),
        )),
      ],
    );
  }

  void _handleUpdate() async {
    if (!_validateInputs()) {
      return;
    }

    final updatedFields = {
      'position': positionController.text.trim(),
      'location': locationController.text.trim(),
      'jobType': selectedJobType.value,
      'categories': selectedCategories.toList(),
      'salary': salaryController.text.trim(),
      'jobDetails.jobDescription': jobDescriptionController.text.trim(),
      'jobDetails.requirements': requirementsList.toList(),
      'jobDetails.facilities': facilitiesController.text
          .split(',')
          .map((e) => e.trim())
          .toList(),
      'jobDetails.companyDetails.aboutCompany': aboutCompanyController.text.trim(),
      'jobDetails.companyDetails.industry': industryController.text.trim(),
      'jobDetails.companyDetails.website': websiteController.text.trim(),
      'jobDetails.companyDetails.companyGalleryPaths': galleryImageUrls.toList(),
      'startDate': jobController.startDate.value?.toIso8601String(),
      'endDate': jobController.endDate.value?.toIso8601String(),
    };

    final success = await jobController.updateJob(jobIndex, updatedFields);

    if (success) {
      Get.snackbar(
        'Success',
        'Job updated successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
      Get.back();
    }
  }

  // Validation Function
  bool _validateInputs() {
    final List<String> emptyFields = [];

    void checkField(String fieldName, String value) {
      if (value.trim().isEmpty) {
        emptyFields.add(fieldName);
      }
    }

    // Basic Job Info
    checkField('Job Position', positionController.text);
    checkField('Location', locationController.text);
    checkField('Salary', salaryController.text);
  if (jobController.startDate.value == null) emptyFields.add('Start Date');
  if (jobController.endDate.value == null) emptyFields.add('End Date');

    // Dropdowns
    if (selectedJobType.value.isEmpty) emptyFields.add('Job Type');
    if (selectedCategories.isEmpty) {
      emptyFields.add('Job Categories');
    }

    // Job Details
    checkField('Job Description', jobDescriptionController.text);
    if (requirementsList.isEmpty) emptyFields.add('Requirements');

    // Company Info
    checkField('Industry', industryController.text);
    checkField('Website', websiteController.text);
    checkField('About Company', aboutCompanyController.text);

    // Benefits
    checkField('Benefits & Facilities', facilitiesController.text);

    // Gallery
    if (galleryImageUrls.isEmpty) {
      emptyFields.add('Company Gallery Images');
    }

    if (emptyFields.isNotEmpty) {
      Get.snackbar(
        'Incomplete Form',
        'Please fill in the following fields:\n${emptyFields.join('\n')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    }

    return true;
  }
}
