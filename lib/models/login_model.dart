class LoginModel {
  final String mobile;
  // You can add password here if you added it to your Laravel table

  LoginModel(
      {required this.mobile}
      );

  Map<String, dynamic> toJson() {
    return {
      "mobile": mobile,
    };
  }
}