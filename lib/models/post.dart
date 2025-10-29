/// Model for a community post
class Post {
  final String id;
  final String userId;
  final String userName;
  final String? userTitle;
  final String? userPhotoUrl;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final List<String> likedBy;
  final List<String> industries; // Industry tags for the post
  final bool isVerified; // If user is verified

  const Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userTitle,
    this.userPhotoUrl,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.likedBy = const [],
    this.industries = const [],
    this.isVerified = false,
  });

  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userTitle,
    String? userPhotoUrl,
    String? content,
    String? imageUrl,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    List<String>? likedBy,
    List<String>? industries,
    bool? isVerified,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userTitle: userTitle ?? this.userTitle,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      likedBy: likedBy ?? this.likedBy,
      industries: industries ?? this.industries,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userTitle': userTitle,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'likedBy': likedBy,
      'industries': industries,
      'isVerified': isVerified,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'User',
      userTitle: json['userTitle'] as String?,
      userPhotoUrl: json['userPhotoUrl'] as String?,
      content: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      sharesCount: json['sharesCount'] as int? ?? 0,
      likedBy: (json['likedBy'] as List<dynamic>?)?.cast<String>() ?? [],
      industries: (json['industries'] as List<dynamic>?)?.cast<String>() ?? [],
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
}
