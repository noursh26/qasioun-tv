import 'dart:ui';

class ContactSlide {
  final int id;
  final String link;
  final String type;
  final String title;
  final String imageUrl;
  final String textColor;
  final String buttonText;
  final String description;
  final String backgroundColor;

  ContactSlide({
    required this.id,
    required this.link,
    required this.type,
    required this.title,
    required this.imageUrl,
    required this.textColor,
    required this.buttonText,
    required this.description,
    required this.backgroundColor,
  });

  factory ContactSlide.fromJson(Map<String, dynamic> json) {
    return ContactSlide(
      id: json['id'] ?? 0,
      link: json['link'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      textColor: json['textColor'] ?? '#FFFFFF',
      buttonText: json['buttonText'] ?? '',
      description: json['description'] ?? '',
      backgroundColor: json['backgroundColor'] ?? '#000000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'link': link,
      'type': type,
      'title': title,
      'imageUrl': imageUrl,
      'textColor': textColor,
      'buttonText': buttonText,
      'description': description,
      'backgroundColor': backgroundColor,
    };
  }

  Color getParsedTextColor() {
    try {
      final hexColor = textColor.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (_) {
      return const Color(0xFFFFFFFF);
    }
  }

  Color getParsedBackgroundColor() {
    try {
      final hexColor = backgroundColor.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (_) {
      return const Color(0xFF000000);
    }
  }
}
