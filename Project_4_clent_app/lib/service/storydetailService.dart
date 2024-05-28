import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:truyencuatui/model/storydetail.dart';

class StoryDetailService {
  Future<List<StoryDetail>> getDetailWithCategoryId(String categoryId) async {
    try {
      final uri = Uri.parse('http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/GetDetailStoriesWithCategoryId/$categoryId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => StoryDetail.fromJson(item)).toList(); // Returns a list of StoryDetail
      } else {
        print('Server responded with status code: ${response.statusCode}');
        return []; // Return an empty list or throw an error as per your use case
      }
    } catch (e) {
      print('An error occurred while fetching story details: $e');
      return []; // Return an empty list or rethrow the exception based on your error handling policy
    }
  }
}
