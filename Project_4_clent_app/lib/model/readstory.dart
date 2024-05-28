class ReadPage {
  final String content;
  final String images;
  final String chapterId;
  final String pageId;

  ReadPage({
    required this.content,
    required this.images,
    required this.chapterId,
    required this.pageId,
  });

  factory ReadPage.fromJson(Map<String, dynamic> json) {
    return ReadPage(
      content: json['content'] as String? ?? 'No content provided',
      images: json['images'] as String? ?? 'No images provided',
      chapterId: json['chapterId'] as String? ?? 'No chapter ID',
      pageId: json['pageId'] as String? ?? 'No page ID',
    );
  }
}

class ReadStory {
  final String chapterId;
  final String chapterName;
  final List<ReadPage> pages;

  ReadStory({
    required this.chapterId,
    required this.chapterName,
    required this.pages,
  });

  factory ReadStory.fromJson(Map<String, dynamic> json) {
    return ReadStory(
      chapterId: json['chapterId'] as String? ?? 'No ID',
      chapterName: json['chapterName'] as String? ?? 'No chapter name',
      pages: (json['pages'] as List<dynamic>?)
              ?.map((page) => ReadPage.fromJson(page as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String get content =>
      pages.isNotEmpty ? pages.first.content : 'No content available';
}
