/// Loan lead buckets aligned with Laravel tables and `loan_type` values.
enum LeadCategory {
  business(
    title: 'Business Loans',
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
    if (normalizedTable == tableName.toLowerCase()) return true;
    return loanType.trim().toLowerCase() == apiType.toLowerCase();
  }
}
