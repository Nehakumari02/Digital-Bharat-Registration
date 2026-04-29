import 'package:flutter/material.dart';
import '../../widgets/admin_widgets.dart';
import 'manage_users_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("Admin Console", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.black87),
            onPressed: () {},
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "System Overview",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            
            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: const [
                AdminStatCard(
                  title: "Total Users",
                  value: "12,482",
                  icon: Icons.people_alt_rounded,
                  color: Colors.blue,
                  trend: "+12%",
                ),
                AdminStatCard(
                  title: "Pending Approvals",
                  value: "154",
                  icon: Icons.pending_actions_rounded,
                  color: Colors.orange,
                  trend: "High",
                ),
                AdminStatCard(
                  title: "Active Services",
                  value: "24",
                  icon: Icons.grid_view_rounded,
                  color: Colors.teal,
                  trend: "Stable",
                ),
                AdminStatCard(
                  title: "Daily Traffic",
                  value: "3.2K",
                  icon: Icons.trending_up_rounded,
                  color: Colors.purple,
                  trend: "+18%",
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            const AdminSectionTitle(title: "Recent Activity"),
            const SizedBox(height: 16),
            const UserActivityTile(
              name: "Rahul Sharma",
              action: "submitted a Farmer Loan application",
              time: "2 minutes ago",
              category: "Farmers",
            ),
            const UserActivityTile(
              name: "Priya Patel",
              action: "updated her student profile",
              time: "15 minutes ago",
              category: "Student",
            ),
            const UserActivityTile(
              name: "Axis Bank",
              action: "verified 12 new leads",
              time: "1 hour ago",
              category: "Bank",
            ),
            const UserActivityTile(
              name: "Suresh Meena",
              action: "registered as a new Business user",
              time: "2 hours ago",
              category: "Business",
            ),
            
            const SizedBox(height: 32),
            const AdminSectionTitle(title: "Quick Management"),
            const SizedBox(height: 16),
            
            // Management Buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManageUsersScreen()),
                      );
                    },
                    child: _quickManageButton(
                      context,
                      "Users",
                      Icons.manage_accounts_rounded,
                      Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _quickManageButton(
                    context,
                    "Services",
                    Icons.settings_suggest_rounded,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _quickManageButton(BuildContext context, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
