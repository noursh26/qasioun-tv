import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/contact_slide.dart';
import '../../services/launcher_service.dart';

class SupportTab extends StatelessWidget {
  final List<ContactSlide> slides;

  const SupportTab({Key? key, required this.slides}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header descriptive text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'الدعم الفني والاشتراكات',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'لطلب تجديد الاشتراك أو الاستفسارات، يمكنك التواصل معنا مباشرة عبر الروابط التالية.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Slides lists
          if (slides.isEmpty)
            _buildFallbackSupportCards(context)
          else
            ...slides.map((slide) => _buildSlideCard(slide)).toList(),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSlideCard(ContactSlide slide) {
    final bgColor = slide.getParsedBackgroundColor();
    final textColor = slide.getParsedTextColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Details
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (slide.title.isNotEmpty) ...[
                      Text(
                        slide.title,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      slide.description,
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        LauncherService.launchWebUrl(slide.link);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: bgColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        elevation: 0,
                      ),
                      child: Text(
                        slide.buttonText.isNotEmpty ? slide.buttonText : 'تواصل معنا',
                        style: TextStyle(
                          color: bgColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Image Banner
            if (slide.imageUrl.isNotEmpty)
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                  child: CachedNetworkImage(
                    imageUrl: slide.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.support_agent_rounded, size: 45, color: Colors.white24),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackSupportCards(BuildContext context) {
    // Return a default whatsapp card if API is not loaded
    final fallbackSlide = ContactSlide(
      id: 1001,
      link: 'whatsapp',
      type: 'subscription',
      title: 'تجديد الاشتراك',
      imageUrl: 'https://i.postimg.cc/k47XDWgf/7877877878-copy-copy.png',
      textColor: '#FFFFFF',
      buttonText: 'تجديد الآن',
      description: 'استمتعوا بمشاهدة جميع القنوات والافلام والمسلسلات الحصرية',
      backgroundColor: '#081830',
    );
    return _buildSlideCard(fallbackSlide);
  }
}
