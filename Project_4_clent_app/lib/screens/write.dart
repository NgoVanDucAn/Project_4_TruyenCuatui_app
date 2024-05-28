import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:truyencuatui/screens/writeComic.dart';
import 'dart:io';

import 'package:truyencuatui/screens/writeNovel.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Write Stories With Me',
      home: WriteStory(),
    );
  }
}

class WriteStory extends StatefulWidget {
  const WriteStory({super.key});

  @override
  _WriteStoryState createState() => _WriteStoryState();
}

class _WriteStoryState extends State<WriteStory> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showWriteOptions(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.book),
                    title: const Text('Write Comic'),
                    onTap: () {
                      Navigator.pop(context); // Dismiss the bottom sheet
                      // Navigate to Write Comic Page
                     Navigator.push(context, MaterialPageRoute(builder: (context) => const WritingComicPage()));

                    }),
                ListTile(
                  leading: const Icon(Icons.create),
                  title: const Text('Write Novel'),
                  onTap: () {
                    Navigator.pop(context); // Dismiss the bottom sheet
                    // Navigate to Write Novel Page
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const WritingPage())); 
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write Stories With Me'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(
                hintText: 'Author',
              ),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: _pickImage,
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Text('Select photo'),
                      ),
                    ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _showWriteOptions(context),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
