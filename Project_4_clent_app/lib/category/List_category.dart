import 'package:flutter/material.dart';
import 'package:truyencuatui/category/category.dart';
import 'package:truyencuatui/category/category_comic.dart';
import 'package:truyencuatui/category/category_novel.dart';
import 'package:truyencuatui/config/Palette.dart';
import 'package:truyencuatui/screens/login_signup.dart';
import 'package:truyencuatui/screens/novel.dart';
import 'package:truyencuatui/screens/searchpage.dart';
import 'package:truyencuatui/screens/userinfor.dart';
import 'package:truyencuatui/screens/write.dart';
import 'package:truyencuatui/service/AuthService.dart';
import 'package:truyencuatui/service/LoginService.dart';
import 'package:truyencuatui/service/storydetailService.dart';
import 'package:truyencuatui/model/storydetail.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryId;
  const CategoryDetailPage({super.key, required this.categoryId});

  @override
  _CategoryDetailPageState createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StoryDetailService str = StoryDetailService();
  List<StoryDetail> stories = [];
  final AuthService _authService = AuthService();
  final LoginService _loginService = LoginService();
  bool _isLoggedIn = false;
  final String logoImagePath = 'images/logo1.png';

  Future<void> fetchData() async {
    List<StoryDetail> fetchedStories = await str.getDetailWithCategoryId(widget.categoryId);
    setState(() {
      stories = fetchedStories;
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

  void _navigateToLoginScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginSignupScreen()),
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
                      MaterialPageRoute(builder: (context) => const categoryComic()),
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
                      MaterialPageRoute(builder: (context) => const categoryNovel()),
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
    body: FutureBuilder<List<StoryDetail>>(
      future: str.getDetailWithCategoryId(widget.categoryId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var story = snapshot.data![index];
                return Card(
                  child: ExpansionTile(
                    title: Text(story.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    children: story.subStories.map((subStory) => ListTile(
                      leading: Image.network(subStory.image, width: 100, height: 100, fit: BoxFit.cover),
                      title: Text(subStory.name),
                      trailing: Text(subStory.status ? "Active" : "Inactive"),
                    )).toList(),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            return const Text("No data available");
          }
        }
        return const CircularProgressIndicator();
      },
    ),
  );
}

}
void _navigateToCategory(BuildContext context, String categoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CategoryDetailPage(categoryId: categoryId)),
    );
  }
  void _navigateToCategoryScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const CategoryPage()),
  );
}


