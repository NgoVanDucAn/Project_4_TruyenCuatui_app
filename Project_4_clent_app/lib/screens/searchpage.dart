import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:truyencuatui/model/story.dart';
import 'package:truyencuatui/screens/comicdetailpage.dart';
import 'package:truyencuatui/screens/filter.dart';
import 'package:truyencuatui/screens/noveldetailpage.dart';
import 'package:truyencuatui/service/StoryService.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search Page Example',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late StoryService storyService;
  List<Story> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    storyService = GetIt.instance<StoryService>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FilterPage()));
  }

  void _onSearchChanged(String query) {
    if (query.isNotEmpty) {
      storyService.findByName(query).then((results) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }).catchError((error) {
        print('Failed to fetch stories: $error');
        setState(() {
          _searchResults = [];
          _isLoading = false;

        });
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  void navigateToDetailPage(Story story) {
    if (story.isComic) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ComicDetailPage(comic: story)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NovelDetailPage(comic: story)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm Truyện'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_tree_rounded),
            onPressed: () => _handleSearch(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Nhập tên truyện hoặc tác giả',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                :ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                Story story = _searchResults[index];
                return ListTile(
                  title: Text(story.name),
                  subtitle: Text(story.subname),
                  onTap: () => navigateToDetailPage(story),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
