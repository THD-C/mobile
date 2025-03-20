import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/main.dart';
import 'package:mobile/models/blog/blog_post.dart';
import 'package:mobile/models/blog/blog_response.dart';

class BlogView extends StatefulWidget {
  const BlogView({super.key});

  @override
  State<BlogView> createState() => _BlogViewState();
}

class _BlogViewState extends State<BlogView> {
  List<String> _filteredPosts = [];
  String _titleSearchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BottomAppBar(
          child: TextField(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate('search'),
              border: OutlineInputBorder(),
            ),
            onChanged: _updateSearchQuery,
          ),
        ),
        Expanded(
          child: FutureBuilder<List<BlogPost>>(
            future: fetchBlogPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data!.elementAt(index).title),
                    );
                  },
                );
              }

              return Center(
                child: Text(
                  AppLocalizations.of(context).translate('blog_no_posts_found'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Uri get uri {
    return Uri.parse('$baseURL/api/blog/').replace(
      queryParameters: {
        'title': '$_titleSearchQuery*',
        'language': Localizations.localeOf(context).languageCode,
      },
    );
  }

  Future<List<BlogPost>> fetchBlogPosts() async {
    final response = await http.get(uri);
    print(response.statusCode);
    if (response.statusCode == 204) {
      return List.empty();
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> parsedJson = json.decode(response.body);
      final blogsResponse = BlogsResponse.fromJson(parsedJson);
      final List<BlogPost> blogPosts = blogsResponse.toList();

      for (var post in blogPosts) {
        print('Title: ${post.toJson()}');
      }

      return blogPosts;
    }

    throw Exception(
      AppLocalizations.of(context).translate('blog_get_posts_exception'),
    );
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _titleSearchQuery = query;
    });
  }
}
