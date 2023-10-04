class Blog {
  final String id;
  final String imageUrl;
  final String title;

  Blog({required this.id, required this.imageUrl, required this.title});

  static Blog fromJson(json) =>
      Blog(id: json['id'], imageUrl: json['image_url'], title: json['title']);
}
