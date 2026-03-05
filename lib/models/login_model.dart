class LoginModel {
  final String mobile;
  final String password; // 1. Added the variable declaration

  LoginModel({
    required this.mobile, // 2. Added a comma here
    required this.password, // 3. Kept the brace OUTSIDE the parentheses
  });

  Map<String, dynamic> toJson() {
    return {
      "mobile": mobile,
      "password": password,
    };
  }
}