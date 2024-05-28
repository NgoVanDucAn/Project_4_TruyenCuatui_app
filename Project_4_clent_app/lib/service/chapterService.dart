import 'package:http/http.dart' as http;
import 'package:truyencuatui/model/chapter.dart';
import 'dart:convert';

class chapterService {
  // Fetches all chapters from the server
  Future<List<Chapter>> findAll() async {
    print('start..hyy.');
    var uri = Uri.parse("http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/GetAllChapters");
    try {
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        var jsonAll = jsonDecode(response.body) as List<dynamic>;
        var chapters = List.generate(
            jsonAll.length, (index) => Chapter.fromJson(jsonAll[index]));
        print('List di: $chapters');
        return chapters;
      } else {
        print('Server error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error occurred during fetching all chapters: $e');
      return [];
    }
  }

  // Fetches a paginated list of chapters from the server
  Future<List> fetchMoreData({int startIndex = 0, int limit = 10}) async {
    var uri = Uri.parse("https://jsonplaceholder.typicode.com/photos");
    try {
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        var jsonAll = jsonDecode(response.body) as List<dynamic>;
        int endIndex = startIndex + limit;
        if (endIndex > jsonAll.length) {
          endIndex = jsonAll.length;
        }
        return jsonAll.sublist(startIndex, endIndex);
      } else {
        print('Server error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error occurred during pagination of data: $e');
      return [];
    }
  }

 Future<List<Chapter>> fetchStoryDetail(String storyId) async {
  final url = 'http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/GetDetailChaptersWithStoryId/$storyId';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    print('Response body: ${response.body}');
    // Giải mã JSON
    List<dynamic> storyData = jsonDecode(response.body);
    // Vì phản hồi dường như là một mảng các đối tượng, ta sẽ xử lý mỗi đối tượng
    if (storyData.isNotEmpty) {
      List<dynamic> chaptersJson = storyData.first['chapters'];  // Lấy mảng chương từ đối tượng đầu tiên
      print('Number of chapters: ${chaptersJson.length}');
      return chaptersJson.map((json) => Chapter.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('No story data available');
    }
  } else {
    throw Exception('Failed to load chapters');
  }
}


}
