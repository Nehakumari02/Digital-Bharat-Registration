import 'package:flutter/material.dart';
import '../../controllers/service_controller.dart';

class SubsidyLeadsScreen extends StatefulWidget {
  const SubsidyLeadsScreen({super.key});

  @override
  State<SubsidyLeadsScreen> createState() => _SubsidyLeadsScreenState();
}

class _SubsidyLeadsScreenState extends State<SubsidyLeadsScreen> {
  final ServiceController _controller = ServiceController();
  late Future<List<dynamic>> _future;
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _typeFilter = 'All';

  static const _subsidyTypes = [
    'All',
    'Fertilizer Subsidy',
    'Solar Pump Scheme (PM-KUSUM)',
    'Seed Subsidy',
    'Irrigation Equipment',
    'Tractor / Farm Equipment',
    'Drip / Sprinkler Irrigation',
    'Other Government Scheme',
  ];

  @override
  void initState() {
    super.initState();
    _future = _controller.fetchSubsidyApplications();
  }

  void _refresh() {
    setState(() {
      _future = _controller.fetchSubsidyApplications();
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  Color _typeColor(String type) {
    if (type.contains('Fertilizer')) return const Color(0xFF4CAF50);
    if (type.contains('Solar')) return const Color(0xFFFF9800);
    if (type.contains('Seed')) return const Color(0xFF8BC34A);
    if (type.contains('Irrigation') || type.contains('Drip')) return const Color(0xFF03A9F4);
    if (type.contains('Tractor')) return const Color(0xFF795548);
    return const Color(0xFF9E9E9E);
  }

  List<dynamic> _applyFilters(List<dynamic> list) {
    return list.where((app) {
      final name = (app['applicant_name'] ?? '').toString().toLowerCase();
      final district = (app['district'] ?? '').toString().toLowerCase();
      final type = (app['subsidy_type'] ?? '').toString().toLowerCase();
      final matchSearch = _searchQuery.isEmpty ||
          name.contains(_searchQuery.toLowerCase()) ||
          district.contains(_searchQuery.toLowerCase()) ||
          type.contains(_searchQuery.toLowerCase());
      final matchStatus = _statusFilter == 'All' ||
          (app['status'] ?? '').toString().toLowerCase() == _statusFilter.toLowerCase();
      final matchType = _typeFilter == 'All' ||
          (app['subsidy_type'] ?? '').toString() == _typeFilter;
      return matchSearch && matchStatus && matchType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF4),
      appBar: AppBar(
        title: Text('Subsidy Applications',
            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Theme.of(context).colorScheme.onSurface),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by name, district, subsidy type…',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filter row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                // Status filter
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _statusFilter,
                        isExpanded: true,
                        hint: const Text('Status'),
                        items: ['All', 'Pending', 'Approved', 'Rejected']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) => setState(() => _statusFilter = v ?? 'All'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Type filter
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _typeFilter,
                        isExpanded: true,
                        hint: const Text('Type'),
                        items: _subsidyTypes
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (v) => setState(() => _typeFilter = v ?? 'All'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF2196F3)));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final all = snapshot.data ?? [];
                final filtered = _applyFilters(all);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet,
                            size: 72, color: Colors.orange.shade200),
                        const SizedBox(height: 16),
                        Text(
                          all.isEmpty
                              ? 'No subsidy applications yet'
                              : 'No results match your filter',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final app = filtered[index] as Map<String, dynamic>;
                    return _SubsidyCard(
                      app: app,
                      statusColor: _statusColor(app['status'] ?? 'Pending'),
                      typeColor: _typeColor(app['subsidy_type'] ?? ''),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SubsidyCard extends StatefulWidget {
  final Map<String, dynamic> app;
  final Color statusColor;
  final Color typeColor;

  const _SubsidyCard({
    required this.app,
    required this.statusColor,
    required this.typeColor,
  });

  @override
  State<_SubsidyCard> createState() => _SubsidyCardState();
}

class _SubsidyCardState extends State<_SubsidyCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final status = app['status'] ?? 'Pending';
    final subsidyType = app['subsidy_type'] ?? 'N/A';
    final details = app['details'] as Map? ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type icon avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: widget.typeColor.withOpacity(0.3)),
                  ),
                  child: Icon(Icons.account_balance_wallet,
                      color: widget.typeColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              app['applicant_name'] ?? 'Unknown',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: widget.statusColor.withOpacity(0.4)),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: widget.statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '📱 ${app['mobile'] ?? 'N/A'}  •  📍 ${app['district'] ?? 'N/A'}, ${app['state'] ?? ''}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _chip(
                              Icons.category,
                              subsidyType.length > 22
                                  ? '${subsidyType.substring(0, 22)}…'
                                  : subsidyType,
                              widget.typeColor),
                          if (app['scheme_name'] != null &&
                              (app['scheme_name'] as String).isNotEmpty)
                            _chip(Icons.assignment, app['scheme_name'] as String,
                                Colors.indigo),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Expand toggle
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _expanded ? 'Hide Details' : 'View Full Details',
                    style: const TextStyle(
                      color: Color(0xFF2196F3),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF2196F3),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('Subsidy'),
                  _detailRow('Type', app['subsidy_type']),
                  _detailRow('Scheme', app['scheme_name']),
                  _detailRow('Purpose', app['purpose']),

                  _sectionHeader('Personal'),
                  _detailRow('Name', app['applicant_name']),
                  _detailRow('Mobile', app['mobile']),
                  _detailRow('Aadhaar', details['aadhaar']?.toString()),

                  _sectionHeader('Location'),
                  _detailRow('Village', details['village']?.toString()),
                  _detailRow('Tehsil', details['tehsil']?.toString()),
                  _detailRow('District', app['district']),
                  _detailRow('State', app['state']),

                  _sectionHeader('Land'),
                  _detailRow('Land Size', '${app['land_size'] ?? 'N/A'} acres'),
                  _detailRow('Khasra No.', details['khasra_number']?.toString()),

                  _sectionHeader('Bank'),
                  _detailRow('Bank', app['bank_name']),
                  _detailRow('Account No.', details['account_number']?.toString()),
                  _detailRow('IFSC', details['ifsc']?.toString()),

                  const SizedBox(height: 4),
                  Text(
                    'Submitted: ${app['created_at'] ?? 'N/A'}',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2196F3),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _detailRow(String key, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(key,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
