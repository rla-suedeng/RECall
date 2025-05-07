class UserModel {
  final String uId;
  final String role;
  final String? pId; // 환자ID는 care일 경우만 있을 수 있음
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
        uId: json['u_id'],
        role: json['role'],
        pId: json['p_id'],
        fName: json['f_name'],
        lName: json['l_name'],
        birthday: json['birthday'],
        email: json['email'],
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
