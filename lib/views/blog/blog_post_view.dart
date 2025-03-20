import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mobile/models/blog/blog_post.dart';

class BlogPostView extends StatelessWidget {
  final BlogPost blogPost;

  const BlogPostView({super.key, required this.blogPost});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(blogPost.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Html(data: blogPost.content),
      ),
    );
  }
}
