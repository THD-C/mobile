import 'package:mobile/models/blog/blog_post.dart';

class BlogsResponse {
  final List<BlogPost> blogs;

  BlogsResponse({required this.blogs});

  factory BlogsResponse.fromJson(Map<String, dynamic> json) {
    return BlogsResponse(
      blogs:
          (json["Blogs"] as List<dynamic>)
              .map((post) => BlogPost.fromJson(post))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {"Blogs": blogs.map((blog) => blog.toJson()).toList()};
  }

  List<BlogPost> toList() {
    return blogs;
  }
}
