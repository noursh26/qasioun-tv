class LiveChannel {
  final String id;
  final String name;
  final String imageUrl;
  final String quality;
  final String category;
  final String streamUrl;
  final bool isHd;

  LiveChannel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.quality,
    required this.category,
    required this.streamUrl,
    required this.isHd,
  });

  factory LiveChannel.fromJson(Map<String, dynamic> json) {
    // Check if the keys are from the kids format or general format
    final String parsedName = json['name'] ?? json['title'] ?? '';
    final String parsedImageUrl = json['image'] ?? json['imageAsset'] ?? '';
    final String parsedStreamUrl = json['stream_url'] ?? json['videoUrl'] ?? '';
    final String parsedId = json['id']?.toString() ?? parsedName.hashCode.toString();
    
    return LiveChannel(
      id: parsedId,
      name: parsedName,
      imageUrl: parsedImageUrl,
      quality: json['quality'] ?? 'SD',
      category: json['category'] ?? '',
      streamUrl: parsedStreamUrl,
      isHd: json['isHD'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': imageUrl,
      'quality': quality,
      'category': category,
      'stream_url': streamUrl,
      'isHD': isHd,
    };
  }
}
