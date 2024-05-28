class Story {
  final String name;
  final String image;
  final String description;
  final String subname;
  final String id;
  final bool isComic;  // Add this to distinguish between novels and comics

  Story({
    required this.name,
    required this.image,
    required this.description,
    required this.subname,
    required this.id,
    this.isComic = false,
  });

  // factory constructor for creating a new Category instance from a map
  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      name: json['name'] ?? '',
      image: json['image'],
      description: json['description'] ?? '',
      subname: json['subname'] ?? '',
      id: json['id'].toString(),
       isComic: json['isComic'] ?? false,
    );
  }
}
