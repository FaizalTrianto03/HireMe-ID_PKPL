import 'package:HireMe_Id/recruiter/profile/views/map_selection_view.dart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:HireMe_Id/utils/webdav_service.dart';

import '../controllers/profile_controller.dart';

class DetailProfileView extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();

// Controllers untuk input field
final TextEditingController firstNameController = TextEditingController();
final TextEditingController lastNameController = TextEditingController();
final TextEditingController phoneController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController addressController = TextEditingController();
final TextEditingController companyNameController = TextEditingController(); // Tambahan untuk Company Name
final TextEditingController companyPositionController = TextEditingController(); // Tambahan untuk Company Position

// Observables
final RxString profileImage = ''.obs;
final RxBool isFormValid = false.obs;

  DetailProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (controller.profileData.isNotEmpty) {
      final profileData = controller.profileData;

      // Mengisi field dengan data dari profileData
      firstNameController.text = profileData['firstname'] ?? '';
      lastNameController.text = profileData['lastname'] ?? '';
      phoneController.text = profileData['phone_number'] ?? '';
      emailController.text = profileData['email_address'] ??
          controller.auth.currentUser?.email ??
          ''; // Ambil dari auth jika kosong
      addressController.text = profileData['address'] ?? '';
      companyNameController.text = profileData['company_name'] ?? '';
      companyPositionController.text = profileData['company_position'] ?? '';
      profileImage.value = profileData['profile_image'] ?? '';
    }
  });

  return Scaffold(
    body: Stack(
      children: [
        _buildGradientBackground(),
        SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: _boxDecoration(),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      // Tampilkan loading indicator jika sedang memuat
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6B34BE),
                        ),
                      );
                    }
                    if (controller.profileData.isEmpty) {
                      // Tampilkan pesan jika profile tidak ditemukan
                      return const Center(child: Text('Profile not found.'));
                    }
                    return _buildFormContent(); // Form data profil
                  }),
                ),
              ),
              _buildSaveButton(), // Tombol Save
            ],
          ),
        ),
      ],
    ),
  );
}


  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD6C5FF), Color(0xFF6B34BE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 60, // Tinggi konsisten untuk AppBar
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Mengirimkan informasi bahwa data telah diperbarui
                Get.back();
              },
            ),
          ),
          const Align(
            alignment: Alignment.center,
            child: Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        _buildProfileImage(),
        const SizedBox(height: 32),
        _buildInputField(
          label: 'First Name',
          controller: firstNameController,
          icon: Icons.person_outline,
        ),
        _buildInputField(
          label: 'Last Name',
          controller: lastNameController,
          icon: Icons.person_outline,
        ),
        _buildInputField(
          label: 'Phone Number',
          controller: phoneController,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        _buildReadOnlyField(
          label: 'Email Address',
          controller: emailController,
          icon: Icons.email_outlined,
        ),
        _buildInputField(
          label: 'Company Name',
          controller: companyNameController,
          icon: Icons.business_outlined,
        ),
        _buildInputField(
          label: 'Company Position',
          controller: companyPositionController,
          icon: Icons.work_outline,
        ),
        _buildAddressField(),
      ],
    ),
  );
}


  Widget _buildAddressField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Address',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B34BE),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => Get.to(() => MapSelectionView())?.then((result) {
              if (result != null) {
                final Map<String, dynamic> selectedLocation = result;
                controller.profileData['address'] = selectedLocation['address'];
                addressController.text = selectedLocation['address'];
                _validateForm();
              }
            }),
            child: Obx(() {
              final address =
                  controller.profileData['address'] ?? 'Tap to select address';
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: Color(0xFF6B34BE)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          address.toString(),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
  return Container(
    padding: const EdgeInsets.all(16),
    child: SizedBox(
      width: double.infinity, // Membuat tombol selebar layar
      child: ElevatedButton(
        onPressed: () async {
          // Panggil fungsi updateProfile
          await controller.updateProfile(
            firstNameController.text,
            lastNameController.text,
            phoneController.text,
            addressController.text,
            companyNameController.text,
            companyPositionController.text,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF6B34BE)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Save',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B34BE),
          ),
        ),
      ),
    ),
  );
}


  void _validateForm() {
    isFormValid.value = firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        addressController.text.isNotEmpty;
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Obx(() {
          final image = profileImage.value;
          return GestureDetector(
            onTap: () {
              if (image.isNotEmpty) {
                Get.dialog(
                  Dialog(
                    backgroundColor: Colors.transparent,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () => Get.back(),
                          ),
                        ),
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              image,
                              fit: BoxFit.contain,
                              headers: image.contains('/remote.php/dav/files/')
                                  ? WebDAVService.authHeaders()
                                  : null,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.broken_image,
                                  size: 100,
                                  color: Colors.white,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  barrierDismissible: true,
                );
              }
            },
            child: CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFFD6C5FF),
              child: ClipOval(
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        headers: image.contains('/remote.php/dav/files/')
                            ? WebDAVService.authHeaders()
                            : null,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF6B34BE),
                          );
                        },
                      )
                    : const Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFF6B34BE),
                      ),
              ),
            ),
          );
        }),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () async {
              await controller.pickProfileImage();
              profileImage.value =
                  controller.profileImage.value; // Update image
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF6B34BE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B34BE),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF6B34BE)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B34BE),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF6B34BE)),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
