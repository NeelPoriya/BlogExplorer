import 'package:blog_explorer/models/Blog.dart';
import 'package:blog_explorer/screens/BlogListView.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const BlogExplorerApp());
}

class BlogExplorerApp extends StatelessWidget {
  const BlogExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Blog Explorer',
      home: BlogListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({super.key});

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  List<Blog> blogs = [];

  @override
  void initState() {
    super.initState();
    fetchBlogs();
  }

  Future<void> fetchBlogs() async {
    final response = await http.get(
      Uri.parse('https://intent-kit-16.hasura.app/api/rest/blogs'),
      headers: {
        'x-hasura-admin-secret':
            '32qR4KmXOIpsGPQKMqEJHGJS27G5s7HdSKO3gdtQd2kv5e852SiYwWNfxkZOBuQ6',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> blogList = data['blogs'];
      final List<Blog> loadedBlogs = blogList.map((blogData) {
        return Blog(
          id: blogData['id'],
          imageUrl: blogData['image_url'],
          title: blogData['title'],
        );
      }).toList();
      setState(() {
        blogs = loadedBlogs;
      });
    } else {
      throw Exception('Failed to load blogs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Explorer'),
      ),
      body: BlogList(blogs: blogs),
    );
  }
}
