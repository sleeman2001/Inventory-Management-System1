import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_falcon_software1/splash_screen/splash_screen.dart';
import 'home_Screen/controller/data_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      initialBinding: MyBinding(),
    );
  }
}

class MyBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(InventoryController());
  }
}
