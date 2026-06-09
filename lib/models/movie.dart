class Movie {
  final String title;
  final String category;
  final String videoUrl;
  final String imageAsset;

  Movie({
    required this.title,
    required this.category,
    required this.videoUrl,
    required this.imageAsset,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      imageAsset: json['imageAsset'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'videoUrl': videoUrl,
      'imageAsset': imageAsset,
    };
  }
}
