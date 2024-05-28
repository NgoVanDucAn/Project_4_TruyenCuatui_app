import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truyencuatui/category/category.dart';
import 'package:truyencuatui/category/category_comic.dart';
import 'package:truyencuatui/category/category_novel.dart';
import 'package:truyencuatui/config/Palette.dart';
import 'package:truyencuatui/model/story.dart';
import 'package:truyencuatui/screens/comic.dart';
import 'package:truyencuatui/screens/login_signup.dart';
import 'package:truyencuatui/screens/noveldetailpage.dart';
import 'package:truyencuatui/screens/userinfor.dart';
import 'package:truyencuatui/screens/write.dart';
import 'package:truyencuatui/service/AuthService.dart';
import 'package:truyencuatui/service/LoginService.dart';
import 'package:truyencuatui/service/StoryService.dart';
import 'package:truyencuatui/screens/searchpage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class NovelScreen extends ConsumerStatefulWidget {
  const NovelScreen({super.key});

  @override
  ConsumerState createState() => _NovelScreenState();
}

class _NovelScreenState extends ConsumerState<NovelScreen> {
  int _selectedIndex = 0;
  int _currentSlide = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String logoImagePath = 'images/logo1.png';
  int _currentPage = 0; // Chỉ số của trang hiện tại
  final int _pageSize = 6; // Số lượng truyện được hiển thị trên mỗi trang
  final AuthService _authService = AuthService();
  final LoginService _loginService = LoginService();
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String _userId = '';

  StoryService st = StoryService();

  List<Story> categories = [];
  @override
  void initState() {
    super.initState();
    fetchData(); // Gọi hàm fetchData() khi widget được khởi tạo
    checkLoginStatus();
  }

  void _logOut() async {
    await _authService.logout();
    ref.read(isUserLoginProvider.notifier).state = false;
    if (!mounted) return; // Check if the widget is still mounted
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        // Double-check after the delay
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NovelScreen()),
        );
      }
    });
  }

  // Hàm này cập nhật trạng thái đăng nhập và quyết định liệu ListTile có nên điều hướng đến màn hình viết truyện hay không.
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

  void _navigateToUser(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserInfoScreen(userId: userId)),
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
        if (mounted) {
          setState(() {
            _isLoggedIn = !_isLoggedIn;
          });
          Navigator.pushReplacement(
            // Navigate to the main screen
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const NovelScreen()), // Assuming MyApp is the main screen after login
          );
        }
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
    String userId = loggedIn
        ? await _authService.getUserId()
        : ''; // Assuming getUserId() returns the current user's ID
    if (mounted) {
      // Check if the widget is still mounted
      setState(() {
        _isLoggedIn = loggedIn;
        _userId = userId;
      });
    }
  }

  Future<void> fetchData() async {
    try {
      // Gọi hàm findAll() và chờ Future trả về
      List<Story> fetchedCategories = await st.findAll();
      if (!mounted) return;
      // Cập nhật danh sách categories và rebuild widget
      setState(() {
        categories = fetchedCategories;
        _isLoading = false; // Set loading thành false khi data đã tải
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false; // Cũng set loading thành false nếu có lỗi
        });
      }
    }
  }

  int _calculatePageCount(int pageSize) {
    int totalCount = categories.length;
    return (totalCount / pageSize).ceil();
  }

  List<Story> _getCurrentPageItems(int pageSize, int pageIndex) {
    int startIndex = pageIndex * pageSize;
    int endIndex = startIndex + pageSize;
    return categories.sublist(startIndex,
        endIndex < categories.length ? endIndex : categories.length);
  }

  void _changePage(int index) {
    if (mounted) {
      setState(() {
        _currentPage = index;
      });
    }
  }

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  List<Widget> buildStoryWidgets() {
    // Lấy tối đa 7 stories để hiển thị
    var limitedStories = categories.take(7).toList();
    return limitedStories.map((story) {
      return Builder(
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {
              // Xử lý khi một câu chuyện được nhấn
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(story.image),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 10.0,
                    left: 10.0,
                    child: Text(
                      story.name,
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.deepOrangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    bool isUserLogin = ref.watch(isUserLoginProvider.notifier).state;
    int pageCount = _calculatePageCount(_pageSize);
    List<Widget> storyWidgets = buildStoryWidgets();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Palette.secondaryColor,
        elevation: 3,
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
              if (isUserLogin) {
                _navigateToUser(context, _userId);
              } else {
                _navigateToLoginScreen();
              }
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image:
                  AssetImage('images/logo.png'), // Hình ảnh với màu nền và logo
              fit: BoxFit
                  .contain, // Hiển thị toàn bộ ảnh trong container mà không bị căng ra ngoài
            ),
          ),
        ),
      ),
      drawer: _renderDrawer(context: context, ref: ref),
      body: _renderBody(pageCount, storyWidgets),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Novel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories),
            label: 'Comic',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  _renderBody(int pageCount, List<Widget> storyWidgets) {
    if (_isLoading) {
      // Hiển thị một spinner loading đẹp
      return Center(
        child: SpinKitFadingCube(
          color: Theme.of(context).primaryColor,
          size: 50.0,
        ),
      );
    }
    // Thực hiện điều hướng đến trang tương ứng với mục được chọn
    switch (_selectedIndex) {
      case 1: // Trang "Comic"
        return const ComicScreen();
      case 0:
        return Column(
          children: <Widget>[
            const SizedBox(height: 30.0),
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentSlide = index; // Cập nhật slide hiện tại
                  });
                },
              ),
              items: storyWidgets,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(storyWidgets.length, (index) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentSlide == index
                        ? Colors.deepOrangeAccent
                        : Colors.grey,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            const Text(
              'List of stories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PageView.builder(
                itemCount: _calculatePageCount(_pageSize),
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  // Lấy truyện cho trang hiện tại
                  var stories = _getCurrentPageItems(_pageSize, index);
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pageCount,
                (index) => GestureDetector(
                  onTap: () {
                    _changePage(index);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentPage
                          ? Colors.blue
                          : Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }

  _renderDrawer({required BuildContext context, required WidgetRef ref}) {
    bool isUserLogin = ref.watch(isUserLoginProvider.notifier).state;
    return Drawer(
      child: ListView(
        children: <Widget>[
          // Sử dụng Container để làm nền với thuộc tính decoration
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/logo1.png'), // Đường dẫn đến ảnh nền
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
              _navigateToStoryScreen(context);
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
              isUserLogin ? 'Log Out' : 'Log In',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              if (isUserLogin) {
                _logOut();
              } else {
                _navigateToLoginScreen();
              }
            },
          )
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

void _navigateToStoryScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const CategoryPage()),
  );
}
