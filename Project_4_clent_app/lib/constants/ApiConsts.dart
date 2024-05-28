
class ApiConsts {
  //static const String ROOT_PATH = 'http://192.168.88.157:5111/api';
  static const String ROOT_PATH = 'http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api';
  static const String ROOTT_PATH = 'http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com';
  static const String Categories_path = '$ROOT_PATH/Categories/GetAll';
  static const String Pages_path = '$ROOT_PATH/Page/GetAll';
  static const String Stories_path = '$ROOTT_PATH/GetAllStories';
  static const String Find_Stories_ByName_path = '$ROOTT_PATH/GetStoriesByName/';
  static const String User_Infor = '$ROOT_PATH/GetDetailStoriesWithAuthorThemself/';
  static const String Login_path = '$ROOT_PATH/Auth/doLogin';
  static const String REGISTER_PATH = "$ROOT_PATH/Auth/doRegister";
  static const String Refresh_token = '$ROOT_PATH/Auth/refreshToken';
  //  static final String Categories_path = 'https://jsonplaceholder.typicode.com/posts';
}
// http://172.20.10.3:5111/api/Auth/doRegister