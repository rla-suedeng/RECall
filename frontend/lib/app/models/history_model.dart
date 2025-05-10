class HistoryModel {
  final int hId;
  final int rId;
  final String uId;
  final String? summary;
  final String? date;

  HistoryModel({
    required this.hId,
    required this.rId,
    required this.uId,
    this.summary,
    this.date,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      hId: json['h_id'],
      rId: json['r_id'],
      uId: json['u_id'],
      summary: json['summary'],
      date: json['date'],
    );
  }
}
