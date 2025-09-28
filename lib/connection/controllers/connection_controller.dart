import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_settings/app_settings.dart';
import '../../non_login/home/views/home_view_non_login.dart';
import '../views/no_connection_view.dart';

class ConnectionController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = false.obs; 
  final RxBool wasPreviouslyOffline = false.obs; 
  bool isFirstCheck = true; 
  String? lastRoute; 

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen((connectivityResults) {
      _updateConnectionStatus(connectivityResults.first);
    });
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityResult.first);
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      if (isConnected.value) {
        _showAwesomeSnackbar(
          title: 'Offline',
          message: 'No internet connection. Please check your connection.',
          contentType: ContentType.failure,
          showSettingsButton: true,
        );
      }
      isConnected.value = false;
      wasPreviouslyOffline.value = true;
      if (Get.currentRoute != '/NoConnectionView') {
        lastRoute = Get.currentRoute;
      }
      Get.to(() => const NoConnectionView());
    } else {
      if (!isFirstCheck && !isConnected.value && wasPreviouslyOffline.value) {
        _showAwesomeSnackbar(
          title: 'Online',
          message: 'You\'re back online!',
          contentType: ContentType.success,
        );
        wasPreviouslyOffline.value = false;
      }
      isConnected.value = true;
      isFirstCheck = false;
      if (Get.currentRoute == '/NoConnectionView') {
        if (lastRoute != null) {
          Get.back();
        } else {
          Get.offAll(() => HomeViewNonLogin());
        }
      }
    }
  }

  void _showAwesomeSnackbar({
    required String title,
    required String message,
    required ContentType contentType,
    bool showSettingsButton = false,
  }) {
    final snackBarContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: contentType,
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          messageTextStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
        if (showSettingsButton)
          const SizedBox(height: 10),
        if (showSettingsButton)
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Tombol warna merah
                foregroundColor: Colors.white, // Text warna putih
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Border radius lebih kecil
                ),
              ),
              onPressed: () {
                AppSettings.openAppSettingsPanel(
                  AppSettingsPanelType.internetConnectivity,
                );
              },
              child: const Text('Buka Pengaturan'),
            ),
          ),
      ],
    );

    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 100.0),
        content: snackBarContent,
      ),
    );
  }

  Future<void> retryConnection() async {
    await _checkConnection();
    if (isConnected.value) {
      if (lastRoute != null) {
        Get.offNamed(lastRoute!);
      } else {
        Get.offAll(() => HomeViewNonLogin());
      }
    } else {
      _showAwesomeSnackbar(
        title: 'Error',
        message: 'No internet connection. Please try again.',
        contentType: ContentType.failure,
        showSettingsButton: true,
      );
    }
  }
}
