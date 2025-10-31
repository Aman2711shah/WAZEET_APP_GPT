class BusinessNewsItem {
  final String industry; // e.g. Technology, Finance
  final String headline;
  final String source; // e.g. Google News, Bloomberg
  final DateTime publishedAt;
  final String url;
  final String? thumbnailUrl;
  final String? logoUrl;

  const BusinessNewsItem({
    required this.industry,
    required this.headline,
    required this.source,
    required this.publishedAt,
    required this.url,
    this.thumbnailUrl,
    this.logoUrl,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(publishedAt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
