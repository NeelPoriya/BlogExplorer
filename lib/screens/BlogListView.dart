import 'package:blog_explorer/models/Blog.dart';
import 'package:flutter/material.dart';

class BlogList extends StatelessWidget {
  final List<Blog> blogs;

  const BlogList({super.key, required this.blogs});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: blogs.length,
      itemBuilder: (BuildContext context, int index) {
        final blog = blogs[index];
        return ListTile(
          leading: Image.network(blog.imageUrl),
          title: Text(
            blog.title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            // Navigate to the blog details screen with 'blog' data
            // You can implement this navigation as needed.
          },
        );
      },
    );
  }
}
