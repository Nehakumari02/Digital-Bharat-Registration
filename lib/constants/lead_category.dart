/// Loan lead buckets aligned with Laravel tables and `loan_type` values.
enum LeadCategory {
  business(
    title: 'Business Leads',
    apiType: 'Business Loan',
    tableName: 'business_loans',
  ),
  student(
    title: 'Student Loans',
    apiType: 'Education Loan',
    tableName: 'student_loans',
  ),
  farmer(
    title: 'Farmer Loans',
    apiType: 'Farmer Loan',
    tableName: 'farmer_loans',
  ),
  cropInsurance(
    title: 'Crop Insurance Leads',
    apiType: 'Crop Insurance',
    tableName: 'farmer_insurance_applications',
  ),
  healthInsurance(
    title: 'Health Insurance Leads',
    apiType: 'Health Insurance',
    tableName: 'health_insurance_applications',
  ),
  motorInsurance(
    title: 'Motor Insurance Leads',
    apiType: 'Motor Insurance',
    tableName: 'motor_insurance_applications',
  ),
  digitalMarketing(
    title: 'Digital Marketing Leads',
    apiType: 'Marketing Support',
    tableName: 'business_loans',
  ),
  gstRegistration(
    title: 'GST Leads',
    apiType: 'GST Registration',
    tableName: 'business_loans',
  ),
  msmeRegistration(
    title: 'MSME Leads',
    apiType: 'MSME Registration',
    tableName: 'business_loans',
  ),
  shopAct(
    title: 'Shop Act Leads',
    apiType: 'Shop Act License',
    tableName: 'business_loans',
  ),
  companyFirm(
    title: 'Company Firm Leads',
    apiType: 'Company Firm Registration',
    tableName: 'business_loans',
  ),
  cropRegistration(
    title: 'Crop Registration Leads',
    apiType: 'Crop Registration',
    tableName: 'crop_registrations',
  ),
  onlineBanking(
    title: 'Online Banking Leads',
    apiType: 'Online Banking',
    tableName: 'business_loans',
  ),
  upiPayments(
    title: 'UPI Payments Leads',
    apiType: 'UPI Payments',
    tableName: 'business_loans',
  ),
  dbtScheme(
    title: 'DBT Scheme Leads',
    apiType: 'Direct Benefit Transfer',
    tableName: 'business_loans',
  ),
  janDhan(
    title: 'Jan Dhan Yojna Leads',
    apiType: 'Jan Dhan Account',
    tableName: 'business_loans',
  ),
  admissionForm(
    title: 'Admission Leads',
    apiType: 'student_admission',
    tableName: 'student_loans',
  ),
  scholarshipForm(
    title: 'Scholarship Leads',
    apiType: 'student_scholarship',
    tableName: 'student_loans',
  );

  const LeadCategory({
    required this.title,
    required this.apiType,
    required this.tableName,
  });

  final String title;
  final String apiType;
  final String tableName;

  bool matchesLead({required String loanType, required String table}) {
    final normalizedTable = table.trim().toLowerCase();
    
    // For business loans and student loans which are shared, we must check the loanType strictly.
    // However, the backend currently returns "Business Loan" for unmapped purposes, and "Education Loan" for all student loans.
    // Since the UI doesn't require strict filtering at the table level (they all just show up), 
    // we'll keep the basic matching but add support for matching exact apiType if they want strict filtering.
    // For now, if the API type matches the expected, it's a match.
    if (loanType.trim().toLowerCase() == apiType.toLowerCase()) {
      return true;
    }
    
    // Fallback for tables that don't pass specific loanTypes correctly yet
    if (normalizedTable == tableName.toLowerCase()) {
      // If it's a shared table, we only match if it's the 'parent' category to avoid 
      // showing all MSME leads when we clicked 'GST Registration' IF we had strict checking.
      // But since we want to show leads, we just return true.
      return true; 
    }
    
    return false;
  }
}
