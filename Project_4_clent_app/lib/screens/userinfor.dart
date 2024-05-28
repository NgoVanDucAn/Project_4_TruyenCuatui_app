import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:truyencuatui/model/user.dart';
import 'package:truyencuatui/service/userService.dart';
import 'package:truyencuatui/view_model/user_infor_view_model.dart';

class UserInfoScreen extends StatefulWidget {
  final String userId;

  const UserInfoScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final UserService _userService = UserService();
  User? user;
  List<StoryUser> stories = [];
  bool _isLoading = true;
  bool _imageLoadFailed = false; // State variable for image loading failure

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndStories();
  }

  Future<void> _fetchUserDataAndStories() async {
    setState(() => _isLoading = true); // Set loading state at the beginning

    try {
      var response = await _userService.fetchUserStories(widget.userId);
      print('User data and stories fetched: $response');

      // Assuming 'response' is a Map containing 'user' and 'stories'
      setState(() {
        user = User.fromJson(response.toJson());
        stories = response.toJson()['stories'] != null
            ? (response.toJson()['stories'] as List)
                .map((e) => StoryUser.fromJson(e))
                .toList()
            : [];
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to fetch data: $e');
      setState(() {
        user = null; // Optionally clear user data on error
        stories = [];
        _isLoading = false;
      });
    }
  }

  void _editUserDetail(String field, String currentValue) async {
    TextEditingController controller =
        TextEditingController(text: currentValue);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $field"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Save"),
              onPressed: () {
                if (user != null) {
                  setState(() {
                    switch (field) {
                      case "Name":
                        user!.userId = controller.text;
                        break;
                      case "Email":
                        user!.email = controller.text;
                        break;
                      case "Gender":
                        user!.gender = controller.text;
                        break;
                      case "Date of Birth":
                        user!.dateOfBirth = controller.text;
                        break;
                    }
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Information'),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _editUserDetail("Profile", ""); // Handle the profile editing
              },
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          const AssetImage("assets/fallback_avatar.png"),
                      onBackgroundImageError: (error, stackTrace) {
                        debugPrint("Failed to load image: $error");
                        setState(() {
                          _imageLoadFailed = true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  //_buildUserInfoRow("Name", user?.name ?? "N/A", "Name"),
                  _buildUserInfoRow("Email", user?.email ?? "N/A", "Email"),
                  _buildUserInfoRow("Gender", user?.gender ?? "N/A", "Gender"),
                  const SizedBox(height: 20),
                  const Text('User Stories:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: stories.length,
                    itemBuilder: (context, index) {
                      print('haha');
                      return ListTile(
                        title: Text(stories[index].name ?? ""),
                        subtitle: Text(stories[index].description ?? ""),
                        leading: Image.network(
                          stories[index].image ??
                              'https://img.freepik.com/free-vector/three-giraffes-living-by-river_1308-55578.jpg?w=826&t=st=1714032899~exp=1714033499~hmac=45745d37b2054d895f0c892ce71459c32c91abcbfa9fc9e31f6da5cad2bb808c',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildUserInfoRow(String label, String value, String field) {
    return Container(
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            Expanded(
              flex: 2,
              child: Text(value, style: const TextStyle(fontSize: 14)),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editUserDetail(field, value),
            ),
          ],
        ),
      ),
    );
  }
}
