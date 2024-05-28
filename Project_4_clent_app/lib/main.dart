import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truyencuatui/screens/novel.dart';
import 'package:get_it/get_it.dart';
import 'package:truyencuatui/service/StoryService.dart';

void main() {
  GetIt.instance.registerLazySingleton<StoryService>(() => StoryService());
  runApp(
    ProviderScope(
      child: LoginSignupUI(
        key: UniqueKey(),
      ),
    ),
  );
}

class LoginSignupUI extends StatelessWidget {
  const LoginSignupUI({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Home Page",
      home: NovelScreen(),
    );
  }
}
