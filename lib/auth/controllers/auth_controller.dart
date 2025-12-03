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
  // Dependency injection untuk test agar tidak memanggil platform channel
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  final bool skipAutoLoad; // true pada unit test agar tidak memanggil SharedPreferences

  AuthController({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
    this.skipAutoLoad = false,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Remember Me state
  var isRememberMe = true.obs;

  User? get currentUser => _auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    if (!skipAutoLoad) {
      loadRememberedCredentials();
    }
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

  // ============================================
  // KEBUTUHAN FUNGSIONAL LOGIN
  // ============================================
  // FR-LOGIN-001: Validasi Format Email dan Kekuatan Password
  // FR-LOGIN-002: Verifikasi Status Akun dan Role User
  
  /// Validasi format email (FR-LOGIN-001)
  /// Test Positif: Email valid (user@example.com) -> return true
  /// Test Negatif: Email invalid (userexample.com, @example.com, user@) -> return false & show error
  bool validateEmailFormat(String email, {bool showErrors = true}) {
    if (email.trim().isEmpty) {
      if (showErrors) {
        _showErrorSnackbar("Validation Error", "Email cannot be empty");
      }
      return false;
    }
    
    // Regex untuk validasi format email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    if (!emailRegex.hasMatch(email.trim())) {
      if (showErrors) {
        _showErrorSnackbar("Validation Error", "Invalid email format. Please use format: user@example.com");
      }
      return false;
    }
    
    return true;
  }
  
  /// Validasi kekuatan password untuk login (FR-LOGIN-001)
  /// Test Positif: Password minimal 6 karakter -> return true
  /// Test Negatif: Password < 6 karakter -> return false & show error
  bool validatePasswordStrength(String password, {bool isRegistration = false, bool showErrors = true}) {
    if (password.isEmpty) {
      if (showErrors) {
        _showErrorSnackbar("Validation Error", "Password cannot be empty");
      }
      return false;
    }
    
    if (isRegistration) {
      // Untuk registration, password harus lebih kuat
      if (password.length < 8) {
        if (showErrors) {
          _showErrorSnackbar("Validation Error", "Password must be at least 8 characters long");
        }
        return false;
      }
      
      // Cek apakah password mengandung huruf dan angka
      final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
      final hasNumber = RegExp(r'[0-9]').hasMatch(password);
      
      if (!hasLetter || !hasNumber) {
        if (showErrors) {
          _showErrorSnackbar("Validation Error", 
            "Password must contain both letters and numbers for security");
        }
        return false;
      }
    } else {
      // Untuk login, minimal 6 karakter (Firebase default)
      if (password.length < 6) {
        if (showErrors) {
          _showErrorSnackbar("Validation Error", "Password must be at least 6 characters long");
        }
        return false;
      }
    }
    
    return true;
  }

  // Login dengan email dan password
  Future<void> login(String email, String password) async {
    try {
      // FR-LOGIN-001: Validasi format email dan password
      if (!validateEmailFormat(email)) {
        return; // Stop jika email tidak valid
      }
      
      if (!validatePasswordStrength(password)) {
        return; // Stop jika password tidak valid
      }
      
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // FR-LOGIN-002: Verifikasi status akun dan role user
      // Test Positif: Account exists dengan role valid -> navigate ke halaman sesuai role
      // Test Negatif: Account tidak ada atau role invalid -> show error & logout
      final docSnapshot =
          await _firestore.collection('Accounts').doc(email).get();
      
      if (!docSnapshot.exists) {
        // Account tidak ditemukan di database
        await _auth.signOut(); // Logout dari Firebase Auth
        _showErrorSnackbar("Login Error", 
          "Account not found in database. Please register first or contact support.");
        return;
      }
      
      final accountData = docSnapshot.data();
      if (accountData == null) {
        await _auth.signOut();
        _showErrorSnackbar("Login Error", "Account data is corrupted. Please contact support.");
        return;
      }
      
      // Validasi role
      final role = accountData['role'] ?? '';
      if (role.isEmpty) {
        await _auth.signOut();
        _showErrorSnackbar("Login Error", "Account role is not set. Please contact support.");
        return;
      }
      
      // Cek apakah account di-disable (optional field untuk future enhancement)
      final isDisabled = accountData['is_disabled'] ?? false;
      if (isDisabled) {
        await _auth.signOut();
        _showErrorSnackbar("Login Error", 
          "This account has been disabled. Please contact support for assistance.");
        return;
      }
      
      // Validasi role yang diizinkan
      final List<String> allowedRoles = ['jobseeker', 'recruiter', 'admin'];
      if (!allowedRoles.contains(role)) {
        await _auth.signOut();
        _showErrorSnackbar("Login Error", 
          "Invalid account role: $role. Please contact support.");
        return;
      }

      // Navigasi sesuai role
      if (role == 'jobseeker') {
        Get.offAll(() => NavbarLoggedIn());
      } else if (role == 'recruiter') {
        Get.offAll(() => NavbarRecruiter());
      } else if (role == 'admin') {
        Get.offAll(() => NavbarAdmin());
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
    } on FirebaseException {
      _showErrorSnackbar("Database Error", "Failed to access user data. Please try again");
    } catch (e) {
      _showErrorSnackbar("Login Error", "An unexpected error occurred. Please try again");
    }
  }

  // ============================================
  // KEBUTUHAN FUNGSIONAL REGISTER
  // ============================================
  // FR-REGISTER-001: Validasi Keunikan Email dan Kompleksitas Password
  // FR-REGISTER-002: Validasi Field Required dan Role Selection
  
  /// Validasi keunikan email sebelum registrasi (FR-REGISTER-001)
  /// Test Positif: Email belum terdaftar -> return true
  /// Test Negatif: Email sudah terdaftar -> return false & show error
  Future<bool> validateEmailUniqueness(String email) async {
    try {
      // Cek di Firebase Auth
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        _showErrorSnackbar("Registration Error", 
          "This email is already registered. Please use a different email or try logging in.");
        return false;
      }
      
      // Double check di Firestore
      final docSnapshot = await _firestore.collection('Accounts').doc(email).get();
      if (docSnapshot.exists) {
        _showErrorSnackbar("Registration Error", 
          "This email is already registered in our system. Please login instead.");
        return false;
      }
      
      return true;
    } catch (e) {
      _showErrorSnackbar("Validation Error", 
        "Failed to verify email uniqueness. Please check your internet connection.");
      return false;
    }
  }
  
  /// Validasi role selection (FR-REGISTER-002)
  /// Test Positif: Role adalah 'jobseeker' atau 'recruiter' -> return true
  /// Test Negatif: Role kosong atau invalid -> return false & show error
  bool validateRoleSelection(String role, {bool showErrors = true}) {
    if (role.isEmpty) {
      if (showErrors) {
        _showErrorSnackbar("Validation Error", "Please select your account type (Job Seeker or Recruiter)");
      }
      return false;
    }
    
    final allowedRoles = ['jobseeker', 'recruiter'];
    if (!allowedRoles.contains(role.toLowerCase())) {
      if (showErrors) {
        _showErrorSnackbar("Validation Error", "Invalid account type selected. Please choose Job Seeker or Recruiter.");
      }
      return false;
    }
    
    return true;
  }

  // Fungsi registrasi untuk Job Seeker
  Future<void> register_job(String email, String password) async {
    try {
      // FR-REGISTER-001: Validasi format email
      if (!validateEmailFormat(email)) {
        return;
      }
      
      // FR-REGISTER-001: Validasi kompleksitas password untuk registrasi
      if (!validatePasswordStrength(password, isRegistration: true)) {
        return;
      }
      
      // FR-REGISTER-001: Validasi keunikan email
      final isUnique = await validateEmailUniqueness(email);
      if (!isUnique) {
        return;
      }
      
      // FR-REGISTER-002: Validasi role
      if (!validateRoleSelection('jobseeker')) {
        return;
      }
      
      await _auth
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
    } on FirebaseException {
      _showErrorSnackbar("Database Error", "Failed to save account data. Please try again");
    } catch (e) {
      _showErrorSnackbar("Registration Error", "An unexpected error occurred. Please try again");
    }
  }

  // Fungsi registrasi untuk Recruiter
  Future<void> register_recruiter(String email, String password) async {
    try {
      // FR-REGISTER-001: Validasi format email
      if (!validateEmailFormat(email)) {
        return;
      }
      
      // FR-REGISTER-001: Validasi kompleksitas password untuk registrasi
      if (!validatePasswordStrength(password, isRegistration: true)) {
        return;
      }
      
      // FR-REGISTER-001: Validasi keunikan email
      final isUnique = await validateEmailUniqueness(email);
      if (!isUnique) {
        return;
      }
      
      // FR-REGISTER-002: Validasi role
      if (!validateRoleSelection('recruiter')) {
        return;
      }
      
      await _auth
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
    } on FirebaseException {
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
    } on FirebaseException {
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
    } on FirebaseException {
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
    } on FirebaseAuthException {
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

// _clearLoginStatus dan _showErrorSnackbar global tidak digunakan lagi setelah refactor dependency injection
