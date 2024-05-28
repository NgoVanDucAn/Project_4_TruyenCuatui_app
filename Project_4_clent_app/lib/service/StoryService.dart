import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:truyencuatui/model/story.dart';
import 'package:truyencuatui/constants/ApiConsts.dart';
import 'package:truyencuatui/service/AuthService.dart';
import 'package:truyencuatui/service/RTService.dart';

class StoryService {
  final AuthService _authService = AuthService();
  late final RTService _rtService; 
  StoryService() {
    _rtService = RTService(_authService);  // Initialize _rtService with an instance of AuthService
  }
  // Fetches all stories from the server
   Future<List<Story>> findAll() async {
    var token = await _authService.getToken();
    String accessToken = token['accessToken'] ?? '';
    var headers = {'Authorization': 'Bearer $accessToken'};

    var response = await http.get(
      Uri.parse(ApiConsts.Stories_path),
      headers: headers,
    );

    if (response.statusCode == 401) {
      accessToken = await _rtService.refreshToken();
      response = await http.get(
        Uri.parse(ApiConsts.Stories_path),
        headers: {'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'},
      );
    }
    var jsonArray = jsonDecode(response.body) as List<dynamic>;

    List<Story> stories = jsonArray.map((item) {
      return Story.fromJson(item);
    }).toList();

    return stories;
  }
  
  Future<List<Story>> findByName(String name) async {
  var encodedName = Uri.encodeComponent(name);
  var uri = Uri.parse(ApiConsts.Find_Stories_ByName_path + encodedName);
  try {
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      var jsonAll = jsonDecode(response.body) as List<dynamic>;
      var stories = jsonAll.map((json) => Story.fromJson(json)).toList();
      return stories;
    } else {
      print('Server returned an error with status code: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('An error occurred during fetching stories by name: $e');
    return [];
  }
}
  

  
}
