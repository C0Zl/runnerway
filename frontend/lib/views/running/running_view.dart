import 'package:flutter/material.dart';
import 'package:frontend/widgets/map/running_map.dart';
import '../../widgets/map/location.dart'; // location.dart 파일을 import
import '../../widgets/map/geolocation.dart'; // geolocation.dart 파일을 import
import '../../widgets/map/map.dart'; // map.dart 파일을 import
import '../../widgets/map/line.dart'; // line.dart 파일을 import
import '../../widgets/map/result_map.dart'; // result_map.dart 파일을 import
import 'ranking_list_view.dart'; // result_map.dart 파일을 import
import 'running_detail_view.dart'; // result_map.dart 파일을 import
import 'package:get/get.dart'; // result_map.dart 파일을 import

class RunningView extends StatelessWidget {
  const RunningView({super.key});

  // location.dart 파일의 GeolocatorWidget 페이지로 이동하는 메소드
  void _navigateToLocation() {
    Get.to(() => const LocationPage());
  }

  // geolocation.dart 파일의 GeolocatorWidget 페이지로 이동하는 메소드
  void _navigateToGeoLocation() {
    Get.to(() => const GeolocatorWidget());
  }

  // map.dart 파일의 MyMap 페이지로 이동하는 메소드
  void _navigateToMap() {
    Get.to(() => const MyMap());
  }

  // line.dart 파일의 MyLine 페이지로 이동하는 메소드
  void _navigateToLine() {
    Get.to(() => MyLine());
  }

  void _navigateToRusultMap() {
    Get.to(() => const ResultMap());
  }

  void _navigateToRunningMap() {
    Get.to(() => const RunningMap());
  }

  void _navigateToRankingListView() {
    Get.to(() => RankingListView());
  }

  void _navigateToRunningDetailView() {
    Get.to(() => RunningDetailView());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Running Screen'),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _navigateToLocation(), // 위치 페이지로 이동
              child: const Text('Go to Location'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToGeoLocation(), // 위치 페이지로 이동
              child: const Text('Go to GeoLocation'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToMap(), // 맵 페이지로 이동
              child: const Text('Go to Map'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToLine(), // 라인 페이지로 이동
              child: const Text('Go to Line'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToRusultMap(),
              // Navigates to the Polyline page
              child: const Text('Go to ResultMap'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToRunningMap(),
              // Navigates to the Polyline page
              child: const Text('Go to RunningMap'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToRankingListView(),
              // Navigates to the RankingList page
              child: const Text('Go to RankingList'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToRunningDetailView(),
              // Navigates to the RunningDetail page
              child: const Text('Go to RunningDetail'),
            ),
          ],
        ),
      ),
    );
  }
}
