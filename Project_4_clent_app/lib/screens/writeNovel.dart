import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Writing Story Chapters',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WritingPage(),
    );
  }
}

class WritingPage extends StatefulWidget {
  const WritingPage({super.key});

  @override
  _WritingPageState createState() => _WritingPageState();
}

class _WritingPageState extends State<WritingPage> {
  final _chapterTitleController = TextEditingController();
  final _chapterContentController = TextEditingController();
  String _chapterContent = '';

  @override
  void dispose() {
    _chapterTitleController.dispose();
    _chapterContentController.dispose();
    super.dispose();
  }

  void _saveChapter() {
    // Xử lý lưu chương truyện ở đây
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Writing Story Chapters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChapter,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _chapterTitleController,
              decoration: const InputDecoration(
                hintText: 'Enter chapter name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _chapterContent = '$value\n$_chapterContent';
                  _chapterContentController.text = _chapterContent;
                });
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: TextField(
                controller: _chapterContentController,
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.top,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Enter chapter content',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _chapterContent = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
