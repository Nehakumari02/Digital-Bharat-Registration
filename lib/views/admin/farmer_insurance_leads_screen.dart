import 'package:flutter/material.dart';
import '../../controllers/service_controller.dart';

class FarmerInsuranceLeadsScreen extends StatefulWidget {
  const FarmerInsuranceLeadsScreen({super.key});

  @override
  State<FarmerInsuranceLeadsScreen> createState() => _FarmerInsuranceLeadsScreenState();
}

class _FarmerInsuranceLeadsScreenState extends State<FarmerInsuranceLeadsScreen> {
  final ServiceController _controller = ServiceController();
  late Future<List<dynamic>> _future;
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _future = _controller.fetchFarmerInsuranceApplications();
  }

  void _refresh() {
    setState(() {
      _future = _controller.fetchFarmerInsuranceApplications();
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  List<dynamic> _applyFilters(List<dynamic> list) {
    return list.where((app) {
      final name = (app['farmer_name'] ?? '').toString().toLowerCase();
      final crop = (app['crop_name'] ?? '').toString().toLowerCase();
      final district = (app['district'] ?? '').toString().toLowerCase();
      final matchSearch = _searchQuery.isEmpty ||
          name.contains(_searchQuery.toLowerCase()) ||
          crop.contains(_searchQuery.toLowerCase()) ||
          district.contains(_searchQuery.toLowerCase());
      final matchStatus = _statusFilter == 'All' ||
          (app['status'] ?? '').toString().toLowerCase() == _statusFilter.toLowerCase();
      return matchSearch && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Farmer Insurance Applications',
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
          // Search + Filter Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search by name, crop, district…',
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
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _statusFilter,
                      items: ['All', 'Pending', 'Approved', 'Rejected']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _statusFilter = v ?? 'All'),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Applications List
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.green));
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
                        Icon(Icons.agriculture, size: 72, color: Colors.green.shade200),
                        const SizedBox(height: 16),
                        Text(
                          all.isEmpty
                              ? 'No insurance applications yet'
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
                    return _InsuranceApplicationCard(
                      app: app,
                      statusColor: _statusColor(app['status'] ?? 'Pending'),
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

class _InsuranceApplicationCard extends StatefulWidget {
  final Map<String, dynamic> app;
  final Color statusColor;

  const _InsuranceApplicationCard({required this.app, required this.statusColor});

  @override
  State<_InsuranceApplicationCard> createState() => _InsuranceApplicationCardState();
}

class _InsuranceApplicationCardState extends State<_InsuranceApplicationCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final status = app['status'] ?? 'Pending';

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
          // Header Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade600, Colors.green.shade300],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 26),
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
                              app['farmer_name'] ?? 'Unknown Farmer',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: widget.statusColor.withOpacity(0.4)),
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
                        runSpacing: 6,
                        children: [
                          _chip(Icons.grass, app['crop_name'] ?? 'N/A', Colors.green),
                          _chip(Icons.wb_sunny_outlined, app['season'] ?? 'N/A', Colors.amber),
                          _chip(Icons.monetization_on, '₹${app['sum_insured'] ?? 0}', Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Expand/Collapse toggle
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _expanded ? 'Hide Details' : 'View Full Details',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.green.shade700,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Details
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('Personal'),
                  _detailRow('Farmer Name', app['farmer_name']),
                  _detailRow('Mobile', app['mobile']),
                  _detailRow('Aadhaar', (app['details'] as Map?)?.containsKey('aadhaar') == true
                      ? (app['details'] as Map)['aadhaar']?.toString()
                      : null),

                  _sectionHeader('Location'),
                  _detailRow('Village', (app['details'] as Map?)?.containsKey('village') == true
                      ? (app['details'] as Map)['village']?.toString() : null),
                  _detailRow('Tehsil', (app['details'] as Map?)?.containsKey('tehsil') == true
                      ? (app['details'] as Map)['tehsil']?.toString() : null),
                  _detailRow('District', app['district']),
                  _detailRow('State', app['state']),

                  _sectionHeader('Land & Crop'),
                  _detailRow('Land Size', '${app['land_size'] ?? 'N/A'} acres'),
                  _detailRow('Khasra No.', (app['details'] as Map?)?.containsKey('khasra_number') == true
                      ? (app['details'] as Map)['khasra_number']?.toString() : null),
                  _detailRow('Crop', app['crop_name']),
                  _detailRow('Season', app['season']),
                  _detailRow('Sowing Date', (app['details'] as Map?)?.containsKey('sowing_date') == true
                      ? (app['details'] as Map)['sowing_date']?.toString() : null),
                  _detailRow('Expected Harvest', (app['details'] as Map?)?.containsKey('expected_harvest') == true
                      ? (app['details'] as Map)['expected_harvest']?.toString() : null),

                  _sectionHeader('Insurance'),
                  _detailRow('Sum Insured', '₹${app['sum_insured'] ?? 0}'),
                  _detailRow('Premium', '₹${app['premium_amount'] ?? 0}'),
                  _detailRow('Bank', app['bank_name']),
                  _detailRow('Account No.', (app['details'] as Map?)?.containsKey('account_number') == true
                      ? (app['details'] as Map)['account_number']?.toString() : null),
                  _detailRow('IFSC', (app['details'] as Map?)?.containsKey('ifsc') == true
                      ? (app['details'] as Map)['ifsc']?.toString() : null),

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
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade700,
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
            width: 120,
            child: Text(key, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
