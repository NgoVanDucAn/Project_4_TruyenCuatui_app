import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:truyencuatui/model/readstory.dart';

class ReadService {
  final String baseUrl = 'http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com';

  Future<List<ReadPage>> fetchPagesByChapterId(String chapterId) async {
    final url = 'http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/GetDetailPagesWithChapterId/$chapterId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> chapterData = jsonDecode(response.body);
      List<ReadPage> pages = [];
      for (var item in chapterData) {
        List<dynamic> pagesJson = item['pages'];
        pages.addAll(pagesJson.map((pageJson) => ReadPage.fromJson(pageJson)));
      }
      return pages;
    } else {
      throw Exception('Failed to load pages for chapterId $chapterId');
    }
  }
}


