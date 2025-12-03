import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:HireMe_Id/recruiter/explore/controllers/job_controller.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

JobController buildJobController() {
  return JobController(
    firebaseAuth: MockFirebaseAuth(),
    firebaseFirestore: MockFirebaseFirestore(),
    skipInit: true,
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.testMode = true;
  });

  group('White-Box: Job validateJobDataIntegrity()', () {
    late JobController c;
    setUp(() { Get.reset(); c = buildJobController(); });
    tearDown(Get.reset);

    test('S1: negative index -> false', () {
      expect(c.validateJobDataIntegrity(-1, showErrors: false), false);
    });

    test('S2: index >= length -> false', () {
      // empty jobs by default -> any non-zero index is invalid
      expect(c.validateJobDataIntegrity(0, showErrors: false), false);
    });

    test('S3: missing idjob -> false', () {
      c.jobs.add({'position': 'Dev'}); // no idjob
      expect(c.validateJobDataIntegrity(0, showErrors: false), false);
    });

    test('S4: valid idjob -> true', () {
      c.jobs
        ..clear()
        ..add({'idjob': 'ID01', 'position': 'Dev'});
      expect(c.validateJobDataIntegrity(0, showErrors: false), true);
    });
  });

  group('White-Box: Job validateJobUniqueness()', () {
    late JobController c;
    setUp(() { Get.reset(); c = buildJobController(); });
    tearDown(Get.reset);

    test('S1: duplicate -> false', () {
      c.jobs.add({'position': 'Flutter Dev'});
      expect(c.validateJobUniqueness('Flutter Dev', showErrors: false), false);
    });

    test('S2: unique -> true', () {
      c.jobs
        ..clear()
        ..add({'position': 'Flutter Dev'});
      expect(c.validateJobUniqueness('Backend Dev', showErrors: false), true);
    });

    test('B1: exclude same index -> true (ignore self)', () {
      c.jobs
        ..clear()
        ..addAll([
          {'position': 'Flutter Dev'},
          {'position': 'Backend Dev'},
        ]);
      // duplicate name equals index 1, but excluded -> should be allowed
      expect(
        c.validateJobUniqueness('Backend Dev', excludeJobIndex: 1, showErrors: false),
        true,
      );
    });
  });
}
