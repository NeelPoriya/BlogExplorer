import 'package:blog_explorer/models/Blog.dart';
import 'package:blog_explorer/models/FavouritesModel.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(BlogAdapter());

  runApp(
    ChangeNotifierProvider(
      create: (context) => FavouritesModel(),
      child: const BlogExplorerApp(),
    ),
  );
}

class BlogExplorerApp extends StatelessWidget {
  const BlogExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, blogFav, child) => const MaterialApp(
        title: 'Blog Explorer',
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
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

  @override
  void initState() {
    super.initState();
    loadBlogsFromLocal();
  }

  Future<void> loadBlogsFromLocal() async {
    final box = await Hive.openBox<Blog>('blogsBox');
    final loadedBlogs = box.values.toList();

    // print('loadedBlogs: ${loadedBlogs}');

    if (loadedBlogs.isEmpty) {
      await getBlogs();
      return;
    }

    setState(() {
      blogs = Future(() => loadedBlogs);
    });
  }

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

        List<Blog> result = data['blogs'].map<Blog>(Blog.fromJson).toList();

        // Save blogs to Hive
        final box = await Hive.openBox<Blog>('blogsBox');
        box.addAll(result);

        return result;
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
    return ListView.builder(
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        final blog = blogs[index];

        final isFavourite =
            context.read<FavouritesModel>().favourites.contains(blog.id);

        return GestureDetector(
          onTap: () {
            print(
                'you clicked on ${blog.title} and it is ${context.read<FavouritesModel>().favourites.contains(blog.id)}');
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
                  ),
                ),
                //Favourite icon here
                GestureDetector(
                  onTap: () {
                    context.read<FavouritesModel>().toggleFavorite(blog.id);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFavourite
                              ? Icons.favorite
                              : Icons.favorite_border_outlined,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            context
                                .read<FavouritesModel>()
                                .toggleFavorite(blog.id);
                          });
                        },
                      ),
                      Text(
                        context
                            .read<FavouritesModel>()
                            .favourites
                            .contains(blog.id)
                            .toString(),
                        style: TextStyle(
                          color:
                              blog.isFavorite ? Colors.red : Colors.pinkAccent,
                        ),
                      )
                    ],
                  ),
                ),
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
          // Favourite icon here...
          GestureDetector(
            onTap: () {
              setState(() {
                context.read<FavouritesModel>().toggleFavorite(widget.blog.id);
                setState(() {});
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    context
                            .read<FavouritesModel>()
                            .favourites
                            .contains(widget.blog.id)
                        ? Icons.favorite
                        : Icons.favorite_border_outlined,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      context
                          .read<FavouritesModel>()
                          .toggleFavorite(widget.blog.id);
                      setState(() {});
                    });
                  },
                ),
                Text(
                  context
                      .read<FavouritesModel>()
                      .favourites
                      .contains(widget.blog.id)
                      .toString(),
                  style: TextStyle(
                    color:
                        widget.blog.isFavorite ? Colors.red : Colors.pinkAccent,
                  ),
                )
              ],
            ),
          ),
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
