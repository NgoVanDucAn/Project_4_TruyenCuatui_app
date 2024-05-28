import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truyencuatui/model/user.dart';
import 'package:truyencuatui/service/userService.dart';

final userInfoViewModelProvider = ChangeNotifierProvider((ref) => UserInfoViewModel(ref: ref));

final isLoadingProvider = StateProvider((ref) => false);

class UserInfoViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final Ref ref;
  User? user;
  List<StoryUser> stories = [];
  //bool isLoading = false;

  UserInfoViewModel({required this.ref});

  bool _loading = false;
  bool get isLoading => _loading;

  set setLoading(bool value) {
    _loading = value;
    print(value);
    notifyListeners();
  }

  Future<void> fetchUserData(String userId) async {
    Future.delayed(const Duration(seconds: 1), () async {
      ref.read(isLoadingProvider.notifier).state = true;
      try {
        var response = await _userService.fetchUserStories(userId);

        // Assuming your API response is a Map like { 'user': {...}, 'stories': [...] }
        if (response.userId != null) {
          user = response;
          stories = response.stories ?? [];
        } else {
          user = null;
        }
        ref.read(isLoadingProvider.notifier).state = false;
        notifyListeners(); // Notify about changes
      } catch (e) {
        print('Error fetching user data: $e');
        // Optionally handle the error, e.g., display an error message
        ref.read(isLoadingProvider.notifier).state = false;
        notifyListeners();
      }
    });
    //setLoading = false;
  }
}
