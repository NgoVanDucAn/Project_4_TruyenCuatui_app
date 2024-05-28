import 'dart:convert';
import 'package:truyencuatui/constants/ApiConsts.dart';
import 'package:truyencuatui/service/AuthService.dart';
import 'package:http/http.dart' as http;

class LoginService {
  Future<void> loginUser(String username, String password) async {
    AuthService authService = AuthService();
    try {
      final response = await http.post(
        Uri.parse(ApiConsts.Login_path),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': username,
          'password': password,
        }),
      );

      print('print o login: ${response.body}');
      Map<String, dynamic> data = jsonDecode(response.body);
      bool result = data['result'];
      if (result == true) {
        final responseData = json.decode(response.body);
        if (responseData != null) {
          await authService.saveToken(
            responseData['accessToken'].toString(),
            responseData['refreshToken'].toString(),
          );
          print(await authService.getToken());
        } else {
          throw Exception('Failed to login');
        }
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
