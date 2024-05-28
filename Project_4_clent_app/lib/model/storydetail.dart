import 'package:truyencuatui/model/substory.dart';

class StoryDetail {
  final String id;
  final String name;
  final String description;
  final String image;
  final List<SubStory> subStories;

  StoryDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.subStories,
  });

  factory StoryDetail.fromJson(Map<String, dynamic> json) {
    List<SubStory> subStories = (json['stories'] as List).map((i) => SubStory.fromJson(i)).toList();
    return StoryDetail(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? "",
      image: json['image'] ?? "",
      subStories: subStories,
    );
  }
}
