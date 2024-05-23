class User {
  final int id;
  final String apiToken;
  final String name;
  final String email;
  final String phone;
  final String businessName;
  final String businessType;
  final int businessTypeId;
  final String branch;
  final int companyId;
  final int branchId;

  User({
    required this.id,
    required this.apiToken,
    required this.name,
    required this.email,
    required this.phone,
    required this.businessName,
    required this.businessType,
    required this.businessTypeId,
    required this.branch,
    required this.companyId,
    required this.branchId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      apiToken: json['api_token'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      businessName: json['business_name'],
      businessType: json['business_type'],
      businessTypeId: json['business_type_id'],
      branch: json['branch'],
      companyId: json['company_id'],
      branchId: json['branch_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user_id': id.toString(),
      'api_token': apiToken,
      'user_name': name,
      'user_email': email,
      'user_phone': phone,
      'business_name': businessName,
      'business_type': businessType,
      'business_type_id': businessTypeId,
      'branch': branch,
      'company_id': companyId,
      'branch_id': branchId,
    };
    return data;
  }
}
