import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorTitle;
  final String? authorAvatarUrl;
  final bool isVerified;
  final String? text;
  final List<PostMedia> media;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final List<String> industries;

  const Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorTitle,
    this.authorAvatarUrl,
    this.isVerified = false,
    this.text,
    this.media = const [],
    required this.createdAt,
    required this.updatedAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.industries = const [],
  });

  Post copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorTitle,
    String? authorAvatarUrl,
    bool? isVerified,
    String? text,
    List<PostMedia>? media,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    List<String>? industries,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorTitle: authorTitle ?? this.authorTitle,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      isVerified: isVerified ?? this.isVerified,
      text: text ?? this.text,
      media: media ?? this.media,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      industries: industries ?? this.industries,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
      'author': {
        'fullName': authorName,
        'headline': authorTitle,
        'avatarUrl': authorAvatarUrl,
        'isVerified': isVerified,
      },
      'text': text,
      'media': media.map((m) => m.toJson()).toList(),
      'industries': industries,
      'likeCount': likesCount,
      'commentCount': commentsCount,
      'sharesCount': sharesCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Post.fromMap(data, id: doc.id);
  }

  factory Post.fromMap(Map<String, dynamic> data, {String id = ''}) {
    final author = data['author'] as Map<String, dynamic>? ?? {};
    return Post(
      id: id,
      authorId: data['authorId'] as String? ?? data['userId'] as String? ?? '',
      authorName:
          author['fullName'] as String? ??
          data['userName'] as String? ??
          'Member',
      authorTitle:
          author['headline'] as String? ?? data['userTitle'] as String?,
      authorAvatarUrl:
          author['avatarUrl'] as String? ?? data['userPhotoUrl'] as String?,
      isVerified:
          author['isVerified'] as bool? ?? data['isVerified'] as bool? ?? false,
      text: data['text'] as String? ?? data['content'] as String?,
      media:
          (data['media'] as List<dynamic>?)
              ?.map((item) => PostMedia.fromJson(item as Map<String, dynamic>))
              .toList() ??
          _legacyMediaFallback(data),
      createdAt: _parseDate(data['createdAt']),
      updatedAt: data['updatedAt'] != null
          ? _parseDate(data['updatedAt'])
          : _parseDate(data['createdAt']),
      likesCount: data['likeCount'] as int? ?? data['likesCount'] as int? ?? 0,
      commentsCount:
          data['commentCount'] as int? ?? data['commentsCount'] as int? ?? 0,
      sharesCount: data['sharesCount'] as int? ?? 0,
      industries:
          (data['industries'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }

  static List<PostMedia> _legacyMediaFallback(Map<String, dynamic> data) {
    final imageUrl = data['imageUrl'] as String?;
    if (imageUrl == null || imageUrl.isEmpty) return const [];
    return [
      PostMedia(
        type: 'image',
        url: imageUrl,
        path: data['imagePath'] as String? ?? '',
        mime: 'image/jpeg',
      ),
    ];
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}

class PostMedia {
  final String type;
  final String url;
  final String path;
  final String mime;
  final int? width;
  final int? height;
  final int? durationMs;

  const PostMedia({
    required this.type,
    required this.url,
    required this.path,
    required this.mime,
    this.width,
    this.height,
    this.durationMs,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
      'path': path,
      'mime': mime,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (durationMs != null) 'durationMs': durationMs,
    };
  }

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      type: json['type'] as String? ?? 'image',
      url: json['url'] as String? ?? '',
      path: json['path'] as String? ?? '',
      mime: json['mime'] as String? ?? 'image/jpeg',
      width: json['width'] as int?,
      height: json['height'] as int?,
      durationMs: json['durationMs'] as int?,
    );
  }
}
