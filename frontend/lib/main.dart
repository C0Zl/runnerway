import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart';
import 'controllers/under_bar_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 앱 시작 시 전역 상태로 UnderBarController 등록
    Get.put(UnderBarController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // 여기서 Home을 직접 렌더링
      initialRoute: '/main',
      getPages: AppRoutes.routes,
    );
  }
}
