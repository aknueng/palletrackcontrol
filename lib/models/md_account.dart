class MAccount {
  final String code;
  final String shortName;
  final String fullName;
  final DateTime joinDate;
  final String posit;
  final String token;
  final String role;
  final String telephone;
  final DateTime logInDate;

  MAccount({
    required this.code,
    required this.shortName,
    required this.fullName,
    required this.joinDate,
    required this.posit,
    required this.token,
    required this.role,
    required this.telephone,
    required this.logInDate,
  });

  factory MAccount.fromJson(Map<String, dynamic> json) {
    return MAccount(
        code: json['code'].toString(),
        shortName: json['shortName'].toString(),
        fullName: json['fullName'].toString(),
        joinDate: DateTime.parse(json['joinDate'].toString()),
        posit: json['posit'].toString(),
        token: json['token'].toString(),
        role: json['role'].toString(),
        telephone: json['telephone'].toString(),
        logInDate: DateTime.parse(json['logInDate'].toString()));
  }
}