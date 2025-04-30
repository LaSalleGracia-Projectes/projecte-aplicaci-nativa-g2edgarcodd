class Review {
  final String author;
  final String content;
  final String? avatarPath;
  final double rating;
  final String createdAt;
  final bool isPositive;

  Review({
    required this.author,
    required this.content,
    this.avatarPath,
    required this.rating,
    required this.createdAt,
    required this.isPositive,
  });
} 