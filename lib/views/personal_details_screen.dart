import 'package:flutter/material.dart';
import 'package:the_digital_registration/widgets/responsive_layout.dart';

class PersonalDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const PersonalDetailsScreen({super.key, required this.userData});

  static const _preferredOrder = [
    'name',
    'mobile',
    'email',
    'registration_type',
    'registration_fee',
    'partner_code',
    'wallet_balance',
    'category',
    'pincode',
    'district',
    'city',
    'state',
    'created_at',
    'updated_at',
  ];

  static const _hiddenKeys = {'password', 'id', '_id', '__v'};

  @override
  Widget build(BuildContext context) {
    final entries = _orderedEntries(userData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Details'),
        centerTitle: true,
      ),
      body: ResponsiveScrollBody(
        children: [
              const SizedBox(height: 12),
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF2196F3),
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              ...entries.map(_detailCard),
              const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<MapEntry<String, dynamic>> _orderedEntries(Map<String, dynamic> data) {
    final shown = <String>{};
    final ordered = <MapEntry<String, dynamic>>[];

    for (final key in _preferredOrder) {
      if (!data.containsKey(key) || _hiddenKeys.contains(key)) continue;
      final value = data[key];
      if (!_hasValue(value)) continue;
      ordered.add(MapEntry(key, value));
      shown.add(key);
    }

    for (final entry in data.entries) {
      if (shown.contains(entry.key) || _hiddenKeys.contains(entry.key)) {
        continue;
      }
      if (!_hasValue(entry.value)) continue;
      ordered.add(entry);
    }

    return ordered;
  }

  bool _hasValue(dynamic value) {
    if (value == null) return false;
    final s = value.toString().trim();
    return s.isNotEmpty && s != 'null';
  }

  Widget _detailCard(MapEntry<String, dynamic> entry) {
    return Builder(
      builder: (context) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            title: Text(
              _formatKey(entry.key),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            subtitle: Builder(
              builder: (context) {
                return Text(
                  entry.value.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                );
              }
            ),
          ),
        );
      }
    );
  }

  String _formatKey(String key) {
    return key.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
