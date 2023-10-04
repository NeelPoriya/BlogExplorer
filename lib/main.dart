import 'package:blog_explorer/models/Blog.dart';
import 'package:blog_explorer/models/BlogFavorites.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

void main() async {
  // await Hive.initFlutter();

  // runApp(
  //   ChangeNotifierProvider(
  //     create: (context) => BlogFavorites(),
  //     child: const BlogExplorerApp(),
  //   ),
  // );

  runApp(
    const BlogExplorerApp(),
  );
}

class BlogExplorerApp extends StatelessWidget {
  const BlogExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Blog Explorer',
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Blog>> blogs = getBlogs();

  // Future<void> loadBlogsFromLocal() async {
  //   final box = await Hive.openBox<Blog>('blogsBox');
  //   final loadedBlogs = box.values.toList();
  //   setState(() {
  //     blogs = Future(() => loadedBlogs);
  //   });
  // }

  static Future<List<Blog>> getBlogs() async {
    const String url = 'https://intent-kit-16.hasura.app/api/rest/blogs';
    const String adminSecret =
        '32qR4KmXOIpsGPQKMqEJHGJS27G5s7HdSKO3gdtQd2kv5e852SiYwWNfxkZOBuQ6';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'x-hasura-admin-secret': adminSecret,
      });

      if (response.statusCode == 200) {
        // Request successful, handle the response data here
        final data = json.decode(response.body);

        // Save blogs to Hive
        // final box = await Hive.openBox<Blog>('blogsBox');
        // box.addAll(data['blogs']);

        return data['blogs'].map<Blog>(Blog.fromJson).toList();
      } else {
        // Request failed
        print('Request failed with status code: ${response.statusCode}');
        print('Response data: ${response.body}');
      }
    } catch (e) {
      // Handle any errors that occurred during the request
      print('Error: $e');
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Explorer'),
      ),
      body: FutureBuilder<List<Blog>>(
          future: blogs,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data!);
              return buildBlogsListView(snapshot.data!);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Widget buildBlogsListView(List<Blog> blogs) {
    // return Consumer<BlogFavorites>(
    //   builder: (context, blogFavorites, child) {
    //     return ListView.builder(
    //       itemCount: blogs.length,
    //       itemBuilder: (BuildContext context, int index) {
    //         final blog = blogs[index];
    //         final isFavorite = blogFavorites.favoriteIds.contains(blog.id);
    //         return ListTile(
    //           leading: Image.network(blog.imageUrl),
    //           title: Text(blog.title),
    //           trailing: IconButton(
    //             icon: Icon(
    //               isFavorite ? Icons.favorite : Icons.favorite_border,
    //               color: Colors.red,
    //             ),
    //             onPressed: () {
    //               // Toggle the favorite status using the provider
    //               context.read<BlogFavorites>().toggleFavorite(blog.id);
    //             },
    //           ),
    //           onTap: () {
    //             // Navigate to the blog details screen with 'blog' data
    //             // You can implement this navigation as needed.
    //           },
    //         );
    //       },
    //     );
    //   },
    // );

    return ListView.builder(
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        final blog = blogs[index];

        return GestureDetector(
          onTap: () {
            print('you clicked on ${blog.title}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  // return Scaffold();
                  return BlogDetailsView(blog: blog);
                },
              ),
            );
          },
          child: Card(
            child: Column(
              children: [
                Image.network(
                  blog.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    child: Text(
                      blog.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BlogDetailsView extends StatefulWidget {
  final Blog blog;

  BlogDetailsView({required this.blog});

  @override
  State<BlogDetailsView> createState() => _BlogDetailsViewState();
}

class _BlogDetailsViewState extends State<BlogDetailsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Text(
              widget.blog.title,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Image.network(
            widget.blog.imageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 30.0),
          const Padding(
            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            child: Text(
              'lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua Ut enim ad minim veniam quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur Excepteur sint occaecat cupidatat non proident sunt in culpa qui officia deserunt mollit anim id est laborum.',
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'Poppins',
              ),
            ),
          )
        ],
      ),
    );
  }
}
