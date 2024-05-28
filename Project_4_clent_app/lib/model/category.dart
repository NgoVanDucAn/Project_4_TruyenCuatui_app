class Category {
  String id;
  String name;
  String description;

  Category({required this.id, required this.name, required this.description});


  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: json['name'] ?? "",
      description: json['description']?? "",
    );
  }

}