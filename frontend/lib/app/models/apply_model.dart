class ApplyModel {
  final String uId;
  final String uName;

  ApplyModel({required this.uId, required this.uName});

  factory ApplyModel.fromJson(Map<String, dynamic> json) {
    return ApplyModel(
      uId: json['u_id'] as String,
      uName: json['u_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'u_id': uId,
      'u_name': uName,
    };
  }
}
