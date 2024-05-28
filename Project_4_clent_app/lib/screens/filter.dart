import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Beautiful Filter Page',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const FilterPage(),
    );
  }
}

class FilterPage extends StatelessWidget {
  const FilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // The MediaQuery will help us make this page responsive
    // final width = MediaQuery.of(context).size.width; // Không cần thiết nếu không sử dụng bên dưới

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter',
          style: TextStyle(color: Colors.black), // Đặt màu văn bản AppBar thành màu đen
        ),
        backgroundColor: Colors.orange, // Đặt màu nền của AppBar thành màu trắng
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black), // Đặt màu của icon AppBar (nếu có) thành màu đen
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: const [
                  // Here you can insert your widgets representing each filter category
                  FilterCategory(title: 'TRẠNG THÁI', options: ['Tất cả', 'Full - Trọn bộ', 'Đang ra']),
                  FilterCategory(title: 'SỐ CHƯƠNG', options: ['Tất cả', '<50', '<100', '100 - 200', '>200']),
                  FilterCategory(title: 'SẮP XẾP', options: ['Cập nhật', 'Mới đăng', 'Xem nhiều', 'Yêu thích']),
                  // Add other categories here
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.orange, backgroundColor: Colors.black, // Đặt màu văn bản của nút
                ),
                child: const Text('LỌC TRUYỆN'),
                onPressed: () {
                  // Insert your filter logic here
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white, // Đặt màu nền của body thành màu trắng
    );
  }
}


class FilterCategory extends StatelessWidget {
  final String title;
  final List<String> options;

  const FilterCategory({Key? key, required this.title, required this.options}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define 'width' here using MediaQuery to make sure it is defined in this scope
    final width = MediaQuery.of(context).size.width;
    // Wrap your GridView with a Container to apply padding
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.black,),
          ),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
            shrinkWrap: true, // You need this to tell GridView to occupy minimum space
            itemCount: options.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: width > 600 ? 4 : 3, // adjust the number of columns depending on the width
              childAspectRatio: 3, // aspect ratio for each item
            ),
            itemBuilder: (context, index) {
              return Card(
                child: Center(
                  child: Text(
                    options[index],
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
