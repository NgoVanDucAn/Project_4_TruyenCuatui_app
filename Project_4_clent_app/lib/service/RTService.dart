import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:truyencuatui/constants/ApiConsts.dart';
import 'package:truyencuatui/service/AuthService.dart';

class RTService {
  final AuthService authService;

  RTService(this.authService);

  Future<String> refreshToken() async {
    var currentAT = await authService.getToken();
    if (currentAT == null || currentAT.isEmpty) {
      throw Exception('Token is not available');
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConsts.Refresh_token),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'accessToken': currentAT['accessToken'],
          'refreshToken': currentAT['refreshToken'],
        }),
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['result']) {
          await authService.saveToken(
            responseData['accessToken'].toString(),
            responseData['refreshToken'].toString(),
          );
          return responseData['accessToken'];
        } else {
          throw Exception('Failed to refresh token: ${responseData['error']}');
        }
      } else {
        throw Exception('Failed to refresh token with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error refreshing token: $e');
      rethrow;
    }
  }
}
