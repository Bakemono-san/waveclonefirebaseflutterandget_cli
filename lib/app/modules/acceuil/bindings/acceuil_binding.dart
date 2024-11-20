import 'package:get/get.dart';

import '../controllers/acceuil_controller.dart';

class AcceuilBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AcceuilController>(
      () => AcceuilController(),
    );
  }
}
