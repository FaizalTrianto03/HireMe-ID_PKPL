import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:HireMe_Id/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow E2E Test', () {
    testWidgets('TC-E2E-001: Login dengan kredensial valid', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Tunggu halaman login muncul
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Cari tombol Login di halaman awal (jika ada splash/onboarding)
      final loginButton = find.text('Login');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
      }

      // Input email
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'recruiter@test.com');
      await tester.pumpAndSettle();

      // Input password
      final passwordField = find.byType(TextField).at(1);
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // Pilih role (jika ada dropdown/radio)
      // Sesuaikan dengan UI actual app
      final roleDropdown = find.text('recruiter');
      if (roleDropdown.evaluate().isNotEmpty) {
        await tester.tap(roleDropdown);
        await tester.pumpAndSettle();
      }

      // Tap tombol Login
      final submitButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(submitButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verifikasi navigasi ke dashboard/home
      expect(
        find.textContaining(RegExp(r'Dashboard|Home|Welcome', caseSensitive: false)),
        findsOneWidget,
        reason: 'Should navigate to dashboard after successful login'
      );
    });

    testWidgets('TC-E2E-002: Login dengan email kosong (negative)', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to login if needed
      final loginButton = find.text('Login');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
      }

      // Leave email empty, input password only
      final passwordField = find.byType(TextField).at(1);
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // Tap login
      final submitButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(submitButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verifikasi error message atau snackbar
      expect(
        find.textContaining(RegExp(r'Email.*empty|required', caseSensitive: false)),
        findsOneWidget,
        reason: 'Should show error for empty email'
      );
    });

    testWidgets('TC-E2E-003: Login dengan password kosong (negative)', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final loginButton = find.text('Login');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
      }

      // Input email only, leave password empty
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'recruiter@test.com');
      await tester.pumpAndSettle();

      // Tap login
      final submitButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(submitButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verifikasi error
      expect(
        find.textContaining(RegExp(r'Password.*empty|required', caseSensitive: false)),
        findsOneWidget,
        reason: 'Should show error for empty password'
      );
    });
  });
}
