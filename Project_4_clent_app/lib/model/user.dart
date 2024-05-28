class User {
  String? userId;
  String? email;
  String? gender;
  String? dateOfBirth;
  String? position;
  List<StoryUser>? stories;

  User({
    this.userId,
    this.email,
    this.gender,
    this.dateOfBirth,
    this.position,
    this.stories,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String?,
      email: json['email'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      position: json['position'] as String?,
      stories: json['stories'] != null ? (json['stories'] as List).map((e) => StoryUser.fromJson(e)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'position': position,
      'stories': stories?.map((e) => e.toJson()).toList(),
    };
  }
  @override
  String toString() {
    return 'User(id: $userId, email: $email, gender: $gender, dateOfBirth: $dateOfBirth)';
  }
}

class StoryUser {
  final String? storyId;
  final String? name;
  final String? subName;
  final String? description;
  final String? image;
  final String? createdTime;
  final String? updatedTime;
  final String? view;
  final bool? status;

  StoryUser({
    this.storyId,
    this.name,
    this.subName,
    this.description,
    this.image,
    this.createdTime,
    this.updatedTime,
    this.view,
    this.status,
  });

  factory StoryUser.fromJson(Map<String, dynamic> json) {
    return StoryUser(
      storyId: json['storyId'] as String?,
      name: json['name'] as String?,
      subName: json['subName'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      createdTime: json['createdTime'] as String?,
      updatedTime: json['updatedTime'] as String?,
      view: json['view'] as String?,
      status: json['status'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storyId': storyId,
      'name': name,
      'subName': subName,
      'description': description,
      'image': image,
      'createdTime': createdTime,
      'updatedTime': updatedTime,
      'view': view,
      'status': status,
    };
  }
}
