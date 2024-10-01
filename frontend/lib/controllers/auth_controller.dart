import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/views/auth/signup_view.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:get/get.dart';
import '../models/auth.dart';

class AuthController extends GetxController {
  var id = ''.obs;
  var email = ''.obs;
  var isLoggedIn = false.obs;
  var nickname = ''.obs;
  var birthDate = ''.obs;
  var height = ''.obs;
  var weight = ''.obs;
  final _storage = FlutterSecureStorage(); // 토큰 저장
  // 혹시 몰라 넣은 토큰
  var newToken =
      'Bearer eyJhbGciOiJIUzI1NiJ9.eyJpZCI6MTAsImVtYWlsIjoidGVzMnQyM3cyNEBleGFtcGxlLmNvbTIiLCJuaWNrbmFtZSI6InJ1bm4ydzMyNDIiLCJpYXQiOjE3MjU5NTc2ODMsImV4cCI6MTcyOTU1NzY4M30.64u_30Q6t3lXGYyNwLhSxfilMRtYgWKWSnqGP4XGG6k';

  final AuthService _authService = AuthService();
  // 선택된 성별 및 버튼 활성화 상태
  var selectedGender = ''.obs;
  var isButtonActive = false.obs;
  RxBool isEditable = false.obs;

  // 닉네임 변경
  void onNicknameChanged(String value) {
    nickname.value = value;
    isButtonActive.value = nickname.value.trim().length > 1;
  }

  // 카카오톡 로그인
  Future<void> loginWithKakao() async {
    try {
      // 기본 카카오 로그인
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      log('카카오 로그인 성공: ${token.accessToken}');
      // 토큰을 스토리지에 저장
      await _saveToken(token.accessToken);

      // 저장된 토큰을 바로 불러와서 확인
      String? accessToken = await _storage.read(key: 'ACCESS_TOKEN');
      if (accessToken != null) {
        log('카카오톡으로 로그인 성공 controller: ${token.accessToken}');
      } else {
        log('토큰 저장 실패: 불러올 수 없습니다.');
      }
      // 사용자 정보 요청
      await requestUserInfo();
      loadDecodedData();
      isLoggedIn.value = true;
    } catch (error) {
      log('카카오톡 로그인 실패: $error');
      Get.snackbar('오류', '카카오톡 로그인에 실패했습니다.');
    }
  }

  // 디코드
  Future<void> loadDecodedData() async {
    // 'ACCESS_TOKEN' 읽기 시 비동기 처리를 위한 await 추가
    String? storedToken = await _storage.read(key: 'ACCESS_TOKEN');

    if (storedToken != null) {
      newToken = storedToken;
    }

    final token = newToken.substring(7);

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

    log('Decoded JWT: $decodedToken');

    await _storage.write(key: 'ID', value: decodedToken['id'].toString());
    await _storage.write(key: 'EMAIL', value: decodedToken['email']);
    await _storage.write(key: 'NICKNAME', value: decodedToken['nickname']);

    id.value = await _storage.read(key: 'ID') ?? 'No ID found';
    email.value = await _storage.read(key: 'EMAIL') ?? 'No Email found';
    nickname.value =
        await _storage.read(key: 'NICKNAME') ?? 'No Nickname found';
  }

  // 카카오 사용자 정보 가져오기
  Future<void> requestUserInfo() async {
    try {
      User user = await UserApi.instance.me();
      email.value = user.kakaoAccount?.email ?? "Unknown";
      log('사용자 정보 요청 성공_controller: ${email.value}');
      await checkUserEmailOnServer(email.value);
    } catch (error) {
      log('사용자 정보 요청 실패_controller: $error');
      Get.snackbar('오류', '사용자 정보를 가져오지 못했습니다.');
    }
  }

// 서버로 이메일을 보내 회원 여부 확인
  Future<void> checkUserEmailOnServer(String userEmail) async {
    try {
      final response = await _authService.getOuathKakao(userEmail);
      log('${response}');
      // 서버에서 받은 응답이 이메일인 경우(신규 회원)
      if (response == userEmail) {
        email.value = userEmail;
        Get.to(SignUpView(email: email.value));
        // TODO toNamed로 바꾸기
        // Get.toNamed('/signup', arguments: {'email': email.value}); //이렇게 두면 오류 남
      }

      // 서버에서 받은 응답이 accessToken인 경우(기존 회원)
      else if (response['token'] != null) {
        // accessToken 저장
        await _saveToken(response['token']);
        // 기존 회원이라면 선호 코스 등록 여부 확인 t / f

        checkFavoriteTag();
      } else {
        log('서버 응답에서 예상치 못한 값이 있습니다.');
      }
      log('${userEmail}');
    } catch (e) {
      log('회원 여부 확인 중 오류 발생 controller: $e');
      Get.snackbar('오류', '회원 여부 확인 중 오류가 발생했습니다.');
    }
  }

  // 사용자 정보 입력
  Future<void> signup(Auth authData) async {
    try {
      final accessToken = await _authService.signupKakao(authData);
      if (accessToken != null) {
        log('회원가입 성공 controller');
        await _saveToken(accessToken);
        Get.snackbar('성공', '선호태그 입력 페이지로 이동합니다.');
      } else {
        Get.snackbar('오류', '회원가입 중 오류가 발생했습니다.');
      }
    } catch (e) {
      log('회원가입 중 오류 발생 controller: $e');
      Get.snackbar('오류', '회원가입에 실패했습니다.');
    }
  }

  // 이메일 중복 체크
  Future<bool> checkNickname(String nickname) async {
    try {
      final isAvailable = await _authService.checkNicknameDuplicate(nickname);
      if (isAvailable) {
        Get.snackbar('오류', '이미 사용 중인 닉네임입니다.');
        return true;
      } else {
        Get.snackbar('성공', '사용 가능한 닉네임입니다.');
        return false;
      }
    } catch (e) {
      log('이메일 체크 controller: $e');
      return false;
    }
  }

// 토큰 저장
  Future<void> _saveToken(String? accessToken) async {
    log('저장할 accessToken _ controller: ${accessToken}');
    if (accessToken != null) {
      await _storage.write(key: 'ACCESS_TOKEN', value: accessToken);
      final accessToken1 = await _storage.read(key: 'ACCESS_TOKEN');
      log('${accessToken1}');
      log('토큰 저장 성공');
    } else {
      log('토큰 저장 실패 controller: accessToken이 없습니다.');
    }
  }

// 선호 태그 등록 여부 확인
  Future<void> checkFavoriteTag() async {
    try {
      final isTagRegistered = await _authService.checkFavoriteTag();
      if (isTagRegistered) {
        Get.toNamed('main');
      } else {
        Get.toNamed('signup2');
      }
    } catch (e) {
      log('선호 태그 확인 중 오류 발생 controller: $e');
    }
  }

  // 선호 태그 전송
  Future<void> sendFavoriteTag(List<String> favoriteTags) async {
    try {
      Map<String, dynamic> requestBody = {
        "favoriteCourses": favoriteTags.map((tag) => {"tagName": tag}).toList()
      };
      await _authService.sendFavoriteTag(requestBody);
      Get.toNamed('/main');
    } catch (e) {
      Get.snackbar('오류', '선호 태그 등록 중 오류가 발생했습니다.');
    }
  }

  // 사용자 정보 불러오기
  Future<void> fetchUserInfo() async {
    // Map<String, dynamic> userInfoMap = await _authService.getUserInfo();
    try {
      // TODO
      // 서버에서 Map<String, dynamic> 데이터를 받음
      Map<String, dynamic> userInfoMap = await _authService.getUserInfo();
      log('${userInfoMap}');
      Auth userInfo = Auth.fromJson(userInfoMap);

      // nickname.value = 'ㅇㅇㅇㅇ';
      nickname.value =
          await _storage.read(key: 'NICKNAME') ?? userInfo.nickname;
      birthDate.value = userInfo.birth?.toString() ?? '';
      height.value = userInfo.height?.toString() ?? '';
      weight.value = userInfo.weight?.toString() ?? '';
      selectedGender.value = userInfo.gender == 1 ? 'man' : 'woman';

      log('회원 정보 불러오기 성공: $userInfoMap');
    } catch (e) {
      log('회원 정보 불러오기controller: $e');
    }
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      await _storage.delete(key: 'ACCESS_TOKEN');
      isLoggedIn.value = false;
      Get.toNamed('/login');
    } catch (e) {
      log('로그아웃 실패 controller: ${e}');
      Get.snackbar('로그아웃 실패 ', '로그아웃 중 문제가 발생했습니다.');
    }
  }

  // 회원탈퇴
  Future<void> remove() async {
    try {
      final accessToken = await _storage.read(key: 'ACCESS_TOKEN');
      // final response = await _authService.removeMember(accessToken);
      Get.snackbar('회원탈퇴 성공 ', '회원탈퇴 중 문제가 발생했습니다.');
    } catch (e) {
      log('회원탈퇴 실패 controller: ${e}');
      Get.snackbar('회원탈퇴 실패 ', '회원탈퇴 중 문제가 발생했습니다.');
    }
  }
}
