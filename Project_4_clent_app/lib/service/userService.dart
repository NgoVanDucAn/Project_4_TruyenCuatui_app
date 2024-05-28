import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:truyencuatui/constants/ApiConsts.dart';
import 'package:truyencuatui/model/user.dart';
import 'package:truyencuatui/service/AuthService.dart';
import 'package:truyencuatui/service/RTService.dart';

class UserService {
  final AuthService _authService = AuthService();
  late final RTService _rtService;  // Declare _rtService to be initialized later

  UserService() {
    _rtService = RTService(_authService);  // Initialize _rtService with an instance of AuthService
  }

  Future<User> fetchUserStories(String userId) async {
    var accessTokenData = await _authService.getToken();  // Retrieve the Map containing the accessToken
    String accessToken = accessTokenData['accessToken'] ?? '';
  
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
  
    var response = await http.get(
      Uri.parse('${ApiConsts.User_Infor}$userId'),
      headers: headers,
    );
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
  
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      // Refresh the token if the old one expired
      accessToken = await _rtService.refreshToken();
      headers['Authorization'] = 'Bearer $accessToken';  // Update the accessToken in the headers
      response = await http.get(
        Uri.parse('${ApiConsts.User_Infor}$userId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
    }
  
    throw Exception('Failed to load user stories for userId: $userId');
  }
}
