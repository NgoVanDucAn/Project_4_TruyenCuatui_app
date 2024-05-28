import 'package:flutter/material.dart';
import 'package:truyencuatui/model/chapter.dart';
import 'package:truyencuatui/model/story.dart';  
import 'package:truyencuatui/screens/read_novel.dart';
import 'package:truyencuatui/service/chapterService.dart';

class NovelDetailPage extends StatefulWidget {
  final Story comic;

  const NovelDetailPage({super.key, required this.comic});

  @override
  _NovelDetailPageState createState() => _NovelDetailPageState();
}

class _NovelDetailPageState extends State<NovelDetailPage> {
  chapterService ct = chapterService();  // Giả sử đây là tên đúng của class
  List<Chapter> chapters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      List<Chapter> fetchedChapters = await ct.fetchStoryDetail(widget.comic.id);
      setState(() {
        chapters = fetchedChapters;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching chapters: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.comic.name),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement sharing functionality
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ))
          :CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(widget.comic.name, style: const TextStyle(color: Colors.white, fontSize: 16, backgroundColor: Colors.black45)),
              background: Hero(
                tag: 'cover${widget.comic.id}',
                child: Image.network(
                  widget.comic.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                Chapter chapter = chapters[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Chapter ${index + 1}: ${chapter.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Tap to read more', style: TextStyle(color: Colors.black.withOpacity(0.6))),
                    onTap: () => _navigateToReadingPage(context, chapter.id),
                  ),
                );
              },
              childCount: chapters.length,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToReadingPage(BuildContext context, String chapterId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReadingPage(chapterId: chapterId)),
    );
  }
}
