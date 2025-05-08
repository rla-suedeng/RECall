class UserModel {
  final String uId;
  final bool role;
  final String? pId;
  final String fName;
  final String lName;
  final String birthday;
  final String email;

  UserModel({
    required this.uId,
    required this.role,
    this.pId,
    required this.fName,
    required this.lName,
    required this.birthday,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uId: json['u_id'] ?? '',
        role: json['role'] ?? false,
        pId: json['p_id'],
        fName: json['f_name'] ?? 'Unknown',
        lName: json['l_name'] ?? '',
        birthday: json['birthday'] ?? '',
        email: json['email'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'u_id': uId,
        'role': role,
        'p_id': pId,
        'f_name': fName,
        'l_name': lName,
        'birthday': birthday,
        'email': email,
      };
}
