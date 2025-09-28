import 'package:get/get.dart';
import '../controllers/applied_controller.dart';
class AppliedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppliedController>(() => AppliedController());
  }
}