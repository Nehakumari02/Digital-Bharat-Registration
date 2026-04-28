class DashboardStats {
  final String registrations;
  final String users;
  final String approved;

  DashboardStats({
    required this.registrations,
    required this.users,
    required this.approved,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      registrations: json['registrations'] ?? '0',
      users: json['users'] ?? '0',
      approved: json['approved'] ?? '0',
    );
  }
}

class Announcement {
  final String title;
  final String subtitle;
  final String colorHex;
  final String iconName;

  Announcement({
    required this.title,
    required this.subtitle,
    required this.colorHex,
    required this.iconName,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      title: json['title'] ?? 'Announcement',
      subtitle: json['subtitle'] ?? '',
      colorHex: json['color'] ?? '0xFFF26522',
      iconName: json['icon'] ?? 'announcement',
    );
  }
}

class FeedItem {
  final String title;
  final String subtitle;
  final String colorHex;
  final String iconName;

  FeedItem({
    required this.title,
    required this.subtitle,
    required this.colorHex,
    required this.iconName,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      title: json['title'] ?? 'Update',
      subtitle: json['subtitle'] ?? '',
      colorHex: json['color'] ?? '0xFFF26522',
      iconName: json['icon'] ?? 'info',
    );
  }
}
