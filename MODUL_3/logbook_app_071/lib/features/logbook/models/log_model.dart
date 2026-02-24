class LogModel {
  final String title;
  final String description;
  final String date;
  final String category; // 'Pribadi', 'Pekerjaan', 'Urgent'

  LogModel({
    required this.title,
    required this.description,
    required this.date,
    this.category = 'Pribadi', // default kategori
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'category': category,
    };
  }

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      category: map['category'] ?? 'Pribadi',
    );
  }
}
