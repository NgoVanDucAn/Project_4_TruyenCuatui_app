class StoryDetail {
  String storyId;
  List<Chapter> chapters;

  StoryDetail({required this.storyId, required this.chapters});

  factory StoryDetail.fromJson(Map<String, dynamic> json) {
    var chaptersList = (json['chapters'] as List? ?? [])
        .map((chapterJson) => Chapter.fromJson(chapterJson as Map<String, dynamic>))
        .toList();
    return StoryDetail(
      storyId: json['storyId'] as String? ?? 'Unknown Story ID', // Giá trị mặc định nếu null
      chapters: chaptersList,
    );
  }
}

class Chapter {
  String id;
  String name;
  String subName;
  String content;
  DateTime createdTime;
  String view;
  bool isPay;

  Chapter({
    required this.id,
    required this.name,
    required this.subName,
    required this.content,
    required this.createdTime,
    required this.view,
    required this.isPay,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String? ?? 'Unknown ID', // Giá trị mặc định nếu null
      name: json['name'] as String? ?? 'No Name', // Giá trị mặc định nếu null
      subName: json['subName'] as String? ?? 'No Subname', // Giá trị mặc định nếu null
      content: json['content'] as String? ?? 'No Content', // Giá trị mặc định nếu null
      createdTime: DateTime.parse(json['createdTime'] as String? ?? DateTime.now().toIso8601String()), // Giá trị mặc định nếu null
      view: json['view'] as String? ?? '0', // Giá trị mặc định nếu null
      isPay: json['isPay'] as bool? ?? false, // Giá trị mặc định nếu null
    );
  }
}
