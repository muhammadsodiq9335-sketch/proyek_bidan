class ReviewPasien {
  final String name;
  final int rating;
  final String date;
  final String content;
  final int avatarColor;
  String? adminReply;

  ReviewPasien({
    required this.name,
    required this.rating,
    required this.date,
    required this.content,
    required this.avatarColor,
    this.adminReply,
  });
}
