class TvSeries {
  final int id;
  final String name;
  final String year;
  final String title;
  final double rating;
  final String category;
  final List<Episode> episodes;
  final String imageAsset;
  final String description;

  TvSeries({
    required this.id,
    required this.name,
    required this.year,
    required this.title,
    required this.rating,
    required this.category,
    required this.episodes,
    required this.imageAsset,
    required this.description,
  });

  factory TvSeries.fromJson(Map<String, dynamic> json) {
    var episodeList = json['episodes'] as List? ?? [];
    List<Episode> parsedEpisodes = episodeList.map((e) => Episode.fromJson(e)).toList();

    double parsedRating = 0.0;
    if (json['rating'] != null) {
      if (json['rating'] is num) {
        parsedRating = (json['rating'] as num).toDouble();
      } else {
        parsedRating = double.tryParse(json['rating'].toString()) ?? 0.0;
      }
    }

    return TvSeries(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['title'] ?? '',
      year: json['year']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? '',
      rating: parsedRating,
      category: json['category'] ?? '',
      episodes: parsedEpisodes,
      imageAsset: json['imageAsset'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'year': year,
      'title': title,
      'rating': rating,
      'category': category,
      'episodes': episodes.map((e) => e.toJson()).toList(),
      'imageAsset': imageAsset,
      'description': description,
    };
  }
}

class Episode {
  final String title;
  final String videoUrl;

  Episode({
    required this.title,
    required this.videoUrl,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      title: json['title'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'videoUrl': videoUrl,
    };
  }
}
