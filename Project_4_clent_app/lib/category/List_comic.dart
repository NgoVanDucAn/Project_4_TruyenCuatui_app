import 'package:flutter/material.dart';
import 'package:truyencuatui/category/category.dart';
import 'package:truyencuatui/category/category_comic.dart';
import 'package:truyencuatui/category/category_novel.dart';
import 'package:truyencuatui/config/Palette.dart';
import 'package:truyencuatui/model/story.dart';
import 'package:truyencuatui/screens/login_signup.dart';
import 'package:truyencuatui/screens/novel.dart';
import 'package:truyencuatui/screens/noveldetailpage.dart';
import 'package:truyencuatui/screens/searchpage.dart';
import 'package:truyencuatui/screens/userinfor.dart';
import 'package:truyencuatui/screens/write.dart';
import 'package:truyencuatui/service/AuthService.dart';
import 'package:truyencuatui/service/LoginService.dart';
import 'package:truyencuatui/service/StoryService.dart';

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
      home: const ListComic(),
    );
  }
}
class ListComic extends StatefulWidget {
  const ListComic({super.key});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<ListComic> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String logoImagePath = 'images/logo1.png';
  final int _pageSize = 6; 
  final AuthService _authService = AuthService();
  final LoginService _loginService = LoginService();
  bool _isLoggedIn = false;

  StoryService st = StoryService();

  List<Story> categories = []; // Khởi tạo danh sách categories

  @override
  void initState() {
    super.initState();
    fetchData(); // Gọi hàm fetchData() khi widget được khởi tạo
    checkLoginStatus();
  }

  Future<void> fetchData() async {
    // Gọi hàm findAll() và chờ Future trả về
    List<Story> fetchedCategories = await st.findAll();
    if (!mounted) return;
    // Cập nhật danh sách categories và rebuild widget
    setState(() {
      categories = fetchedCategories;
    });
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

  List<Story> _getCurrentPageItems(int pageSize, int pageIndex) {
    int startIndex = pageIndex * pageSize;
    int endIndex = startIndex + pageSize;
    return categories.sublist(startIndex,
        endIndex < categories.length ? endIndex : categories.length);
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
                      'images/Background1.png'), // Đường dẫn đến ảnh nền
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),
            const Text(
              'List of stories Comic',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PageView.builder(
                itemBuilder: (context, index) {
                  // Lấy truyện cho trang hiện tại
                  var stories = _getCurrentPageItems(_pageSize, index);
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Đặt số cột là 2
                      childAspectRatio: 0.75, // Tỉ lệ của mỗi item
                    ),
                    itemCount: stories.length,
                    itemBuilder: (context, index) {
                      // Xây dựng widget cho mỗi truyện
                      return StoryGridItem(story: stories[index]);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class StoryGridItem extends StatelessWidget {
  final Story story;

  const StoryGridItem({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NovelDetailPage(comic: story),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(story.image),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // This section is modified to show the description
                      Text(
                        story.description, // Use story.description here
                        style: TextStyle(color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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


