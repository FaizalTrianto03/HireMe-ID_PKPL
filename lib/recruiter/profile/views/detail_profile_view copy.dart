// import 'package:HireMe_Id/login/profile/views/map_selection_view.dart.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../controllers/profile_controller.dart';

// class DetailProfileView extends StatelessWidget {
//   final ProfileController controller = Get.find<ProfileController>();
//   final TextEditingController firstNameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController companyNameController = TextEditingController();
//   final TextEditingController companyPositionController = TextEditingController();
//   final RxString profileImage = ''.obs;
//   final RxBool isFormValid = false.obs;

//   DetailProfileView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       if (controller.profileData.isNotEmpty) {
//         final profileData = controller.profileData;
//         firstNameController.text = profileData['firstname'] ?? '';
//         lastNameController.text = profileData['lastname'] ?? '';
//         phoneController.text = profileData['phone_number'] ?? '';
//         companyNameController.text = profileData['company_name'] ?? '';
//         companyPositionController.text = profileData['company_position'] ?? '';
//         profileImage.value = profileData['profile_image'] ?? '';
//       }
//       _validateForm();
//     });

//     return Scaffold(
//       body: Stack(
//         children: [
//           _buildGradientBackground(),
//           SafeArea(
//             child: Column(
//               children: [
//                 _buildAppBar(),
//                 Expanded(
//                   child: Container(
//                     margin: const EdgeInsets.all(16),
//                     decoration: _boxDecoration(),
//                     child: Obx(() {
//                       if (controller.profileData.isEmpty) {
//                         return const Center(child: Text('Profile not found.'));
//                       }
//                       return _buildFormContent();
//                     }),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGradientBackground() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFFD6C5FF), Color(0xFF6B34BE)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//     );
//   }

//   Widget _buildAppBar() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () => Get.back(),
//           ),
//           const Expanded(
//             child: Text(
//               'Edit Profile',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           Obx(() => TextButton(
//                 onPressed: isFormValid.value
//                     ? () {
//                         controller.updateProfile(
//                           firstNameController.text,
//                           lastNameController.text,
//                           phoneController.text,
//                           controller.profileData['address'] ?? '',
//                           companyNameController.text,
//                           companyPositionController.text,
//                           profileImage.value,
//                         );
//                       }
//                     : null,
//                 child: Text(
//                   'Save',
//                   style: TextStyle(
//                     color: isFormValid.value ? Colors.white : Colors.white60,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               )),
//         ],
//       ),
//     );
//   }

//   Widget _buildFormContent() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         children: [
//           _buildProfileImage(),
//           const SizedBox(height: 32),
//           _buildInputField(
//             label: 'First Name',
//             controller: firstNameController,
//             icon: Icons.person_outline,
//           ),
//           _buildInputField(
//             label: 'Last Name',
//             controller: lastNameController,
//             icon: Icons.person_outline,
//           ),
//           _buildInputField(
//             label: 'Phone Number',
//             controller: phoneController,
//             icon: Icons.phone_outlined,
//             keyboardType: TextInputType.phone,
//           ),
//           _buildInputField(
//             label: 'Company Name',
//             controller: companyNameController,
//             icon: Icons.business_outlined,
//           ),
//           _buildInputField(
//             label: 'Company Position',
//             controller: companyPositionController,
//             icon: Icons.work_outline,
//           ),
//           _buildAddressField(),
//         ],
//       ),
//     );
//   }

//   Widget _buildAddressField() {
//   return Container(
//     margin: const EdgeInsets.only(bottom: 20),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Address',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF6B34BE),
//           ),
//         ),
//         const SizedBox(height: 8),
//         GestureDetector(
//           onTap: () => Get.to(() => MapSelectionView())?.then((result) {
//             if (result != null) {
//               // Karena result adalah Map<String, dynamic>
//               final Map<String, dynamic> selectedLocation = result;
//               controller.profileData['address'] = selectedLocation['address'];
//               // Jika perlu menyimpan posisi juga
//               // controller.profileData['position'] = selectedLocation['position'];
//               _validateForm();
//             }
//           }),
//           child: Obx(() {
//             final address =
//                 controller.profileData['address'] ?? 'Tap to select address';
//             return Container(
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey[300]!),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.location_on_outlined, color: Color(0xFF6B34BE)),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Text(
//                         address.toString(),
//                         style: const TextStyle(fontSize: 14, color: Colors.black87),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }),
//         ),
//       ],
//     ),
//   );
// }

//   BoxDecoration _boxDecoration() {
//     return BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(20),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.1),
//           blurRadius: 10,
//           offset: const Offset(0, 5),
//         ),
//       ],
//     );
//   }

//   void _validateForm() {
//     isFormValid.value = firstNameController.text.isNotEmpty &&
//         lastNameController.text.isNotEmpty &&
//         phoneController.text.isNotEmpty &&
//         companyNameController.text.isNotEmpty &&
//         companyPositionController.text.isNotEmpty;
//   }

//   void _showOpenInMapsDialog() {
//     final address = controller.profileData['address'] ?? '';
//     if (address.isEmpty) {
//       Get.snackbar('Error', 'Address not available');
//     } else {
//       Get.dialog(
//         AlertDialog(
//           title: const Text('Open in Google Maps?'),
//           content: Text('Do you want to open this address in Google Maps?\n\n$address'),
//           actions: [
//             TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
//             TextButton(
//               onPressed: () {
//                 controller.selectLocation();
//                 Get.back();
//               },
//               child: const Text('Open Google Maps'),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   Widget _buildProfileImage() {
//   return Stack(
//     children: [
//       // Widget foto profil yang bisa diklik untuk melihat foto
//       GestureDetector(
//         onTap: () => controller.viewProfileImage(),  // Fungsi baru untuk melihat foto
//         child: Obx(() {
//           final image = profileImage.value;
//           return CircleAvatar(
//             radius: 60,
//             backgroundColor: const Color(0xFFD6C5FF),
//             backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
//             child: image.isEmpty ? const Icon(Icons.person, size: 60, color: Color(0xFF6B34BE)) : null,
//           );
//         }),
//       ),
//       // Icon pensil untuk mengganti foto
//       Positioned(
//         bottom: 0,
//         right: 0,
//         child: GestureDetector(
//           onTap: () => controller.pickProfileImage(),
//           child: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: const BoxDecoration(
//               color: Color(0xFF6B34BE),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.edit,
//               size: 20,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     ],
//   );
// }


//   Widget _buildInputField({
//     required String label,
//     required TextEditingController controller,
//     required IconData icon,
//     TextInputType? keyboardType,
//     int maxLines = 1,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF6B34BE))),
//           const SizedBox(height: 8),
//           TextField(
//             controller: controller,
//             keyboardType: keyboardType,
//             maxLines: maxLines,
//             decoration: InputDecoration(
//               prefixIcon: Icon(icon, color: const Color(0xFF6B34BE)),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             ),
//             onChanged: (value) => _validateForm(),
//           ),
//         ],
//       ),
//     );
//   }
// }
