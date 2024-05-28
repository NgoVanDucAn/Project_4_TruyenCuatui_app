import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<void> saveToken(String accessToken, String refreshToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Lưu token và thời gian lưu trữ
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setInt('lastTokenTime', currentTime);
  }

  Future<void> clearToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('lastTokenTime'); // Xóa thời gian lưu trữ token
  }

  Future<Map<String, String>> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String accessToken = prefs.getString('accessToken') ?? '';
    final String refreshToken = prefs.getString('refreshToken') ?? '';
    return {'accessToken': accessToken, 'refreshToken': refreshToken};
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Xóa token
    // Xóa bất kỳ thông tin người dùng hoặc cài đặt nào khác được lưu trữ
    await prefs.remove('user_id');
    await prefs.clear(); // Xóa tất cả dữ liệu, sử dụng với thận trọng
  }

  Future<bool> isLoggedIn() async {
    // Giả định đang sử dụng SharedPreferences để quản lý token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  Future<bool> isTokenFresh() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int lastTokenTime = prefs.getInt('lastTokenTime') ?? 0;
    // Kiểm tra nếu token vẫn trong vòng 24 giờ
    return DateTime.now().millisecondsSinceEpoch - lastTokenTime < 86400000; // 24 hours
  }

  Future<void> checkTokenValidityOnStart() async {
    if (!await isTokenFresh()) {
      await clearToken();
    }
  }

  Future<String> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';
    return userId;
  }
}
