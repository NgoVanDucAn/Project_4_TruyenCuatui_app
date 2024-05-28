import 'dart:convert';
import 'package:http/http.dart' as http;

class SignUpService {
  static const String ROOT_PATH = "http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api";  // Cập nhật lại theo đường dẫn cơ sở của bạn
  static const String REGISTER_PATH = "$ROOT_PATH/Auth/doRegister";

  // Function to register user
  Future<Map<String, dynamic>> registerUser(String email, String password) async {
  var url = Uri.parse(REGISTER_PATH);
  try {
    var response = await http.post(url, body: jsonEncode({
      'email': email,
      'password': password,
    }), headers: {
      'Content-Type': 'application/json'
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['result'] == true) {
        return {
          'success': true,
          'accessToken': data['accessToken'],
          'refreshToken': data['refreshToken']
        };
      } else {
        return {
          'success': false,
          'message': 'Registration failed with errors: ${data['errors']}'
        };
      }
    } else {
      return {
        'success': false,
        'message': 'Server responded with status code: ${response.statusCode}'
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'An error occurred: $e'
    };
  }
}

}