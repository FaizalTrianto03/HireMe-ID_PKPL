import 'package:HireMe_Id/connection/bindings/connection_binding.dart';
class DependencyInjection {
  
  static void init() {
    ConnectionBinding().dependencies();
  }
}