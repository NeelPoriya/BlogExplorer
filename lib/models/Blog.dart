import 'package:hive/hive.dart';

part 'Blog.g.dart';

@HiveType(typeId: 0)
class Blog extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String imageUrl;
  @HiveField(2)
  final String title;
  @HiveField(3)
  bool isFavorite; // Add this property

  Blog({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.isFavorite = false, // Initialize as not favorite
  });

  static Blog fromJson(json) =>
      Blog(id: json['id'], imageUrl: json['image_url'], title: json['title']);
}
