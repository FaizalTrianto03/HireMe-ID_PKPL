import 'package:HireMe_Id/widgets/navbar_admin.dart';
import 'package:HireMe_Id/widgets/navbar_recruiter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:HireMe_Id/widgets/navbar_non_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/navbar_login.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Remember Me state
  var isRememberMe = true.obs;

  User? get currentUser => _auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    loadRememberedCredentials();
  }

  // Load email dan password yang disimpan
  Future<void> loadRememberedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isRememberMe.value = prefs.getBool('rememberMe') ?? false;
      if (isRememberMe.value) {
        String? email = prefs.getString('email');
        String? password = prefs.getString('password');
        if (email != null && password != null) {
          await login(email, password); // Auto-login jika Remember Me aktif
        }
      }
    } catch (e) {
      _showErrorSnackbar("Error", "Failed to load saved credentials");
    }
  }

  // Fungsi untuk toggle Remember Me
  void toggleRememberMe(bool value) {
    try {
      isRememberMe.value = value;
    } catch (e) {
      _showErrorSnackbar("Error", "Failed to update remember me setting");
    }
  }

  // Login dengan email dan password
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Cek role dari Firestore
      final docSnapshot =
          await _firestore.collection('Accounts').doc(email).get();
      if (docSnapshot.exists) {
        final role = docSnapshot.data()?['role'] ?? '';

        // Navigasi sesuai role
        if (role == 'jobseeker') {
          Get.offAll(() => NavbarLoggedIn());
        } else if (role == 'recruiter') {
          Get.offAll(() => NavbarRecruiter());
        } else if (role == 'admin') {
          Get.offAll(() => NavbarAdmin());
        } else {
          _showErrorSnackbar("Login Error", "Unknown user role");
          return;
        }
      } else {
        _showErrorSnackbar("Login Error", "Account not found in database");
        return;
      }

      // Simpan status login jika Remember Me aktif
      if (isRememberMe.value) {
        await _saveCredentials(email, password);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user found with this email address";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email address format";
          break;
        case 'user-disabled':
          errorMessage = "This account has been disabled";
          break;
        case 'too-many-requests':
          errorMessage = "Too many failed attempts. Please try again later";
          break;
        case 'network-request-failed':
          errorMessage = "Network error. Please check your connection";
          break;
        default:
          errorMessage = "Login failed. Please try again";
      }
      _showErrorSnackbar("Login Failed", errorMessage);
    } on FirebaseException catch (e) {
      _showErrorSnackbar("Database Error", "Failed to access user data. Please try again");
    } catch (e) {
      _showErrorSnackbar("Login Error", "An unexpected error occurred. Please try again");
    }
  }

  // Fungsi registrasi untuk Job Seeker
  Future<void> register_job(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection('Accounts').doc(email).set({
        'firstname': '',
        'lastname': '',
        'email_address': email,
        'phone_number': '',
        'address': '',
        'role': 'jobseeker',
        'created_at': FieldValue.serverTimestamp(),
      });

      await _saveLoginStatus();
      Get.offAll(() => NavbarLoggedIn());
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = "Password is too weak. Please use a stronger password";
          break;
        case 'email-already-in-use':
          errorMessage = "An account already exists with this email";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email address format";
          break;
        case 'operation-not-allowed':
          errorMessage = "Email/password accounts are not enabled";
          break;
        case 'network-request-failed':
          errorMessage = "Network error. Please check your connection";
          break;
        default:
          errorMessage = "Registration failed. Please try again";
      }
      _showErrorSnackbar("Registration Failed", errorMessage);
    } on FirebaseException catch (e) {
      _showErrorSnackbar("Database Error", "Failed to save account data. Please try again");
    } catch (e) {
      _showErrorSnackbar("Registration Error", "An unexpected error occurred. Please try again");
    }
  }

  // Fungsi registrasi untuk Recruiter
  Future<void> register_recruiter(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection('Accounts').doc(email).set({
        'firstname': '',
        'lastname': '',
        'email_address': email,
        'phone_number': '',
        'address': '',
        'role': 'recruiter',
        'created_at': FieldValue.serverTimestamp(),
        'company_name': '',
        'company_position': '',
      });

      await _saveLoginStatus();
      Get.offAll(() => NavbarRecruiter());
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = "Password is too weak. Please use a stronger password";
          break;
        case 'email-already-in-use':
          errorMessage = "An account already exists with this email";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email address format";
          break;
        case 'operation-not-allowed':
          errorMessage = "Email/password accounts are not enabled";
          break;
        case 'network-request-failed':
          errorMessage = "Network error. Please check your connection";
          break;
        default:
          errorMessage = "Registration failed. Please try again";
      }
      _showErrorSnackbar("Registration Failed", errorMessage);
    } on FirebaseException catch (e) {
      _showErrorSnackbar("Database Error", "Failed to save recruiter data. Please try again");
    } catch (e) {
      _showErrorSnackbar("Registration Error", "An unexpected error occurred. Please try again");
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        "Success",
        "Password reset email sent.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF6B34BE),
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user found with this email address";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email address format";
          break;
        case 'network-request-failed':
          errorMessage = "Network error. Please check your connection";
          break;
        default:
          errorMessage = "Failed to send reset email. Please try again";
      }
      _showErrorSnackbar("Reset Password Failed", errorMessage);
    } catch (e) {
      _showErrorSnackbar("Reset Password Error", "An unexpected error occurred. Please try again");
    }
  }

  // Login dengan Google untuk Job Seeker
  Future<void> loginWithGoogle_job() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _showErrorSnackbar("Login Cancelled", "No account selected");
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Cek apakah user sudah ada di Firestore
        final docSnapshot =
            await _firestore.collection('Accounts').doc(user.email).get();

        if (!docSnapshot.exists) {
          // Jika belum ada, buat dokumen baru
          await _firestore.collection('Accounts').doc(user.email).set({
            'firstname': user.displayName?.split(' ').first ?? '',
            'lastname': user.displayName?.split(' ').last ?? '',
            'email_address': user.email,
            'phone_number': user.phoneNumber ?? '',
            'address': '',
            'role': 'jobseeker',
            'created_at': FieldValue.serverTimestamp(),
          });
        }

        await _saveLoginStatus();
        Get.offAll(() => NavbarLoggedIn());
      } else {
        _showErrorSnackbar("Login Failed", "Google Sign-In authentication failed");
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = "An account already exists with a different sign-in method";
          break;
        case 'invalid-credential':
          errorMessage = "Invalid Google credentials";
          break;
        case 'operation-not-allowed':
          errorMessage = "Google Sign-In is not enabled";
          break;
        case 'user-disabled':
          errorMessage = "This account has been disabled";
          break;
        case 'network-request-failed':
          errorMessage = "Network error. Please check your connection";
          break;
        default:
          errorMessage = "Google Sign-In failed. Please try again";
      }
      _showErrorSnackbar("Google Sign-In Failed", errorMessage);
    } on FirebaseException catch (e) {
      _showErrorSnackbar("Database Error", "Failed to save account data. Please try again");
    } catch (e) {
      _showErrorSnackbar("Google Sign-In Error", "An unexpected error occurred. Please try again");
    }
  }

  // Login dengan Google untuk Recruiter
  Future<void> loginWithGoogle_recruiter() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _showErrorSnackbar("Login Cancelled", "No account selected");
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Cek apakah user sudah ada di Firestore
        final docSnapshot =
            await _firestore.collection('Accounts').doc(user.email).get();

        if (!docSnapshot.exists) {
          // Jika belum ada, buat dokumen baru
          await _firestore.collection('Accounts').doc(user.email).set({
            'firstname': user.displayName?.split(' ').first ?? '',
            'lastname': user.displayName?.split(' ').last ?? '',
            'email_address': user.email,
            'phone_number': user.phoneNumber ?? '',
            'address': '',
            'role': 'recruiter',
            'created_at': FieldValue.serverTimestamp(),
            'company_name': '',
            'company_position': '',
          });
        }

        await _saveLoginStatus();
        Get.offAll(() => NavbarRecruiter());
      } else {
        _showErrorSnackbar("Login Failed", "Google Sign-In authentication failed");
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = "An account already exists with a different sign-in method";
          break;
        case 'invalid-credential':
          errorMessage = "Invalid Google credentials";
          break;
        case 'operation-not-allowed':
          errorMessage = "Google Sign-In is not enabled";
          break;
        case 'user-disabled':
          errorMessage = "This account has been disabled";
          break;
        case 'network-request-failed':
          errorMessage = "Network error. Please check your connection";
          break;
        default:
          errorMessage = "Google Sign-In failed. Please try again";
      }
      _showErrorSnackbar("Google Sign-In Failed", errorMessage);
    } on FirebaseException catch (e) {
      _showErrorSnackbar("Database Error", "Failed to save recruiter data. Please try again");
    } catch (e) {
      _showErrorSnackbar("Google Sign-In Error", "An unexpected error occurred. Please try again");
    }
  }

  // Logout dan hapus data Remember Me
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await _clearCredentials();
      Get.offAll(() => NavbarNonLogin());
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar("Logout Error", "Failed to sign out from Firebase");
    } catch (e) {
      // Even if logout fails, still navigate to login screen for security
      await _clearCredentials();
      Get.offAll(() => NavbarNonLogin());
      _showErrorSnackbar("Logout Warning", "Logout completed but some data may not be cleared");
    }
  }

  // Simpan email dan password ke SharedPreferences
  Future<void> _saveCredentials(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', true);
      await prefs.setString('email', email);
      await prefs.setString('password', password);
    } catch (e) {
      _showErrorSnackbar("Save Error", "Failed to save login credentials");
    }
  }

  // Hapus email dan password dari SharedPreferences
  Future<void> _clearCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('rememberMe');
      await prefs.remove('email');
      await prefs.remove('password');
    } catch (e) {
      _showErrorSnackbar("Clear Error", "Failed to clear saved credentials");
    }
  }

  // Fungsi untuk menunjukkan error snackbar
  void _showErrorSnackbar(String title, String message) {
    try {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      // Fallback jika Get.snackbar gagal
      print("Error showing snackbar: $title - $message");
    }
  }
}

Future<void> _saveLoginStatus() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  } catch (e) {
    print("Failed to save login status: $e");
  }
}

Future<void> _clearLoginStatus() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
  } catch (e) {
    print("Failed to clear login status: $e");
  }
}

void _showErrorSnackbar(String title, String message) {
  try {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    );
  } catch (e) {
    print("Error showing snackbar: $title - $message");
  }
}
