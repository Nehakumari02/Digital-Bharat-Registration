class RegistrationModel {
  final String name;
  final String mobile;
  final String category;
  final String state;
  final String city;

  RegistrationModel({
    required this.name,
    required this.mobile,
    required this.category,
    this.state = "Punjab",
    this.city = "Chandigarh",
  });

  // Converts the Object into a Map that the Laravel API can understand
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "mobile": mobile,
      "category": category,
      "state": state,
      "city": city,
    };
  }
}