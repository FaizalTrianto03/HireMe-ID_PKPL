import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:HireMe_Id/auth/controllers/auth_controller.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

AuthController buildAuthController() {
  return AuthController(
    firebaseAuth: MockFirebaseAuth(),
    firestore: MockFirebaseFirestore(),
    skipAutoLoad: true,
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.testMode = true;
  });

  group('White-Box: Auth validateEmailFormat()', () {
    late AuthController c;
    setUp(() { Get.reset(); c = buildAuthController(); });
    tearDown(Get.reset);

    test('S1: empty email -> false', () {
      expect(c.validateEmailFormat('', showErrors: false), false);
    });

    test('S2: invalid format -> false', () {
      expect(c.validateEmailFormat('userexample.com', showErrors: false), false);
    });

    test('S3: valid format -> true', () {
      expect(c.validateEmailFormat('user@example.com', showErrors: false), true);
    });
  });

  group('White-Box: Auth validatePasswordStrength() - login path', () {
    late AuthController c;
    setUp(() { Get.reset(); c = buildAuthController(); });
    tearDown(Get.reset);

    test('S1: empty -> false', () {
      expect(c.validatePasswordStrength('', showErrors: false), false);
    });

    test('B1: length < 6 -> false', () {
      expect(c.validatePasswordStrength('12345', showErrors: false), false);
    });

    test('B2: length == 6 -> true', () {
      expect(c.validatePasswordStrength('123456', showErrors: false), true);
    });
  });

  group('White-Box: Auth validatePasswordStrength() - registration path', () {
    late AuthController c;
    setUp(() { Get.reset(); c = buildAuthController(); });
    tearDown(Get.reset);

    test('S1: length < 8 -> false', () {
      expect(c.validatePasswordStrength('Pass123', isRegistration: true, showErrors: false), false);
    });

    test('B1: no number -> false', () {
      expect(c.validatePasswordStrength('PasswordOnly', isRegistration: true, showErrors: false), false);
    });

    test('B2: no letter -> false', () {
      expect(c.validatePasswordStrength('12345678', isRegistration: true, showErrors: false), false);
    });

    test('B3: strong (letters+numbers, >=8) -> true', () {
      expect(c.validatePasswordStrength('Passw0rd', isRegistration: true, showErrors: false), true);
    });
  });

  group('White-Box: Auth validateRoleSelection()', () {
    late AuthController c;
    setUp(() { Get.reset(); c = buildAuthController(); });
    tearDown(Get.reset);

    test('S1: empty -> false', () {
      expect(c.validateRoleSelection('', showErrors: false), false);
    });

    test('B1: invalid -> false', () {
      expect(c.validateRoleSelection('admin', showErrors: false), false);
    });

    test('B2: jobseeker -> true', () {
      expect(c.validateRoleSelection('jobseeker', showErrors: false), true);
    });

    test('B3: recruiter -> true', () {
      expect(c.validateRoleSelection('recruiter', showErrors: false), true);
    });
  });
}
