import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:truyencuatui/category/category.dart';
import 'package:truyencuatui/model/story.dart';
import 'package:truyencuatui/screens/comicdetailpage.dart';
import 'package:truyencuatui/screens/novel.dart';
import 'package:truyencuatui/service/StoryService.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Truyện Của Tui',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ComicScreen(),
    );
  }
}

class ComicScreen extends StatefulWidget {
  const ComicScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ComicScreen> {

  int _selectedIndex = 0;
  int _currentSlide = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String logoImagePath = 'images/logo.png';
  int _currentPage = 0; // Chỉ số của trang hiện tại
  final int _pageSize = 6; // Số lượng truyện được hiển thị trên mỗi trang
  bool _isLoading = true; 
  

  StoryService st = StoryService();
  
  
  List<Story> categories = []; // Khởi tạo danh sách categories

  @override
  void initState() {
    super.initState();
    fetchData(); // Gọi hàm fetchData() khi widget được khởi tạo
  }

  Future<void> fetchData() async {
    try{
    // Gọi hàm findAll() và chờ Future trả về
    List<Story> fetchedCategories = await st.findAll();
    if (!mounted) return;
    // Cập nhật danh sách categories và rebuild widget
    setState(() {
      categories = fetchedCategories;
      _isLoading = false; // Set loading thành false khi data đã tải
    });
    }catch(e){
      setState(() {
        _isLoading = false; // Cũng set loading thành false nếu có lỗi
      });
    }
  }


  int _calculatePageCount(int pageSize) {
    int totalCount = categories.length;
    return (totalCount / pageSize).ceil();
  }

  List<Story> _getCurrentPageItems(int pageSize, int pageIndex){
    int startIndex = pageIndex * pageSize;
    int endIndex = startIndex + pageSize;
    return categories.sublist(startIndex,
        endIndex < categories.length ? endIndex : categories.length);
  }

  void _changePage(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
    int pageCount =  _calculatePageCount(_pageSize);
    List<Widget> storyWidgets = buildStoryWidgets();
    return Scaffold(
      key: _scaffoldKey,
      
      body: _renderBody(pageCount, storyWidgets),
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
      case 1: // Trang "Novel"
        return const NovelScreen();       
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
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
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
                builder: (context) => ComicDetailPage(comic: story),
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
