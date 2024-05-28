import 'package:flutter/material.dart';
import 'package:truyencuatui/category/List_comic.dart';
import 'package:truyencuatui/category/category.dart';
import 'package:truyencuatui/category/category_novel.dart';
import 'package:truyencuatui/config/Palette.dart';
import 'package:truyencuatui/model/category.dart';
import 'package:truyencuatui/screens/login_signup.dart';
import 'package:truyencuatui/screens/novel.dart';
import 'package:truyencuatui/screens/searchpage.dart';
import 'package:truyencuatui/screens/userinfor.dart';
import 'package:truyencuatui/screens/write.dart';
import 'package:truyencuatui/service/AuthService.dart';
import 'package:truyencuatui/service/LoginService.dart';
import 'package:truyencuatui/service/categoryService.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thể Loại Truyện',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const categoryComic(),
    );
  }
}

class categoryComic extends StatefulWidget {
  const categoryComic({super.key});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<categoryComic> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String logoImagePath = 'images/logo1.png';
  final AuthService _authService = AuthService();
  final LoginService _loginService = LoginService();
  bool _isLoggedIn = false;

  categoryService st = categoryService();
  List<Category> categories = []; // Khởi tạo danh sách categories

  Future<void> fetchData() async {
    // Gọi hàm findAll() và chờ Future trả về
    List<Category> fetchedCategories = await st.findAll();

    // Cập nhật danh sách categories và rebuild widget
    setState(() {
      categories = fetchedCategories;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Gọi hàm fetchData() khi widget được khởi tạo
    checkLoginStatus();
  }

  void _logOut() async {
    await _authService.logout();
    setState(() {
      _isLoggedIn = false;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const NovelScreen()), // Navigate to the login screen or main screen after logout
    );
  }
  void _handleWriteStoryOrLogin(BuildContext context) {
  print("Handle tap: Logged in status is $_isLoggedIn");
  if (_isLoggedIn) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const WriteStory()));
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Required'),
          content: const Text('You need to log in to write stories with me.'),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginSignupScreen()));
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }
}
  void _navigateToLoginScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginSignupScreen()),
    );
  }

  void _logIn() async {
    // For demo, using static credentials; replace with actual user input.
    String username = 'your_username';
    String password = 'your_password';

    try {
      await _loginService.loginUser(username, password);
      // After successful login, update the UI
      if (await _authService.isLoggedIn()) {
        setState(() {
          _isLoggedIn = true;
        });
        Navigator.pushReplacement(
          // Navigate to the main screen
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const NovelScreen()), // Assuming MyApp is the main screen after login
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Login Failed'),
          content: const Text('Failed to login. Please try again.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }
  }

  Future<void> checkLoginStatus() async {
    bool loggedIn = await _authService.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Palette.secondaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_2_sharp),
            onPressed: () {
              if (_isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserInfoScreen(
                            userId: 'userId',
                          )),
                );
              } else {
                _navigateToLoginScreen();
              }
            },
          ),
        ],
        flexibleSpace: GestureDetector(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const NovelScreen()),
              (Route<dynamic> route) => false,
            );
          },
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'images/logo.png'), // Hình ảnh với màu nền và logo
                fit: BoxFit
                    .contain, // Hiển thị toàn bộ ảnh trong container mà không bị căng ra ngoài
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            // Sử dụng Container để làm nền với thuộc tính decoration
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'images/logo1.png'), // Đường dẫn đến ảnh nền
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(
                  logoImagePath,
                  width: 150, // Điều chỉnh kích thước logo tùy ý
                ),
              ),
            ),
            ListTile(
              title: const Text(
                'Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                // Handle onTap
                _navigateToCategoryScreen(context);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      'Comic',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      // Handle onTap
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const categoryComic()),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Novel',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      // Handle onTap
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const categoryNovel()),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
            title: Text(
              _isLoggedIn ? 'Write stories with me' :"Write stories with me",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            onTap: () => _handleWriteStoryOrLogin(context),
          ),
            Divider(
              thickness: 1,
              color: Colors.grey[300],
            ),
            ListTile(
              title: Text(
                _isLoggedIn ? 'Log Out' : 'Log In',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                if (_isLoggedIn) {
                  _logOut();
                } else {
                  _navigateToLoginScreen();
                }
              },
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Comic genre',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0, // Thay đổi tỉ lệ của ô
                ),
                itemCount: categories.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ListComic()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Palette.secondaryColor,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Center(
                        child: Text(
                          categories[index].name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _navigateToCategoryScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const CategoryPage()),
  );
}
