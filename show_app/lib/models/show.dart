class Show {
  final int id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;

  Show({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
  });

  factory Show.fromJson(Map<String, dynamic> json) {
    return Show(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
    };
  }
}