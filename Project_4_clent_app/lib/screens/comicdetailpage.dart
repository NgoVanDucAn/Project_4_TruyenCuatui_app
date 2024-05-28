import 'package:flutter/material.dart';
import 'package:truyencuatui/model/chapter.dart';
import 'package:truyencuatui/model/story.dart';
import 'package:truyencuatui/screens/read_comic.dart';
import 'package:truyencuatui/service/chapterService.dart';

class ComicDetailPage extends StatefulWidget {
  final Story comic;

  const ComicDetailPage({super.key, required this.comic});

  @override
  _ComicDetailPageState createState() => _ComicDetailPageState();
}

class _ComicDetailPageState extends State<ComicDetailPage> {
  chapterService ct = chapterService();
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
        actions: const <Widget>[
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
              title: Text(widget.comic.name, style: const TextStyle(shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
              background: Hero(
                tag: 'comicCover${widget.comic.id}',
                child: Image.network(
                  widget.comic.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Story name: ${widget.comic.name}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                ],
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
                    onTap: () => navigateToComicPage(context, chapter.id),
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

  void navigateToComicPage(BuildContext context, String chapterId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadComicPage(chapterId: chapterId),
      ),
    );
  }
}
