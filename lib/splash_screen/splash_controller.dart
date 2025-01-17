import 'package:get/get.dart';
import '../home_Screen/view/inventory_home_screen_view.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _navigateToHome();
  }

  void _navigateToHome() {
    Future.delayed(const Duration(seconds: 7), () {
      Get.off(() => InventoryScreen());
    });
  }
}
