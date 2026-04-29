import 'package:flutter/material.dart';
import 'package:the_digital_registration/views/service_forms.dart';
import 'login_screen.dart';
import 'personal_details_screen.dart';
import 'settings_screen.dart';
import 'security_screen.dart';
import 'help_support_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const DashboardScreen({super.key, required this.userData});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    String category = widget.userData['category'] ?? 'User';

    final List<Widget> _pages = [
      _buildHomeTab(category),
      _buildServicesTab(category),
      _buildProfileTab(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFF26522),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // --- TAB 1: HOME ---
  Widget _buildHomeTab(String category) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 260,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF26522), Color(0xFFFDB913)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(80),
                    bottomRight: Radius.circular(80),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome back,", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
                          Text(
                            widget.userData['name'] ?? "User",
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                            child: Text("$category Portal", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    const CircleAvatar(radius: 25, backgroundColor: Colors.white24, child: Icon(Icons.notifications_none, color: Colors.white)),
                  ],
                ),
              ),
              Positioned(
                top: 180,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: _buildModernStat("2.1L+", "Registered", Icons.group_add)),
                      _buildModernDivider(),
                      Expanded(child: _buildModernStat("6.9L+", "Active Users", Icons.public)),
                      _buildModernDivider(),
                      Expanded(child: _buildModernStat("18K+", "Approved", Icons.verified)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("Highlights"),
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    children: [
                      _promoCard("Digital Rupee", "Experience the new e-Rupee today", Colors.deepPurple, Icons.currency_rupee),
                      _promoCard("Cyber Security", "Stay safe from online frauds", Colors.blue, Icons.security),
                      _promoCard("Skill India", "Free courses for youth", Colors.teal, Icons.school),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _sectionTitle("Quick Actions"),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _getQuickActions(category).map((action) => SizedBox(
                    width: (MediaQuery.of(context).size.width - 56) / 2,
                    height: 100,
                    child: action,
                  )).toList(),
                ),
                const SizedBox(height: 24),
                _sectionTitle("Recent Updates"),
                ..._getRecentUpdates(category),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: SERVICES ---
  Widget _buildServicesTab(String category) {
    return CustomScrollView(
      slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFFF26522),
            title: const Text("Digital Services", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF26522), Color(0xFFFDB913)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Available for $category"),
                  const SizedBox(height: 10),

                  if (category == 'Student') ...[
                    _serviceCard(Icons.work, "Internship", "Find new opportunities", InternshipScreen(userData: widget.userData), context),
                    _serviceCard(Icons.school, "Scholarship", "Government grants", const ScholarshipScreen(), context),
                    _serviceCard(Icons.description, "Loan Form", "Education financing", EducationLoanForm(userData: widget.userData), context),
                    _statusCard("Loan Status", "Approved"),
                  ],

                  if (category == 'Business') ...[
                    _serviceCard(Icons.monetization_on, "Loan Form", "Expansion capital", BusinessLoanForm(userData: widget.userData), context),
                    _serviceCard(Icons.post_add, "Post Job", "Hire Students", PostJobScreen(userData: widget.userData), context),
                    _serviceCard(Icons.people, "Applicants", "View applied students", const ApplicantsScreen(), context),
                    _statusCard("Business Loan", "Pending"),
                  ],

                  if (category == 'Farmers') ...[
                    _serviceCard(Icons.request_quote, "Loan Form", "Kisan Credit", FarmerLoanForm(userData: widget.userData), context),
                    _serviceCard(Icons.add_a_photo, "Crop Registration", "Add Image, Name, Price", CropRegistrationScreen(userData: widget.userData), context),
                    _serviceCard(Icons.security, "Bima Yojana", "Crop Insurance", const BimaYojanaScreen(), context),
                    _serviceCard(Icons.account_balance_wallet, "Subsidy", "Govt Benefits", const SubsidyScreen(), context),
                  ],

                  if (category == 'Bank') ...[
                    // Extract ID safely
                    (() {
                      final rawId = widget.userData['id'];
                      final int bankId = rawId != null ? int.tryParse(rawId.toString()) ?? 0 : 0;
                      
                      return Column(
                        children: [
                          _serviceCard(
                            Icons.business,
                            "Business Loans",
                            "Review MSME applications",
                            AllLeadsScreen(currentBankUserId: bankId, filterType: "Job Posting"),
                            context,
                          ),
                          _serviceCard(
                            Icons.school,
                            "Student Loans",
                            "Education financing leads",
                            AllLeadsScreen(currentBankUserId: bankId, filterType: "Education Loan"),
                            context,
                          ),
                          _serviceCard(
                            Icons.agriculture,
                            "Farmer Loans",
                            "Kisan Credit applications",
                            AllLeadsScreen(currentBankUserId: bankId, filterType: "Farmer Loan"),
                            context,
                          ),
                          _serviceCard(
                            Icons.list_alt,
                            "All Leads",
                            "All incoming requests",
                            AllLeadsScreen(currentBankUserId: bankId),
                            context,
                          ),
                          _serviceCard(
                            Icons.check_circle,
                            "Accepted Leads",
                            "Approved loans",
                            AcceptedLeadsScreen(currentBankUserId: bankId),
                            context,
                          ),
                        ],
                      );
                    })(),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
  }

  // --- TAB 3: PROFILE ---
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF26522), Color(0xFFFDB913)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 50, color: Colors.white), 
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: IconButton(icon: const Icon(Icons.edit, color: Color(0xFFF26522), size: 20), onPressed: () {}),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(widget.userData['name'] ?? "User", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(widget.userData['email'] ?? "Email not provided", style: const TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text(widget.userData['category'] ?? "Category", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _profileMenuTile(Icons.person_outline, "Personal Details", "View and edit your profile", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalDetailsScreen(userData: widget.userData)));
                }),
                _profileMenuTile(Icons.settings_outlined, "Settings", "App preferences and notifications", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                }),
                _profileMenuTile(Icons.security, "Security", "Password and authentication", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityScreen()));
                }),
                _profileMenuTile(Icons.help_outline, "Help & Support", "FAQs and customer care", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
                }),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout", style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.shade100.withOpacity(0.2),
                      foregroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _profileMenuTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFF26522).withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFFF26522)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _quickActionCard(String title, IconData icon, Color color, String category) {
    return GestureDetector(
      onTap: () => _showDetailDialog(title, "Access services for $title here.", icon, color),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _promoCard(String title, String subtitle, MaterialColor color, IconData icon) {
    return GestureDetector(
      onTap: () => _showDetailDialog(title, subtitle, icon, color),
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.shade400, color.shade700], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Stack(
          children: [
            Positioned(right: -20, top: -20, child: Icon(icon, size: 120, color: Colors.white.withOpacity(0.15))),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const Spacer(),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String subtitle, Color iconColor) {
    return GestureDetector(
      onTap: () => _showDetailDialog(title, subtitle, icon, iconColor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.3)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle), child: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFF26522))),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStat(String count, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFF26522), size: 28),
        const SizedBox(height: 8),
        FittedBox(fit: BoxFit.scaleDown, child: Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87))),
        const SizedBox(height: 4),
        FittedBox(fit: BoxFit.scaleDown, child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildModernDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade300);
  }

  void _showDetailDialog(String title, String subtitle, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 35, backgroundColor: color.withOpacity(0.15), child: Icon(icon, size: 40, color: color)),
                const SizedBox(height: 20),
                Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                  child: const Text("Detailed info preview. Comprehensive data fetched from backend.", style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF26522), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text("Got it", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.5)),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Viewing all for "$title"...'), behavior: SnackBarBehavior.floating));
            },
            child: const Text("See All", style: TextStyle(fontSize: 14, color: Color(0xFFF26522), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _serviceCard(IconData icon, String title, String sub, Widget destination, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF26522).withOpacity(0.12), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: const Color(0xFFF26522), size: 28)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)), const SizedBox(height: 4), Text(sub, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.2))])),
            const SizedBox(width: 10),
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle), child: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFF26522))),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(String title, String status) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green.shade400, Colors.green.shade700], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.verified, color: Colors.white, size: 24)), const SizedBox(width: 12), Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text(status.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12))),
        ],
      ),
    );
  }

  // --- DASHBOARD HELPERS ---
  List<Widget> _getQuickActions(String category) {
    if (category == 'Student') {
      return [
        _quickActionCard("Scholarships", Icons.school, Colors.blue, category),
        _quickActionCard("Internships", Icons.work, Colors.orange, category),
        _quickActionCard("E-Books", Icons.menu_book, Colors.green, category),
        _quickActionCard("Skill Test", Icons.psychology, Colors.purple, category),
      ];
    } else if (category == 'Business') {
      return [
        _quickActionCard("MSME Loans", Icons.monetization_on, Colors.teal, category),
        _quickActionCard("GST Portal", Icons.receipt_long, Colors.indigo, category),
        _quickActionCard("Hiring", Icons.person_add, Colors.amber, category),
        _quickActionCard("Market", Icons.analytics, Colors.deepOrange, category),
      ];
    } else if (category == 'Farmers') {
      return [
        _quickActionCard("Mandi Price", Icons.trending_up, Colors.green, category),
        _quickActionCard("Weather", Icons.wb_sunny, Colors.blue, category),
        _quickActionCard("Equipment", Icons.agriculture, Colors.brown, category),
        _quickActionCard("Insurance", Icons.security, Colors.red, category),
      ];
    } else if (category == 'Bank') {
      return [
        _quickActionCard("All Leads", Icons.list_alt, Colors.blue, category),
        _quickActionCard("Verification", Icons.verified_user, Colors.green, category),
        _quickActionCard("Guidelines", Icons.gavel, Colors.purple, category),
        _quickActionCard("Reports", Icons.assessment, Colors.orange, category),
      ];
    }
    return [
       _quickActionCard("Profile", Icons.person, Colors.blue, category),
       _quickActionCard("Settings", Icons.settings, Colors.grey, category),
       _quickActionCard("Support", Icons.help, Colors.orange, category),
       _quickActionCard("Policy", Icons.description, Colors.teal, category),
    ];
  }

  List<Widget> _getRecentUpdates(String category) {
    if (category == 'Student') {
      return [
        _infoCard(Icons.campaign, "UPSC Application", "New notification for UPSC Prelims 2026 is out.", Colors.red),
        _infoCard(Icons.star, "New Internship", "Google is hiring Summer Interns for 2026.", Colors.blue),
      ];
    } else if (category == 'Business') {
      return [
        _infoCard(Icons.notification_important, "GST Filing", "Monthly GST filing deadline is approaching.", Colors.orange),
        _infoCard(Icons.rocket_launch, "StartUp Expo", "Join the upcoming Startup India Expo in Delhi.", Colors.purple),
      ];
    } else if (category == 'Farmers') {
      return [
        _infoCard(Icons.cloud_sync, "Heavy Rain Alert", "Isolated heavy rainfall expected in your region.", Colors.blue),
        _infoCard(Icons.check_circle, "Subsidy Approved", "Your tractor subsidy application has been approved.", Colors.green),
      ];
    } else if (category == 'Bank') {
      return [
        _infoCard(Icons.warning_amber, "RBI Guideline", "New circular regarding digital lending security.", Colors.red),
        _infoCard(Icons.people, "New Lead", "5 new loan applications pending for your branch.", Colors.blue),
      ];
    }
    return [
      _infoCard(Icons.info_outline, "Welcome", "Welcome to the Digital Registration Portal.", Colors.blue),
    ];
  }
}
