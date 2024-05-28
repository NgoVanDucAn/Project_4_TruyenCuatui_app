class SubStory {
  final String id;
  final String name;
  final String description;
  final String image;
  final bool status;

  SubStory({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.status,
  });

  factory SubStory.fromJson(Map<String, dynamic> json) {
    return SubStory(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? "",
      image: json['image'] ?? "",
      status: json['status'] ?? false,
    );
  }
}
