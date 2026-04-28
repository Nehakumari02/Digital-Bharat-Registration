import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import '../models/dashboard_model.dart';

class DashboardController {
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else {
      return 'http://10.0.2.2:8000/api';
    }
  }

  Future<DashboardStats> fetchDashboardStats() async {
    try {
      final url = Uri.parse('$_baseUrl/dashboard-stats');
      final response = await http.get(url, headers: {"Accept": "application/json"});
      
      if (response.statusCode == 200) {
        return DashboardStats.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load stats');
      }
    } catch (e) {
      // Return a default on failure so the UI doesn't crash completely
      return DashboardStats(registrations: "0", users: "0", approved: "0");
    }
  }

  Future<List<Announcement>> fetchAnnouncements() async {
    try {
      final url = Uri.parse('$_baseUrl/announcements');
      final response = await http.get(url, headers: {"Accept": "application/json"});
      
      if (response.statusCode == 200) {
        Iterable l = jsonDecode(response.body);
        return List<Announcement>.from(l.map((model) => Announcement.fromJson(model)));
      } else {
        throw Exception('Failed to load announcements');
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<FeedItem>> fetchUserFeed(String category) async {
    try {
      // Passing category as a query parameter
      final url = Uri.parse('$_baseUrl/user-feed?category=$category');
      final response = await http.get(url, headers: {"Accept": "application/json"});
      
      if (response.statusCode == 200) {
        Iterable l = jsonDecode(response.body);
        return List<FeedItem>.from(l.map((model) => FeedItem.fromJson(model)));
      } else {
        throw Exception('Failed to load user feed');
      }
    } catch (e) {
      return [];
    }
  }
}
