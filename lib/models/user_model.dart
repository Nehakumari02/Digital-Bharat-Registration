class UserRegistration {
  final String id;
  final String name;
  final String mobile;
  final String state;
  final String city;
  final String pinCode;
  final String district;
  final String category; // student, business, bank, farmers

  UserRegistration({
    required this.id,
    required this.name,
    required this.mobile,
    required this.state,
    required this.city,
    required this.pinCode,
    required this.district,
    required this.category,
  });
}