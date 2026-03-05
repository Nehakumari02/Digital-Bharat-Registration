class RegistrationModel {
  final String name;
  final String mobile;
  final String category;
  final String pincode;    // Added
  final String district;   // Added
  final String state;
  final String city;

  RegistrationModel({
    required this.name,
    required this.mobile,
    required this.category,
    required this.pincode,   // Added
    required this.district,  // Added
    required this.city,
    required this.state,
  });

  // Converts the Object into a Map that the Laravel API can understand
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "mobile": mobile,
      "category": category,
      "state": state,
      "city": city,
      "pincode": pincode,    // Added
      "district": district,  // Added
      "city": city,
      "state": state,
    };
  }
}