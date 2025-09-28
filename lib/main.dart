// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'routes/app_pages.dart';
// import 'widgets/navbar_non_login.dart';
// import 'utils/setup_mic.dart'; // Import SpeechService

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized(); // Inisialisasi widget binding
//   await Firebase.initializeApp(); // Inisialisasi Firebase

//   // Inisialisasi global SpeechService
//   final SpeechService speechService = SpeechService();
//   await speechService.initialize(); // Pastikan diinisialisasi sebelum aplikasi berjalan

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false, // Menghapus banner debug
//       title: 'HireMe.id',
//       theme: ThemeData(
//         primaryColor: const Color(0xFF6B34BE), // Warna utama aplikasi
//         scaffoldBackgroundColor: const Color(0xFFF9F9F9), // Latar belakang
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.white, // Warna app bar putih
//           elevation: 0, // Hilangkan bayangan app bar
//           titleTextStyle: TextStyle(
//             color: Colors.black,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//           iconTheme: IconThemeData(color: Colors.black), // Warna ikon
//         ),
//       ),
//       home: NavbarNonLogin(), // Halaman awal
//       getPages: AppPages.pages, // Rute aplikasi
//     );
//   }
// }

import 'package:HireMe_Id/dependency_injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'utils/setup_mic.dart'; // Import SpeechService
import 'widgets/navbar_non_login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ✅ Import Controllers
import 'non_login/home/controllers/home_controller.dart';
import 'login/home/controllers/home_controller_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Inisialisasi widget binding
  // Load environment variables (.env)
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(); // Inisialisasi Firebase

  // ✅ Inisialisasi global SpeechService
  final SpeechService speechService = SpeechService();
  await speechService.initialize(); // Pastikan diinisialisasi sebelum aplikasi berjalan

  // ✅ Inisialisasi Dependency Injection
  DependencyInjection.init();

  // ✅ Inisialisasi Controllers
  Get.put(HomeController()); // Inisialisasi HomeController
  Get.put(HomeControllerLogin()); // Inisialisasi HomeControllerLogin

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false, // Menghapus banner debug
      title: 'HireMe.id',
      theme: ThemeData(
        primaryColor: const Color(0xFF6B34BE), // Warna utama aplikasi
        scaffoldBackgroundColor: const Color(0xFFF9F9F9), // Latar belakang
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // Warna app bar putih
          elevation: 0, // Hilangkan bayangan app bar
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black), // Warna ikon
        ),
      ),
      home: NavbarNonLogin(), // Halaman awal
      getPages: AppPages.pages, // Rute aplikasi
    );
  }
}
