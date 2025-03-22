class BlogPost {
  final String title;
  final String language;
  final String path;
  final String content;

  BlogPost({
    required this.title,
    required this.language,
    required this.path,
    required this.content,
  });

  // Factory constructor for creating an instance from JSON
  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      title: json['title'],
      language: json['language'],
      path: json['path'],
      content: json['content'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'language': language,
      'path': path,
      'content': content,
    };
  }
}
