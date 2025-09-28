import 'package:get/get.dart';
import '../controllers/job_application_controller.dart';
class JobApplicationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobApplicationController>(() => JobApplicationController());
  }
}