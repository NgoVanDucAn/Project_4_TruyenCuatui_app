import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:truyencuatui/model/comment.dart'; // Import your Comment model here

class CommentService {
  // You can set this to the actual URL of your API
  final String apiUrl = 'http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Comment/GetAll';

  // Fetch comments from the API
  Future<List<Comment>> fetchComments() async { 
    try {
      // Sending a GET request to the specified URL
      final response = await http.get(Uri.parse(apiUrl));

      // Checking if the response status is 200 (OK)
      if (response.statusCode == 200) {
        // Decoding the JSON response body
        List<dynamic> jsonList = json.decode(response.body);

        // Mapping each JSON object in the list to a Comment object
        return jsonList.map((jsonItem) => Comment.fromJson(jsonItem)).toList();
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      // Printing the error and rethrowing the exception
      print(e.toString());
      throw Exception('Failed to load comments: $e');
    }
  }
}
