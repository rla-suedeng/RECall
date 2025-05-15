import 'package:intl/intl.dart';

class RecModel {
  final String? rId;
  final String uId;
  final String title;
  final String? content;
  final String? fileUrl;
  final String? date;
  final String category;
  final String? authorName;

  RecModel({
    this.rId,
    required this.uId,
    required this.title,
    this.content,
    this.fileUrl,
    this.date,
    required this.category,
    this.authorName,
  });

  factory RecModel.fromJson(Map<String, dynamic> json) => RecModel(
        rId: json['r_id']?.toString(),
        uId: json['u_id'] ?? '',
        title: json['title'] ?? 'Untitled',
        content: json['content'],
        fileUrl: json['file'],
        date: json['r_date'] ?? json['date'],
        category: json['category'] ?? 'etc',
        authorName: json['author_name'],
      );

  Map<String, dynamic> toJson() => {
        'u_id': uId,
        'title': title,
        'content': content,
        'file': fileUrl,
        'r_date': date ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'category': category,
        'author': authorName,
      };

  RecModel copyWith({
    String? rId,
    String? uId,
    String? title,
    String? content,
    String? fileUrl,
    String? date,
    String? category,
    String? authorName,
  }) {
    return RecModel(
      rId: rId ?? this.rId,
      uId: uId ?? this.uId,
      title: title ?? this.title,
      content: content ?? this.content,
      fileUrl: fileUrl ?? this.fileUrl,
      date: date ?? this.date,
      category: category ?? this.category,
      authorName: authorName ?? this.authorName,
    );
  }
}
