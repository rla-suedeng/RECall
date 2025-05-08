import 'package:intl/intl.dart';

class RecModel {
  final String? rId; // 백엔드에서 생성됨
  final String uId; // 현재 로그인된 사용자 uid
  final String title; // title
  final String? content; // 메모리 설명
  final String? fileUrl; // Firebase Storage의 다운로드 URL
  final String? date; // yyyy-MM-dd 형식
  final String category; // childhood, family, travel, special
  final String? author; // 생성 유저 이름 등

  RecModel({
    this.rId,
    required this.uId,
    required this.title,
    this.content,
    this.fileUrl,
    this.date,
    required this.category,
    this.author,
  });

  factory RecModel.fromJson(Map<String, dynamic> json) => RecModel(
        rId: json['r_id']?.toString(),
        uId: json['u_id'] ?? '',
        title: json['title'] ?? 'Untitled',
        content: json['content'],
        fileUrl: json['file'],
        date: json['r_date'] ?? json['date'],
        category: json['category'] ?? 'etc',
        author: json['author'],
      );

  Map<String, dynamic> toJson() => {
        'u_id': uId,
        'title': title,
        'content': content,
        'file': fileUrl,
        'r_date': date ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'category': category,
        'author': author,
      };
}
