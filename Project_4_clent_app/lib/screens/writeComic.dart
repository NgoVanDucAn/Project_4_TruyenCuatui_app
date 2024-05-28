import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class WritingComicPage extends StatefulWidget {
  const WritingComicPage({super.key});

  @override
  _WritingComicPageState createState() => _WritingComicPageState();
}

class _WritingComicPageState extends State<WritingComicPage> {
  final _comicTitleController = TextEditingController();
  File? _comicImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _comicTitleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _comicImage = File(pickedFile.path);
      });
    }
  }

  void _saveComic() {
    // Implement saving the comic title and image
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Writing Comic Chapters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveComic,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _comicTitleController,
              decoration: const InputDecoration(
                hintText: 'Enter comic name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: _pickImage,
              child: _comicImage != null
                  ? Image.file(
                      _comicImage!,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                    ),
            ),
            // Optionally, add more controls for comic captions or descriptions here
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'Add Photo',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
