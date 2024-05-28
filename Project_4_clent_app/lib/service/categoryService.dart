import 'package:http/http.dart' as http;
import 'package:truyencuatui/model/category.dart';
import 'dart:convert';

class categoryService {
  // Fetches all categories from the server
  Future<List<Category>> findAll() async {
    print('Starting fetch...');
    var uri = Uri.parse("http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Categories/GetAll");
    try {
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        print('Response body: ${response.body}'); // Thêm dòng này để xem kết quả trả về
        var jsonAll = jsonDecode(response.body) as List<dynamic>;
        var categories = List.generate(
            jsonAll.length, (index) => Category.fromJson(jsonAll[index]));
        print('List of categories: $categories');
        return categories;
      } else {
        print('Server error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error occurred during fetching all categories: $e');
      return [];
    }
  }
}
