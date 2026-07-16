import 'package:flutter/material.dart';
import 'package:the_digital_registration/views/service_forms.dart';
import 'package:the_digital_registration/views/student_forms.dart';
import 'package:the_digital_registration/constants/home_images.dart';
import 'package:the_digital_registration/widgets/app_asset_image.dart';
import 'package:the_digital_registration/widgets/home_featured_strip.dart';
import 'package:the_digital_registration/widgets/home_hero_carousel.dart';
import 'package:the_digital_registration/widgets/responsive_layout.dart';
import 'login_screen.dart';
import 'personal_details_screen.dart';
import 'settings_screen.dart';
import 'security_screen.dart';
import 'help_support_screen.dart';
import 'partner_wallet_screen.dart';
import 'quick_content_screens.dart';
import 'ai_graphics_screen.dart';
import 'job_seeker/available_jobs_screen.dart';
import 'job_seeker/my_applications_screen.dart';
import 'job_seeker/resume_builder_screen.dart';
import 'job_seeker/interview_prep_screen.dart';
import 'edit_profile_screen.dart';
import 'my_loans_screen.dart';
import '../constants/lead_category.dart';
import '../constants/registration_plan.dart';
import '../theme/app_theme.dart';
import '../services/auth_session.dart';
import '../services/wallet_balance_resolver.dart';
import '../utils/user_profile_helpers.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const DashboardScreen({super.key, required this.userData});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  double? _profileWalletBalance;

  int _parsedUserId() {
    final rawId = widget.userData['id'];
    return rawId != null ? int.tryParse(rawId.toString()) ?? 0 : 0;
  }

  String _normalizeCategory(String? raw) {
    final c = (raw ?? 'User').trim();
    switch (c.toLowerCase()) {
      case 'farmers':
      case 'farmer':
        return 'Farmers';
      case 'business':
        return 'Business';
      case 'bank':
        return 'Bank';
      case 'student':
      case 'students':
        return 'Student';
      default:
        return c;
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshProfileWalletBalance();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final path in [
        HomeImages.banner,
        HomeImages.carouselServices,
        HomeImages.carouselIndia,
        HomeImages.digital,
        HomeImages.security,
        HomeImages.skills,
        HomeImages.business,
        HomeImages.services,
        HomeImages.workspace,
      ]) {
        precacheImage(AssetImage(path), context);
      }
    });
  }

  Future<void> _refreshProfileWalletBalance() async {
    final user = await AuthSession.load() ?? widget.userData;
    final balance = await WalletBalanceResolver.resolveAndPersist(user);
    if (mounted) setState(() => _profileWalletBalance = balance);
  }

  void _onNavIndexChanged(int index) {
    setState(() => _selectedIndex = index);
    if (index == 2) _refreshProfileWalletBalance();
  }

  @override
  Widget build(BuildContext context) {
    String category = _normalizeCategory(widget.userData['category']?.toString());

    final List<Widget> pages = [
      _buildHomeTab(category),
      _buildServicesTab(category),
      _buildProfileTab(),
    ];

    final desktop = Responsive.isDesktop(context);

    if (desktop) {
      final userName = _stringValue(widget.userData['name'], fallback: 'User');
      final category = widget.userData['category']?.toString() ?? 'User';
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DesktopSideNavigation(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onNavIndexChanged,
              userName: userName,
              userCategory: category,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.dashboardPanelMaxWidth(context),
                  ),
                  child: pages[_selectedIndex],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
        onTap: _onNavIndexChanged,
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
    final userName = _stringValue(widget.userData['name'], fallback: 'User');
    final profileCompletion = _profileCompletionPercent(widget.userData);
    final primaryInfo = _primaryInfoByCategory(category, widget.userData);
    final secondaryInfo = _secondaryInfoByCategory(category, widget.userData);
    final district = _stringValue(widget.userData['district'], fallback: '--');
    final state = _stringValue(widget.userData['state'], fallback: '--');

    final desktop = Responsive.isDesktop(context);

    final statsCard = Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModernStat(
              "${profileCompletion.toInt()}%",
              "Profile",
              Icons.account_circle_outlined,
            ),
          ),
          _buildModernDivider(),
          Expanded(
            child: _buildModernStat(
              district == '--' && state == '--'
                  ? '--'
                  : "$district, $state",
              "Location",
              Icons.location_on_outlined,
            ),
          ),
          _buildModernDivider(),
          Expanded(
            child: _buildModernStat(
              primaryInfo,
              secondaryInfo,
              _categoryIcon(category),
            ),
          ),
        ],
      ),
    );

    return SingleChildScrollView(
      child: ResponsiveContent(
        padding: EdgeInsets.fromLTRB(
          Responsive.horizontalPadding(context),
          desktop ? 16 : 0,
          Responsive.horizontalPadding(context),
          32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHomeHero(context, category, userName),
            const SizedBox(height: 16),
            statsCard,
            const SizedBox(height: 20),
            _buildFeaturedStrip(category),
            const SizedBox(height: 24),
            _sectionTitle(
              "Highlights",
              onSeeAll: () => _openHighlightsSeeAll(),
            ),
            const SizedBox(height: 12),
            desktop
                    ? IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _promoCard(
                                "Digital Rupee",
                                "Experience the new e-Rupee today",
                                Colors.deepPurple,
                                Icons.currency_rupee,
                                imageAsset: HomeImages.digital,
                                expand: true,
                                detailBullets: const [
                                  'CBDC pilot (e₹) is bank-issued digital currency, not crypto.',
                                  'Use only official bank apps listed on RBI’s website.',
                                  'Verify merchant UPI IDs before high-value transfers.',
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _promoCard(
                                "Cyber Security",
                                "Stay safe from online frauds",
                                Colors.blue,
                                Icons.security,
                                imageAsset: HomeImages.security,
                                expand: true,
                                detailBullets: const [
                                  'Never share OTPs or card CVV over phone or chat.',
                                  'Enable transaction alerts on your bank account.',
                                  'Report suspicious SMS to your operator’s spam line.',
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _promoCard(
                                "Skill India",
                                "Free courses for youth",
                                Colors.teal,
                                Icons.school,
                                imageAsset: HomeImages.skills,
                                expand: true,
                                detailBullets: const [
                                  'Short-term NSDC-aligned courses improve employability.',
                                  'Pair courses with internships from the Services tab.',
                                  'Keep certificates ready for employer verification.',
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 160,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          children: [
                            _promoCard(
                              "Digital Rupee",
                              "Experience the new e-Rupee today",
                              Colors.deepPurple,
                              Icons.currency_rupee,
                              imageAsset: HomeImages.digital,
                              detailBullets: const [
                                'CBDC pilot (e₹) is bank-issued digital currency, not crypto.',
                                'Use only official bank apps listed on RBI’s website.',
                                'Verify merchant UPI IDs before high-value transfers.',
                              ],
                            ),
                            _promoCard(
                              "Cyber Security",
                              "Stay safe from online frauds",
                              Colors.blue,
                              Icons.security,
                              imageAsset: HomeImages.security,
                              detailBullets: const [
                                'Never share OTPs or card CVV over phone or chat.',
                                'Enable transaction alerts on your bank account.',
                                'Report suspicious SMS to your operator’s spam line.',
                              ],
                            ),
                            _promoCard(
                              "Skill India",
                              "Free courses for youth",
                              Colors.teal,
                              Icons.school,
                              imageAsset: HomeImages.skills,
                              detailBullets: const [
                                'Short-term NSDC-aligned courses improve employability.',
                                'Pair courses with internships from the Services tab.',
                                'Keep certificates ready for employer verification.',
                              ],
                            ),
                          ],
                        ),
                      ),
            const SizedBox(height: 28),
            _sectionTitle(
              "Quick Actions",
              onSeeAll: () => setState(() => _selectedIndex = 1),
            ),
            const SizedBox(height: 12),
            ResponsiveActionGrid(
              children: _getQuickActions(category),
            ),
            const SizedBox(height: 24),
            _sectionTitle(
              "Category Insights",
              onSeeAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => responsiveListScaffold(
                      context,
                      title: 'Category insights',
                      children: _getCategoryInsights(
                        category,
                        widget.userData,
                      ),
                    ),
                  ),
                );
              },
            ),
            ..._getCategoryInsights(category, widget.userData),
            _sectionTitle(
              "Recent Updates",
              onSeeAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => responsiveListScaffold(
                      context,
                      title: 'Recent updates',
                      children: _getRecentUpdates(
                        category,
                        widget.userData,
                      ),
                    ),
                  ),
                );
              },
            ),
            ..._getRecentUpdates(category, widget.userData),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: SERVICES ---
  Widget _buildServicesTab(String category) {
    final desktop = Responsive.isDesktop(context);
    return ResponsivePage(
      child: CustomScrollView(
      slivers: [
        if (desktop)
          SliverToBoxAdapter(
            child: ResponsiveContent(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: DesktopPageHeader(
                title: 'Digital Services',
                subtitle: 'Tools and applications for $category accounts',
              ),
            ),
          )
        else
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF2196F3),
            title: const Text(
              "Digital Services",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1E88E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: ResponsiveContent(
            padding: EdgeInsets.all(desktop ? 24 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('AI Studio', showSeeAll: false),
                const SizedBox(height: 10),
                _buildServiceSection(
                  context,
                  [
                    _serviceCard(
                      Icons.auto_awesome,
                      'AI Graphics',
                      'Generate banners & posters',
                      AiGraphicsScreen(userData: widget.userData),
                      context,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (!desktop)
                  _sectionTitle("Available for $category", showSeeAll: false),
                if (!desktop) const SizedBox(height: 10),
                _buildServiceSection(
                  context,
                  category != null && category.startsWith('Student')
                      ? [
                          _serviceCard(
                            Icons.how_to_reg,
                            "Admission Forms",
                            "Apply for college admissions",
                            AdmissionFormScreen(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.account_balance_wallet_outlined,
                            "Scholarship Forms",
                            "Apply for scholarships",
                            ScholarshipFormScreen(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.work,
                            "Internship Applications",
                            "Apply for internships",
                            InternshipFormScreen(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.business_center,
                            "Job Application Forms",
                            "Apply for student jobs",
                            JobApplicationFormScreen(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.laptop_mac,
                            "Digital Learning",
                            "SWAYAM, NPTEL & more",
                            const DigitalLearningPlatformsScreen(),
                            context,
                          ),
                          _serviceCard(
                            Icons.verified,
                            "Online Certificates",
                            "DigiLocker & course credentials",
                            OnlineCertificatesScreen(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.description,
                            "Loan Form",
                            "Education financing",
                            EducationLoanForm(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.account_balance,
                            "My Student Loans",
                            "Track education applications",
                            MyLoansScreen(
                              userId: _parsedUserId(),
                              category: LeadCategory.student,
                            ),
                            context,
                          ),
                          _serviceCard(
                            Icons.health_and_safety,
                            "Health Insurance",
                            "Apply for health cover",
                            HealthInsuranceForm(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.directions_car,
                            "Motor Insurance",
                            "Insure your vehicle",
                            MotorInsuranceForm(userData: widget.userData),
                            context,
                          ),
                        ]
                      : category != null && category.startsWith('Business')
                      ? [
                          _serviceCard(
                            Icons.receipt_long,
                            "GST Registration",
                            "Apply for new GSTIN",
                            GstRegistrationScreen(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.storefront,
                            "MSME / Udyam",
                            "Register & get benefits",
                            MsmeRegistrationScreen(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.store,
                            "Shop Act Licence",
                            "State shop establishment",
                            ShopActLicenseScreen(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.business,
                            "Company / Firm",
                            "MCA incorporation",
                            CompanyFirmRegistrationScreen(
                              userData: widget.userData,
                            ),
                            context,
                          ),
                          _serviceCard(
                            Icons.campaign,
                            "Digital Marketing",
                            "Ad campaigns & SEO support",
                            DigitalMarketingSupportScreen(
                              userData: widget.userData,
                            ),
                            context,
                          ),
                          _serviceCard(
                            Icons.monetization_on,
                            "Loan Form",
                            "Expansion capital",
                            BusinessLoanForm(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.post_add,
                            "Post Job",
                            "Hire Students",
                            PostJobScreen(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.work_history,
                            "My Jobs",
                            "Review posted jobs",
                            MyJobsScreen(userId: int.tryParse(widget.userData['id']?.toString() ?? '0') ?? 0),
                            context,
                          ),
                          _serviceCard(
                            Icons.people,
                            "Applicants",
                            "View applied students",
                            ApplicantsScreen(userId: int.tryParse(widget.userData['id']?.toString() ?? '0') ?? 0),
                            context,
                          ),
                          _serviceCard(
                            Icons.account_balance,
                            "My Business Loans",
                            "Track MSME applications",
                            MyLoansScreen(
                              userId: _parsedUserId(),
                              category: LeadCategory.business,
                            ),
                            context,
                          ),
                          _serviceCard(
                            Icons.health_and_safety,
                            "Health Insurance",
                            "Apply for health cover",
                            HealthInsuranceForm(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.directions_car,
                            "Motor Insurance",
                            "Insure your vehicle",
                            MotorInsuranceForm(userData: widget.userData),
                            context,
                          ),
                        ]
                      : (category != null && category.startsWith('Job Seeker'))
                      ? [
                          _serviceCard(
                            Icons.work_outline,
                            category == 'Job Seeker - Internship' ? "Find Internships" : "Find Jobs",
                            "Browse opportunities",
                            AvailableJobsScreen(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.check_circle_outline,
                            category == 'Job Seeker - Internship' ? "Track internship status" : "Track job status",
                            category == 'Job Seeker - Internship' ? "Track internship status" : "Track job status",
                            MyApplicationsScreen(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.description,
                            "Resume Builder",
                            "Create digital CV",
                            ResumeBuilderScreen(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.health_and_safety,
                            "Health Insurance",
                            "Apply for health cover",
                            HealthInsuranceForm(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.directions_car,
                            "Motor Insurance",
                            "Insure your vehicle",
                            MotorInsuranceForm(userData: widget.userData),
                            context,
                          ),
                        ]
                      : category == 'Farmers'
                      ? [
                          _serviceCard(
                            Icons.request_quote,
                            "Loan Form",
                            "Kisan Credit",
                            FarmerLoanForm(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.add_a_photo,
                            "Crop Registration",
                            "Add Image, Name, Price",
                            CropRegistrationScreen(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.security,
                            "Bima Yojana",
                            "Crop Insurance",
                            BimaYojanaScreen(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.account_balance_wallet,
                            "Subsidy",
                            "Govt Benefits",
                            SubsidyScreen(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.agriculture,
                            "My Farmer Loans",
                            "From farmer_loans table",
                            MyLoansScreen(
                              userId: _parsedUserId(),
                              category: LeadCategory.farmer,
                            ),
                            context,
                          ),
                          _serviceCard(
                            Icons.health_and_safety,
                            "Health Insurance",
                            "Apply for health cover",
                            HealthInsuranceForm(userData: widget.userData),
                            context,
                          ),
                          _serviceCard(
                            Icons.directions_car,
                            "Motor Insurance",
                            "Insure your vehicle",
                            MotorInsuranceForm(userData: widget.userData),
                            context,
                          ),
                        ]
                      : (category == 'Bank' || category == 'Banking / Financial Services')
                      ? (() {
                          final rawId = widget.userData['id'];
                          final int bankId = rawId != null
                              ? int.tryParse(rawId.toString()) ?? 0
                              : 0;
                          return [
                            _serviceCard(
                              Icons.business,
                              "Business Loans",
                              "Review MSME applications",
                              AllLeadsScreen(
                                currentBankUserId: bankId,
                                category: LeadCategory.business,
                              ),
                              context,
                            ),
                            _serviceCard(
                              Icons.school,
                              "Student Loans",
                              "Education financing leads",
                              AllLeadsScreen(
                                currentBankUserId: bankId,
                                category: LeadCategory.student,
                              ),
                              context,
                            ),
                            _serviceCard(
                              Icons.agriculture,
                              "Farmer Loans",
                              "Kisan Credit applications",
                              AllLeadsScreen(
                                currentBankUserId: bankId,
                                category: LeadCategory.farmer,
                              ),
                              context,
                            ),
                            _serviceCard(
                              Icons.check_circle,
                              "Accepted Leads",
                              "Approved loans",
                              AcceptedLeadsScreen(currentBankUserId: bankId),
                              context,
                            ),
                            _serviceCard(
                              Icons.account_balance,
                              "Online Banking",
                              "Apply for internet banking",
                              OnlineBankingScreen(userData: widget.userData),
                              context,
                            ),
                            _serviceCard(
                              Icons.qr_code_scanner,
                              "UPI Payments",
                              "Register UPI merchant",
                              UpiPaymentScreen(userData: widget.userData),
                              context,
                            ),
                            _serviceCard(
                              Icons.sync_alt,
                              "Direct Benefit Transfer",
                              "Link Aadhaar for DBT",
                              DirectBenefitTransferScreen(userData: widget.userData),
                              context,
                            ),
                            _serviceCard(
                              Icons.people_outline,
                              "Jan Dhan Yojna",
                              "Open zero-balance account",
                              JanDhanYojnaScreen(userData: widget.userData),
                              context,
                            ),
                            _serviceCard(
                              Icons.health_and_safety,
                              "Health Insurance",
                              "Apply for health cover",
                              HealthInsuranceForm(userData: widget.userData),
                              context,
                            ),
                            _serviceCard(
                              Icons.directions_car,
                              "Motor Insurance",
                              "Insure your vehicle",
                              MotorInsuranceForm(userData: widget.userData),
                              context,
                            ),
                          ];
                        })()
                      : <Widget>[],
                ),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildServiceSection(BuildContext context, List<Widget> cards) {
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }
    if (Responsive.isDesktop(context)) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final crossAxisCount = w >= 1100 ? 3 : (w >= 700 ? 2 : 1);
          return GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: crossAxisCount >= 3 ? 3.2 : (crossAxisCount == 2 ? 3.6 : 4.2),
            children: cards,
          );
        },
      );
    }
    return Column(children: cards);
  }

  // --- TAB 3: PROFILE ---
  Widget _buildProfileTab() {
    final desktop = Responsive.isDesktop(context);

    final profileHeader = Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: desktop ? 40 : 60,
        bottom: desktop ? 28 : 30,
        left: desktop ? 32 : 0,
        right: desktop ? 32 : 0,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: desktop
            ? BorderRadius.circular(24)
            : const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
        boxShadow: desktop
            ? [
                BoxShadow(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF2196F3), size: 20),
                  onPressed: () async {
                    final updatedData = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(userData: widget.userData),
                      ),
                    );
                    if (updatedData != null && updatedData is Map<String, dynamic>) {
                      setState(() {
                        updatedData.forEach((key, value) {
                          widget.userData[key] = value;
                        });
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            widget.userData['name'] ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            widget.userData['email'] ?? 'Email not provided',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.userData['category'] ?? 'Category',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    final menuColumn = Column(
      children: [
        _profileWalletBanner(),
        _profileMenuTile(
          Icons.person_outline,
          'Personal Details',
          'View and edit your profile',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PersonalDetailsScreen(userData: widget.userData),
              ),
            );
          },
        ),
        _profileMenuTile(
          Icons.settings_outlined,
          'Settings',
          'App preferences and notifications',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
        _profileMenuTile(
          Icons.security,
          'Security',
          'Password and authentication',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SecurityScreen()),
            );
          },
        ),
        _profileMenuTile(
          Icons.help_outline,
          'Help & Support',
          'FAQs and customer care',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
            );
          },
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await AuthSession.clear();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade100.withValues(alpha: 0.2),
              foregroundColor: Colors.red,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );

    return SingleChildScrollView(
      child: ResponsiveContent(
        padding: EdgeInsets.fromLTRB(
          Responsive.horizontalPadding(context),
          desktop ? 24 : 0,
          Responsive.horizontalPadding(context),
          Responsive.horizontalPadding(context),
        ),
        child: desktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: profileHeader),
                  const SizedBox(width: 24),
                  Expanded(flex: 3, child: menuColumn),
                ],
              )
            : Column(
                children: [
                  profileHeader,
                  const SizedBox(height: 20),
                  menuColumn,
                ],
              ),
      ),
    );
  }

  // --- HELPERS ---

  Future<void> _openWallet() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PartnerWalletScreen(userData: widget.userData),
      ),
    );
    _refreshProfileWalletBalance();
  }

  Widget _profileWalletBanner() {
    final user = UserProfileHelpers.normalize(
      Map<String, dynamic>.from(widget.userData),
    );
    final balance = _profileWalletBalance ?? UserProfileHelpers.walletBalance(user);
    final partnerCode = UserProfileHelpers.displayPartnerCode(user);
    return Material(
      color: const Color(0xFF2196F3),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _openWallet,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Wallet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      partnerCode != null
                          ? 'Balance ₹${balance.toStringAsFixed(2)} · Your code $partnerCode'
                          : 'Balance ₹${balance.toStringAsFixed(2)} · Tap to open',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileMenuTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF2196F3)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _quickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _promoCard(
    String title,
    String subtitle,
    MaterialColor color,
    IconData icon, {
    String? imageAsset,
    List<String>? detailBullets,
    bool expand = false,
  }) {
    return GestureDetector(
      onTap: () => _showDetailDialog(
        title,
        subtitle,
        icon,
        color,
        bullets: detailBullets,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: expand ? null : 260,
          height: expand ? 168 : null,
          margin: expand ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageAsset != null)
                AppAssetImage(
                  asset: imageAsset,
                  expand: true,
                  errorBuilder: (_, __, ___) =>
                      ColoredBox(color: color.shade600),
                ),
              if (imageAsset != null)
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        color.shade900.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                )
              else
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.shade400, color.shade700],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(icon, color: Colors.white, size: 26),
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(
    IconData icon,
    String title,
    String subtitle,
    Color iconColor, {
    String? imageAsset,
    List<String>? detailBullets,
  }) {
    return GestureDetector(
      onTap: () => _showDetailDialog(
        title,
        subtitle,
        icon,
        iconColor,
        bullets: detailBullets,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: imageAsset != null
                    ? AppAssetImage(
                        asset: imageAsset,
                        width: 72,
                        height: 72,
                        errorBuilder: (_, __, ___) => ColoredBox(
                          color: iconColor.withValues(alpha: 0.12),
                          child: Icon(icon, color: iconColor, size: 28),
                        ),
                      )
                    : ColoredBox(
                        color: iconColor.withValues(alpha: 0.12),
                        child: Icon(icon, color: iconColor, size: 28),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStat(String count, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 24),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            count,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade200);
  }

  Widget _buildHomeHero(
    BuildContext context,
    String category,
    String userName,
  ) {
    final user = UserProfileHelpers.normalize(
      Map<String, dynamic>.from(widget.userData),
    );
    final isPartner = UserProfileHelpers.isPartner(user);
    final cashback = RegistrationPlan.cashbackForNormalRegistration();
    final desktop = Responsive.isDesktop(context);
    final openServices = () => setState(() => _selectedIndex = 1);

    return HomeHeroCarousel(
      height: desktop ? 280 : 200,
      slides: [
        HomeCarouselSlide(
          imageAsset: category != null && category.startsWith('Business') ? HomeImages.businessBanner : ((category != null && category.startsWith('Student')) ? HomeImages.studentBanner : (category == 'Farmers' ? HomeImages.farmerBanner : ((category == 'Bank' || category == 'Banking / Financial Services') ? HomeImages.bankBanner : HomeImages.banner))),
          badge: isPartner ? 'PARTNER PROGRAM' : '$category Portal',
          title: isPartner
              ? 'Earn ₹${cashback.toStringAsFixed(0)} on every referral'
              : 'Welcome back, $userName',
          subtitle: isPartner
              ? 'Share your partner code — earn when others register (₹${RegistrationPlan.normalFeeInr}).'
              : 'Loans, crop registration, internships & more in one place.',
          ctaLabel: isPartner ? 'Open My Wallet' : 'Explore Services',
          onCtaTap: isPartner ? _openWallet : openServices,
        ),
        HomeCarouselSlide(
          imageAsset: HomeImages.carouselServices,
          title: 'Grow with digital services',
          subtitle: 'Loans, GST, hiring & market tools in one portal.',
          ctaLabel: 'View services',
          onCtaTap: openServices,
        ),
        HomeCarouselSlide(
          imageAsset: HomeImages.carouselIndia,
          title: 'Your $category dashboard',
          subtitle: 'Track profile, insights and updates in real time.',
          ctaLabel: 'Go to profile',
          onCtaTap: () => setState(() => _selectedIndex = 2),
        ),
      ],
    );
  }

  Widget _buildFeaturedStrip(String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('Featured', showSeeAll: false),
        const SizedBox(height: 10),
        HomeFeaturedStrip(
          items: category != null && category.startsWith('Business')
              ? [
                  FeaturedImageItem(
                    label: 'GST Registration',
                    imageAsset: HomeImages.businessGst,
                    onTap: () => _handleQuickAction(category, "GST Registration"),
                  ),
                  FeaturedImageItem(
                    label: 'Business Loans',
                    imageAsset: HomeImages.businessLoans,
                    onTap: () => _handleQuickAction(category, "MSME Loans"),
                  ),
                  FeaturedImageItem(
                    label: 'Hiring & Jobs',
                    imageAsset: HomeImages.businessHiring,
                    onTap: () => _handleQuickAction(category, "Hiring"),
                  ),
                ]
              : category == 'Farmers'
                  ? [
                      FeaturedImageItem(
                        label: 'Digital Services',
                        imageAsset: HomeImages.farmerFeat1,
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                      FeaturedImageItem(
                        label: 'Farmers Hub',
                        imageAsset: HomeImages.farmerFeat2,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MarketScreen(),
                            ),
                          );
                        },
                      ),
                      FeaturedImageItem(
                        label: 'Your Workspace',
                        imageAsset: HomeImages.farmerFeat3,
                        onTap: () => setState(() => _selectedIndex = 2),
                      ),
                      FeaturedImageItem(
                        label: 'Skill Programs',
                        imageAsset: HomeImages.farmerFeat4,
                        onTap: () => _openHighlightsSeeAll(),
                      ),
                    ]
                  : (category == 'Bank' || category == 'Banking / Financial Services')
                  ? [
                      FeaturedImageItem(
                        label: 'Digital Services',
                        imageAsset: HomeImages.bankFeat1,
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                      FeaturedImageItem(
                        label: 'Bank Hub',
                        imageAsset: HomeImages.bankFeat2,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OnlineBankingScreen(userData: widget.userData),
                            ),
                          );
                        },
                      ),
                      FeaturedImageItem(
                        label: 'Your Workspace',
                        imageAsset: HomeImages.bankFeat3,
                        onTap: () => setState(() => _selectedIndex = 2),
                      ),
                      FeaturedImageItem(
                        label: 'Skill Programs',
                        imageAsset: HomeImages.bankFeat4,
                        onTap: () => _openHighlightsSeeAll(),
                      ),
                    ]
                  : [
                      FeaturedImageItem(
                        label: 'Digital Services',
                        imageAsset: HomeImages.services,
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                      FeaturedImageItem(
                        label: '$category Hub',
                        imageAsset: HomeImages.business,
                        onTap: () {
                          if (category != null && category.startsWith('Job Seeker')) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AvailableJobsScreen(userData: widget.userData),
                          ),
                        );
                      } else if ((category == 'Bank' || category == 'Banking / Financial Services') || category == 'Banker') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OnlineBankingScreen(userData: widget.userData),
                          ),
                        );
                      } else if (category == 'Farmers') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MarketScreen(),
                          ),
                        );
                      } else {
                        setState(() => _selectedIndex = 1);
                      }
                    },
                  ),
                  FeaturedImageItem(
                    label: 'Your Workspace',
                    imageAsset: HomeImages.workspace,
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                  FeaturedImageItem(
                    label: 'Skill Programs',
                    imageAsset: HomeImages.skills,
                    onTap: () => _openHighlightsSeeAll(),
                  ),
                ],
        ),
      ],
    );
  }

  void _showDetailDialog(
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    List<String>? bullets,
  }) {
    final desktop = Responsive.isDesktop(context);
    ResponsiveDialog.show(
      context,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.4,
              ),
            ),
            if (bullets != null && bullets.isNotEmpty) ...[
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: bullets
                      .map(
                        (b) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '• ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF2196F3),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  b,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.35,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: desktop ? 180 : double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title, {
    VoidCallback? onSeeAll,
    bool showSeeAll = true,
  }) {
    final effectiveSeeAll = showSeeAll ? onSeeAll : null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (effectiveSeeAll != null)
          TextButton(
            onPressed: effectiveSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primary,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'See all',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  void _openHighlightsSeeAll() {
    final desktop = Responsive.isDesktop(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: !desktop,
      constraints: desktop
          ? const BoxConstraints(maxWidth: 560)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(desktop ? 20 : 16),
          bottom: Radius.circular(desktop ? 20 : 0),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Highlights',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap an item for details',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    child: const Icon(Icons.currency_rupee, color: Colors.deepPurple),
                  ),
                  title: const Text('Digital Rupee'),
                  subtitle: const Text('Experience the new e-Rupee today'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showDetailDialog(
                      'Digital Rupee',
                      'Experience the new e-Rupee today',
                      Icons.currency_rupee,
                      Colors.deepPurple,
                      bullets: const [
                        'CBDC pilot (e₹) is bank-issued digital currency, not crypto.',
                        'Use only official bank apps listed on RBI’s website.',
                        'Verify merchant UPI IDs before high-value transfers.',
                      ],
                    );
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.security, color: Colors.blue),
                  ),
                  title: const Text('Cyber Security'),
                  subtitle: const Text('Stay safe from online frauds'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showDetailDialog(
                      'Cyber Security',
                      'Stay safe from online frauds',
                      Icons.security,
                      Colors.blue,
                      bullets: const [
                        'Never share OTPs or card CVV over phone or chat.',
                        'Enable transaction alerts on your bank account.',
                        'Report suspicious SMS to your operator’s spam line.',
                      ],
                    );
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: const Icon(Icons.school, color: Colors.teal),
                  ),
                  title: const Text('Skill India'),
                  subtitle: const Text('Free courses for youth'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showDetailDialog(
                      'Skill India',
                      'Free courses for youth',
                      Icons.school,
                      Colors.teal,
                      bullets: const [
                        'Short-term NSDC-aligned courses improve employability.',
                        'Pair courses with internships from the Services tab.',
                        'Keep certificates ready for employer verification.',
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _serviceCard(
    IconData icon,
    String title,
    String sub,
    Widget destination,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFF2196F3), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Color(0xFF2196F3),
              ),
            ),
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
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- DASHBOARD HELPERS ---
  List<Widget> _getQuickActions(String category) {
    List<Widget> actions = [];
    if (category != null && category.startsWith('Job Seeker')) {
      final isInternship = category == 'Job Seeker - Internship';
      actions.addAll([
        _quickActionCard(
          isInternship ? "Find Internships" : "Find Jobs",
          Icons.search,
          Colors.blue,
          () => _handleQuickAction(category, isInternship ? "Find Internships" : "Find Jobs"),
        ),
        _quickActionCard(
          "My Applications",
          Icons.history,
          Colors.orange,
          () => _handleQuickAction(category, "My Applications"),
        ),
        _quickActionCard(
          "Resume Builder",
          Icons.description,
          Colors.green,
          () => _handleQuickAction(category, "Resume Builder"),
        ),
        _quickActionCard(
          "Interview Prep",
          Icons.lightbulb,
          Colors.purple,
          () => _handleQuickAction(category, "Interview Prep"),
        ),
      ]);
    }
    if (category != null && category.startsWith('Student')) {
      actions.addAll([
        _quickActionCard(
          "Online Admission",
          Icons.how_to_reg,
          Colors.indigo,
          () => _handleQuickAction(category, "Online Admission"),
        ),
        _quickActionCard(
          "Scholarship Portal",
          Icons.account_balance_wallet_outlined,
          Colors.blue,
          () => _handleQuickAction(category, "Scholarship Portal"),
        ),
        _quickActionCard(
          "Digital Learning",
          Icons.laptop_mac,
          Colors.teal,
          () => _handleQuickAction(category, "Digital Learning"),
        ),
        _quickActionCard(
          "Certificates",
          Icons.verified,
          Colors.green,
          () => _handleQuickAction(category, "Certificates"),
        ),
        _quickActionCard(
          "Internships",
          Icons.work,
          Colors.orange,
          () => _handleQuickAction(category, "Internships"),
        ),
        _quickActionCard(
          "E-Books",
          Icons.menu_book,
          Colors.brown,
          () => _handleQuickAction(category, "E-Books"),
        ),
        _quickActionCard(
          "Skill Test",
          Icons.psychology,
          Colors.purple,
          () => _handleQuickAction(category, "Skill Test"),
        ),
        _quickActionCard(
          "Education Loan",
          Icons.description,
          Colors.deepOrange,
          () => _handleQuickAction(category, "Education Loan"),
        ),
      ]);
    } else if (category != null && category.startsWith('Business')) {
      actions.addAll([
        _quickActionCard(
          "GST Registration",
          Icons.receipt_long,
          Colors.indigo,
          () => _handleQuickAction(category, "GST Registration"),
        ),
        _quickActionCard(
          "MSME / Udyam",
          Icons.storefront,
          Colors.teal,
          () => _handleQuickAction(category, "MSME"),
        ),
        _quickActionCard(
          "Shop Act",
          Icons.store,
          Colors.brown,
          () => _handleQuickAction(category, "Shop Act"),
        ),
        _quickActionCard(
          "Company / Firm",
          Icons.business,
          Colors.blue,
          () => _handleQuickAction(category, "Company Firm"),
        ),
        _quickActionCard(
          "MSME Loans",
          Icons.monetization_on,
          Colors.deepOrange,
          () => _handleQuickAction(category, "MSME Loans"),
        ),
        _quickActionCard(
          "Hiring",
          Icons.person_add,
          Colors.amber,
          () => _handleQuickAction(category, "Hiring"),
        ),
        _quickActionCard(
          "AI Graphics",
          Icons.auto_awesome,
          Colors.deepPurple,
          () => _handleQuickAction(category, "AI Graphics"),
        ),
        _quickActionCard(
          "Marketing Support",
          Icons.campaign,
          Colors.pink,
          () => _handleQuickAction(category, "Marketing Support"),
        ),
        _quickActionCard(
          "GST Portal",
          Icons.account_balance,
          Colors.purple,
          () => _handleQuickAction(category, "GST Portal"),
        ),
        _quickActionCard(
          "Applicants",
          Icons.people,
          Colors.green,
          () => _handleQuickAction(category, "Applicants"),
        ),
        _quickActionCard(
          "Post Internship",
          Icons.badge,
          Colors.teal,
          () => _handleQuickAction(category, "Post Internship"),
        ),
        _quickActionCard(
          "Business Leads",
          Icons.leaderboard,
          Colors.orange,
          () => _handleQuickAction(category, "Business Leads"),
        ),
        _quickActionCard(
          "My Jobs",
          Icons.work_history,
          Colors.indigo,
          () => _handleQuickAction(category, "My Jobs"),
        ),
        _quickActionCard(
          "Online Banking",
          Icons.account_balance,
          Colors.blue,
          () => _handleQuickAction(category, "Online Banking"),
        ),
        _quickActionCard(
          "UPI Payments",
          Icons.qr_code_scanner,
          Colors.pink,
          () => _handleQuickAction(category, "UPI Payments"),
        ),
        _quickActionCard(
          "DBT Scheme",
          Icons.sync_alt,
          Colors.amber,
          () => _handleQuickAction(category, "DBT Scheme"),
        ),
        _quickActionCard(
          "Jan Dhan Account",
          Icons.people_outline,
          Colors.cyan,
          () => _handleQuickAction(category, "Jan Dhan Account"),
        ),
        _quickActionCard(
          "Market",
          Icons.storefront,
          Colors.green,
          () => _handleQuickAction(category, "Market"),
        ),
      ]);
    } else if (category == 'Farmers') {
      actions.addAll([
        _quickActionCard(
          "My Farmer Loans",
          Icons.agriculture,
          Colors.green,
          () => _handleQuickAction(category, "My Farmer Loans"),
        ),
        _quickActionCard(
          "Mandi Price",
          Icons.trending_up,
          Colors.green,
          () => _handleQuickAction(category, "Mandi Price"),
        ),
        _quickActionCard(
          "Weather",
          Icons.wb_sunny,
          Colors.blue,
          () => _handleQuickAction(category, "Weather"),
        ),
        _quickActionCard(
          "Equipment",
          Icons.agriculture,
          Colors.brown,
          () => _handleQuickAction(category, "Equipment"),
        ),
        _quickActionCard(
          "Insurance",
          Icons.security,
          Colors.red,
          () => _handleQuickAction(category, "Insurance"),
        ),
        _quickActionCard(
          "Market",
          Icons.storefront,
          Colors.green,
          () => _handleQuickAction(category, "Market"),
        ),
      ]);
    } else if ((category == 'Bank' || category == 'Banking / Financial Services')) {
      actions.addAll([
        _quickActionCard(
          "My Wallet",
          Icons.account_balance_wallet,
          const Color(0xFF2196F3),
          () => _handleQuickAction(category, "Wallet"),
        ),
        _quickActionCard(
          "Business Leads",
          Icons.business,
          Colors.indigo,
          () => _handleQuickAction(category, "Business Leads"),
        ),
        _quickActionCard(
          "Student Leads",
          Icons.school,
          Colors.teal,
          () => _handleQuickAction(category, "Student Leads"),
        ),
        _quickActionCard(
          "Farmer Leads",
          Icons.agriculture,
          Colors.green,
          () => _handleQuickAction(category, "Farmer Leads"),
        ),
        _quickActionCard(
          "Verification",
          Icons.verified_user,
          Colors.green,
          () => _handleQuickAction(category, "Verification"),
        ),
        _quickActionCard(
          "Guidelines",
          Icons.gavel,
          Colors.purple,
          () => _handleQuickAction(category, "Guidelines"),
        ),
        _quickActionCard(
          "Reports",
          Icons.assessment,
          Colors.orange,
          () => _handleQuickAction(category, "Reports"),
        ),
        _quickActionCard(
          "Market",
          Icons.storefront,
          Colors.green,
          () => _handleQuickAction(category, "Market"),
        ),

        _quickActionCard(
          "Online Banking",
          Icons.account_balance,
          Colors.blue,
          () => _handleQuickAction(category, "Online Banking"),
        ),
        _quickActionCard(
          "UPI Payments",
          Icons.qr_code_scanner,
          Colors.pink,
          () => _handleQuickAction(category, "UPI Payments"),
        ),
        _quickActionCard(
          "DBT Portal",
          Icons.sync_alt,
          Colors.amber,
          () => _handleQuickAction(category, "DBT Portal"),
        ),
        _quickActionCard(
          "Jan Dhan Account",
          Icons.people_outline,
          Colors.cyan,
          () => _handleQuickAction(category, "Jan Dhan Account"),
        ),
        _quickActionCard(
          "Digital Leads",
          Icons.folder_shared,
          Colors.deepPurple,
          () => _handleQuickAction(category, "Digital Leads Folder"),
        ),
      ]);
    } else if (category.startsWith('Agent')) {
      if (category == 'Agent - Insurance') {
        actions.addAll([
          _quickActionCard("Crop Insurance", Icons.agriculture, Colors.green, () => _handleQuickAction(category, "Crop Insurance Leads")),
          _quickActionCard("Health Insurance", Icons.health_and_safety, Colors.red, () => _handleQuickAction(category, "Health Insurance Leads")),
          _quickActionCard("Motor Insurance", Icons.directions_car, Colors.blue, () => _handleQuickAction(category, "Motor Insurance Leads")),
        ]);
      } else if (category == 'Agent - Digital Services') {
        actions.addAll([
          _quickActionCard("Digital Marketing", Icons.campaign, Colors.purple, () => _handleQuickAction(category, "Digital Marketing Leads")),
        ]);
      } else if (category == 'Agent - CA / Document Agent') {
        actions.addAll([
          _quickActionCard("GST Registration", Icons.receipt_long, Colors.orange, () => _handleQuickAction(category, "GST Leads")),
          _quickActionCard("MSME / Udyam", Icons.factory, Colors.indigo, () => _handleQuickAction(category, "MSME Leads")),
          _quickActionCard("Shop Act", Icons.store, Colors.teal, () => _handleQuickAction(category, "Shop Act Leads")),
          _quickActionCard("Company / Firm", Icons.business, Colors.blueGrey, () => _handleQuickAction(category, "Company Firm Leads")),
          _quickActionCard("Crop Registration", Icons.eco, Colors.green, () => _handleQuickAction(category, "Crop Registration Leads")),
        ]);
      } else if (category == 'Agent - Institute/College') {
        actions.addAll([
          _quickActionCard("Admission Forms", Icons.school, Colors.blue, () => _handleQuickAction(category, "Admission Leads")),
          _quickActionCard("Scholarship Forms", Icons.card_giftcard, Colors.amber, () => _handleQuickAction(category, "Scholarship Leads")),
        ]);
      } else {
        actions.addAll([
          _quickActionCard("Agent Portal", Icons.support_agent, Colors.blue, () => _handleQuickAction(category, "Agent Portal")),
        ]);
      }
    }
    actions.addAll([
      _quickActionCard(
        "My Wallet",
        Icons.account_balance_wallet,
        const Color(0xFF2196F3),
        () => _handleQuickAction(category, "Wallet"),
      ),
      _quickActionCard(
        "Profile",
        Icons.person,
        Colors.blue,
        () => _handleQuickAction(category, "Profile"),
      ),
      _quickActionCard(
        "Settings",
        Icons.settings,
        Colors.grey,
        () => _handleQuickAction(category, "Settings"),
      ),
      _quickActionCard(
        "Support",
        Icons.help,
        Colors.orange,
        () => _handleQuickAction(category, "Support"),
      ),
      _quickActionCard(
        "Policy",
        Icons.description,
        Colors.teal,
        () => _handleQuickAction(category, "Policy"),
      ),
    ]);
    return actions;
}

  void _handleQuickAction(String category, String action) {
    final rawId = widget.userData['id'];
    final bankId = rawId != null ? int.tryParse(rawId.toString()) ?? 0 : 0;

    if (action == "Market") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MarketScreen()),
      );
      return;
    }

    if (action == "Wallet") {
      _openWallet();
      return;
    }
    if (action == "Profile") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => PersonalDetailsScreen(userData: widget.userData),
        ),
      );
      return;
    }
    if (action == "Settings") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
      return;
    }
    if (action == "Support") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
      );
      return;
    }
    if (action == "Policy") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PortalPolicyScreen(
            category: _stringValue(
              widget.userData['category'],
              fallback: 'User',
            ),
          ),
        ),
      );
      return;
    }

    if (category != null && category.startsWith('Job Seeker')) {
      if (action == "Find Jobs" || action == "Find Internships") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AvailableJobsScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "My Applications") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyApplicationsScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "Resume Builder") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResumeBuilderScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "Interview Prep") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const InterviewPrepScreen(),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$action coming soon!")),
      );
      return;
    }

    if (category != null && category.startsWith('Student')) {
      if (action == "Online Admission") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OnlineAdmissionScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "Scholarship Portal") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ScholarshipPortalScreen(),
          ),
        );
        return;
      }
      if (action == "Digital Learning") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DigitalLearningPlatformsScreen(),
          ),
        );
        return;
      }
      if (action == "Certificates") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OnlineCertificatesScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "Scholarships") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScholarshipScreen()),
        );
        return;
      }
      if (action == "Education Loan") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EducationLoanForm(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "Internships") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InternshipScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "E-Books") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EbooksLibraryScreen(
              streamHint: _stringValue(
                widget.userData['stream'],
                fallback: '',
              ),
            ),
          ),
        );
        return;
      }
      if (action == "Skill Test") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SkillAssessmentsScreen(
              skillsCsv: _stringValue(
                widget.userData['skills'],
                fallback: '',
              ),
            ),
          ),
        );
        return;
      }
      return;
    }

    if (category != null && category.startsWith('Business')) {
      if (action == "GST Registration") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                GstRegistrationScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "MSME") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MsmeRegistrationScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "Shop Act") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ShopActLicenseScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "Company Firm") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CompanyFirmRegistrationScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "MSME Loans") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusinessLoanForm(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "Applicants") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ApplicantsScreen(userId: int.tryParse(widget.userData['id']?.toString() ?? '0') ?? 0)),
        );
        return;
      }
      if (action == "Hiring" || action == "Post Internship") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostJobScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "Business Leads") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyLoansScreen(userId: _parsedUserId(), category: LeadCategory.business),
          ),
        );
        return;
      }
      if (action == "My Jobs") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyJobsScreen(userId: _parsedUserId()),
          ),
        );
        return;
      }
      if (action == "AI Graphics") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AiGraphicsScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "Marketing Support") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DigitalMarketingSupportScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "GST Portal") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GstOverviewScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "Online Banking") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OnlineBankingScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "UPI Payments") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpiPaymentScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "DBT Scheme") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DirectBenefitTransferScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "Jan Dhan Account") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JanDhanYojnaScreen(userData: widget.userData),
          ),
        );
        return;
      }
      return;
    }

    if (category == 'Farmers') {
      if (action == "My Farmer Loans") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyLoansScreen(
              userId: bankId,
              category: LeadCategory.farmer,
            ),
          ),
        );
        return;
      }
      if (action == "Mandi Price") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => const MarketScreen(),
          ),
        );
        return;
      }
      if (action == "Weather") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherAdvisoryScreen(
              district: _stringValue(widget.userData['district'], fallback: ''),
              state: _stringValue(widget.userData['state'], fallback: ''),
            ),
          ),
        );
        return;
      }
      if (action == "Equipment") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SubsidyScreen(userData: widget.userData)),
        );
        return;
      }
      if (action == "Insurance") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BimaYojanaScreen(userData: widget.userData)),
        );
        return;
      }
      return;
    }

    if ((category == 'Bank' || category == 'Banking / Financial Services')) {
      if (action == "Business Leads") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllLeadsScreen(
              currentBankUserId: bankId,
              category: LeadCategory.business,
            ),
          ),
        );
        return;
      }
      if (action == "Student Leads") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllLeadsScreen(
              currentBankUserId: bankId,
              category: LeadCategory.student,
            ),
          ),
        );
        return;
      }
      if (action == "Farmer Leads") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllLeadsScreen(
              currentBankUserId: bankId,
              category: LeadCategory.farmer,
            ),
          ),
        );
        return;
      }
      if (action == "Verification") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => AcceptedLeadsScreen(currentBankUserId: bankId),
          ),
        );
        return;
      }
      if (action == "Guidelines") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BankGuidelinesScreen(),
          ),
        );
        return;
      }
      if (action == "Reports") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => AcceptedLeadsScreen(currentBankUserId: bankId),
          ),
        );
        return;
      }
      if (action == "Online Banking") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OnlineBankingScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "UPI Payments") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpiPaymentScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "DBT Portal") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DirectBenefitTransferScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "Jan Dhan Account") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JanDhanYojnaScreen(userData: widget.userData),
          ),
        );
        return;
      }
      if (action == "Digital Leads Folder") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DigitalLeadsFolderScreen(
              userData: widget.userData,
              currentBankUserId: bankId,
            ),
          ),
        );
        return;
      }
      return;
    }

    if (action == "Crop Insurance Leads") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AllLeadsScreen(
            currentBankUserId: _parsedUserId(),
            category: LeadCategory.cropInsurance,
          ),
        ),
      );
      return;
    }

    if (action == "Health Insurance Leads") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AllLeadsScreen(
            currentBankUserId: _parsedUserId(),
            category: LeadCategory.healthInsurance,
          ),
        ),
      );
      return;
    }

    if (action == "Motor Insurance Leads") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AllLeadsScreen(
            currentBankUserId: _parsedUserId(),
            category: LeadCategory.motorInsurance,
          ),
        ),
      );
      return;
    }

    final Map<String, LeadCategory> agentLeadMap = {
      "Digital Marketing Leads": LeadCategory.digitalMarketing,
      "GST Leads": LeadCategory.gstRegistration,
      "MSME Leads": LeadCategory.msmeRegistration,
      "Shop Act Leads": LeadCategory.shopAct,
      "Company Firm Leads": LeadCategory.companyFirm,
      "Crop Registration Leads": LeadCategory.cropRegistration,
      "Admission Leads": LeadCategory.admissionForm,
      "Scholarship Leads": LeadCategory.scholarshipForm,
      "Online Banking Leads": LeadCategory.onlineBanking,
      "UPI Payments Leads": LeadCategory.upiPayments,
      "DBT Scheme Leads": LeadCategory.dbtScheme,
      "Jan Dhan Yojna Leads": LeadCategory.janDhan,
    };

    if (agentLeadMap.containsKey(action)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AllLeadsScreen(
            currentBankUserId: _parsedUserId(),
            category: agentLeadMap[action]!,
          ),
        ),
      );
      return;
    }

    if (action == "Agent Portal") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Coming soon: $action')),
      );
      return;
    }


    if (action == "Digital Leads Folder") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DigitalLeadsFolderScreen(
            userData: widget.userData,
            currentBankUserId: _parsedUserId(),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
    );
  }

  List<Widget> _getRecentUpdates(
    String category,
    Map<String, dynamic> userData,
  ) {
    if (category != null && category.startsWith('Student')) {
      return [
        _infoCard(
          Icons.school,
          "Academic Profile",
          "College: ${_stringValue(userData['college_name'], fallback: 'Not updated')}",
          Colors.red,
          imageAsset: HomeImages.skills,
        ),
        _infoCard(
          Icons.workspace_premium,
          "Skill Snapshot",
          "Skills: ${_stringValue(userData['skills'], fallback: 'Not added')}",
          Colors.blue,
          imageAsset: HomeImages.workspace,
        ),
      ];
    } else if (category != null && category.startsWith('Business')) {
      return [
        _infoCard(
          Icons.business_center,
          "Business Profile",
          "Company: ${_stringValue(userData['company_name'], fallback: 'Not updated')}",
          Colors.orange,
          imageAsset: HomeImages.business,
        ),
        _infoCard(
          Icons.receipt_long,
          "Compliance",
          "GST: ${_stringValue(userData['gst_number'], fallback: 'Not updated')}",
          Colors.purple,
          imageAsset: HomeImages.security,
        ),
      ];
    } else if (category == 'Farmers') {
      return [
        _infoCard(
          Icons.grass,
          "Crop Profile",
          "Main Crop: ${_stringValue(userData['crop_name'], fallback: 'Not updated')}",
          Colors.blue,
          imageAsset: HomeImages.carouselIndia,
        ),
        _infoCard(
          Icons.landscape,
          "Land Details",
          "Land Size: ${_stringValue(userData['land_size'], fallback: 'Not updated')}",
          Colors.green,
          imageAsset: HomeImages.business,
        ),
      ];
    } else if ((category == 'Bank' || category == 'Banking / Financial Services')) {
      return [
        _infoCard(
          Icons.account_balance,
          "Bank Profile",
          "Bank: ${_stringValue(userData['bank_name'], fallback: 'Not updated')}",
          Colors.red,
          imageAsset: HomeImages.carouselIndia,
        ),
        _infoCard(
          Icons.apartment,
          "Branch",
          "Branch: ${_stringValue(userData['branch_name'], fallback: 'Not updated')}",
          Colors.blue,
          imageAsset: HomeImages.services,
        ),
      ];
    } else if (category != null && category.startsWith('Job Seeker')) {
      return [
        _infoCard(
          Icons.school,
          "Education Profile",
          "Education: ${_stringValue(userData['highest_education'], fallback: 'Not updated')}",
          Colors.blue,
          imageAsset: HomeImages.skills,
        ),
        _infoCard(
          Icons.work,
          "Career Focus",
          "Role: ${_stringValue(userData['preferred_job_role'], fallback: 'Not specified')}",
          Colors.orange,
          imageAsset: HomeImages.workspace,
        ),
      ];
    }
    return [
      _infoCard(
        Icons.info_outline,
        "Welcome",
        "Welcome to the Digital Registration Portal.",
        Colors.blue,
        imageAsset: HomeImages.banner,
      ),
    ];
  }

  List<Widget> _getCategoryInsights(
    String category,
    Map<String, dynamic> userData,
  ) {
    if (category != null && category.startsWith('Student')) {
      return [
        _infoCard(
          Icons.school_outlined,
          "Education Track",
          "Year: ${_stringValue(userData['standard_year'], fallback: 'Not updated')} | "
              "Stream: ${_stringValue(userData['stream'], fallback: 'Not updated')}",
          Colors.indigo,
          imageAsset: HomeImages.skills,
        ),
        _infoCard(
          Icons.account_balance_wallet_outlined,
          "Loan Readiness",
          "Preferred amount: ${_stringValue(userData['loan_amount'], fallback: 'Add in education loan form')}",
          Colors.teal,
          imageAsset: HomeImages.digital,
        ),
      ];
    }
    if (category != null && category.startsWith('Business')) {
      return [
        _infoCard(
          Icons.corporate_fare_outlined,
          "Business Snapshot",
          "Company: ${_stringValue(userData['company_name'], fallback: 'Not updated')}",
          Colors.indigo,
          imageAsset: HomeImages.business,
        ),
        _infoCard(
          Icons.groups_2_outlined,
          "Operations",
          "Employees: ${_stringValue(userData['employee_count'], fallback: 'Not updated')} | "
              "Turnover: ${_stringValue(userData['turnover'], fallback: 'Not updated')}",
          Colors.teal,
          imageAsset: HomeImages.workspace,
        ),
      ];
    }
    if (category == 'Farmers') {
      return [
        _infoCard(
          Icons.agriculture_outlined,
          "Crop Planning",
          "Main crop: ${_stringValue(userData['crop_name'], fallback: 'Not updated')}",
          Colors.indigo,
          imageAsset: HomeImages.carouselIndia,
        ),
        _infoCard(
          Icons.landscape_outlined,
          "Farm Capacity",
          "Land size: ${_stringValue(userData['land_size'], fallback: 'Not updated')}",
          Colors.teal,
          imageAsset: HomeImages.business,
        ),
      ];
    }
    if ((category == 'Bank' || category == 'Banking / Financial Services')) {
      return [
        _infoCard(
          Icons.account_balance_outlined,
          "Branch Profile",
          "Bank: ${_stringValue(userData['bank_name'], fallback: 'Not updated')} | "
              "Branch: ${_stringValue(userData['branch_name'], fallback: 'Not updated')}",
          Colors.indigo,
          imageAsset: HomeImages.carouselIndia,
        ),
        _infoCard(
          Icons.rule_outlined,
          "Policy Focus",
          "Interest rate: ${_stringValue(userData['interest_rate'], fallback: 'Not updated')}%",
          Colors.teal,
          imageAsset: HomeImages.security,
        ),
      ];
    }
    if (category != null && category.startsWith('Job Seeker')) {
      return [
        _infoCard(
          Icons.cases_outlined,
          "Experience Level",
          "Years: ${_stringValue(userData['years_of_experience'], fallback: 'Not updated')}",
          Colors.indigo,
          imageAsset: HomeImages.business,
        ),
        _infoCard(
          Icons.star_outline,
          "Application Status",
          "Find and track your job applications in Quick Actions.",
          Colors.teal,
          imageAsset: HomeImages.digital,
        ),
      ];
    }
    return [
      _infoCard(
        Icons.dashboard_outlined,
        "Portal Overview",
        "Use Quick Actions for services and Profile tab for account settings.",
        Colors.indigo,
        imageAsset: HomeImages.services,
      ),
    ];
  }

  String _stringValue(dynamic value, {String fallback = '--'}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return fallback;
    return text;
  }

  double _profileCompletionPercent(Map<String, dynamic> userData) {
    final List<String> relevantKeys = [
      'name',
      'mobile',
      'email',
      'category',
      'pincode',
      'district',
      'city',
      'state',
    ];

    final category = userData['category']?.toString();
    if (category != null && category.startsWith('Job Seeker')) {
      relevantKeys.addAll(['years_of_experience', 'highest_education', 'preferred_job_role']);
    } else if (category != null && category.startsWith('Business')) {
      relevantKeys.addAll(['company_name', 'gst_number', 'turnover']);
    } else if (category != null && category.startsWith('Student')) {
      relevantKeys.addAll(['college_name', 'standard_year', 'stream']);
    } else if (category == 'Farmers' || category == 'Farmer') {
      relevantKeys.addAll(['crop_name', 'land_size']);
    } else if ((category == 'Bank' || category == 'Banking / Financial Services') || category == 'Banker') {
      relevantKeys.addAll(['bank_name', 'branch_name']);
    }

    final filled =
        relevantKeys
            .where(
              (key) => _stringValue(userData[key], fallback: '').isNotEmpty,
            )
            .length;
    return (filled / relevantKeys.length) * 100;
  }

  IconData _categoryIcon(String category) {
    if (category.startsWith('Student')) {
      return Icons.school;
    } else if (category.startsWith('Business')) {
      return Icons.business;
    } else if (category.startsWith('Agent')) {
      return Icons.support_agent;
    } else if (category == 'Farmers') {
      return Icons.agriculture;
    } else if (category == 'Bank' || category == 'Banking / Financial Services') {
      return Icons.account_balance;
    } else if (category != null && category.startsWith('Job Seeker')) {
      return Icons.work;
    } else {
      return Icons.person;
    }
  }

  String _primaryInfoByCategory(
    String category,
    Map<String, dynamic> userData,
  ) {
    if (category.startsWith('Student')) {
      return _stringValue(userData['name'], fallback: 'Student');
    } else if (category.startsWith('Business')) {
      return _stringValue(userData['company_name'], fallback: 'Not set');
    } else if (category == 'Farmers') {
      return _stringValue(userData['name'], fallback: 'Farmer');
    } else if (category == 'Bank' || category == 'Banking / Financial Services') {
      return _stringValue(userData['bank_name'], fallback: 'Not set');
    } else if (category != null && category.startsWith('Job Seeker')) {
      return _stringValue(userData['preferred_job_role'], fallback: 'Job Seeker');
    } else {
      return _stringValue(userData['category'], fallback: 'User');
    }
  }

  String _secondaryInfoByCategory(
    String category,
    Map<String, dynamic> userData,
  ) {
    if (category.startsWith('Student')) {
      return 'College';
    } else if (category.startsWith('Business')) {
      return 'Company';
    } else if (category == 'Farmers') {
      return 'Main Crop';
    } else if (category == 'Bank' || category == 'Banking / Financial Services') {
      return 'Bank';
    } else if (category != null && category.startsWith('Job Seeker')) {
      return 'Preferred Role';
    } else {
      return _stringValue(userData['category'], fallback: 'Category');
    }
  }
}

class DigitalLeadsFolderScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  final int currentBankUserId;

  const DigitalLeadsFolderScreen({
    super.key,
    required this.userData,
    required this.currentBankUserId,
  });

  Widget _quickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLeads(BuildContext context, LeadCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllLeadsScreen(
          currentBankUserId: currentBankUserId,
          category: category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Digital Leads'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Digital Scheme Leads",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8, // Increased to make cards even shorter
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _quickActionCard(
                  "Online Banking Leads",
                  Icons.account_balance_wallet,
                  Colors.blueAccent,
                  () => _navigateToLeads(context, LeadCategory.onlineBanking),
                ),
                _quickActionCard(
                  "UPI Payments Leads",
                  Icons.qr_code_2,
                  Colors.pinkAccent,
                  () => _navigateToLeads(context, LeadCategory.upiPayments),
                ),
                _quickActionCard(
                  "DBT Scheme Leads",
                  Icons.account_tree,
                  Colors.amberAccent,
                  () => _navigateToLeads(context, LeadCategory.dbtScheme),
                ),
                _quickActionCard(
                  "Jan Dhan Yojna Leads",
                  Icons.group,
                  Colors.cyanAccent,
                  () => _navigateToLeads(context, LeadCategory.janDhan),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
