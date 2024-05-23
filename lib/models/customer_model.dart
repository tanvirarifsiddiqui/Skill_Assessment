class CustomerDash {
  final int id;
  final String name;
  final String phone;
  final String balance;

  CustomerDash({
    required this.id,
    required this.name,
    required this.phone,
    required this.balance,
  });

  factory CustomerDash.fromJson(Map<String, dynamic> json) {
    return CustomerDash(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      balance: json['balance'],
    );
  }
}


class Customer {
  final int id;
  final int companyId;
  final int branchId;
  final int userId;
  final String name;
  final String phone;
  final String email;
  final int type;
  final String balance;
  final String? reminderDate;
  final String? image;
  final String address;
  final String area;
  final String postCode;
  final String city;
  final String state;
  final int status;
  final int createdBy;
  final String createdAt;
  final int updatedBy;
  final String updatedAt;
  final int deleted;
  final int? deletedBy;
  final String? deletedAt;
  final String? showImage;

  Customer({
    required this.id,
    required this.companyId,
    required this.branchId,
    required this.userId,
    required this.name,
    required this.phone,
    required this.email,
    required this.type,
    required this.balance,
    required this.address,
    required this.area,
    required this.postCode,
    required this.city,
    required this.state,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    required this.deleted,
    this.reminderDate,
    this.image,
    this.deletedBy,
    this.deletedAt,
    this.showImage,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      companyId: json['company_id'],
      branchId: json['branch_id'],
      userId: json['user_id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      type: json['type'],
      balance: json['balance'],
      reminderDate: json['reminder_date'],
      image: json['image'],
      address: json['address'],
      area: json['area'],
      postCode: json['post_code'],
      city: json['city'],
      state: json['state'],
      status: json['status'],
      createdBy: json['created_by'],
      createdAt: json['created_at'],
      updatedBy: json['updated_by'],
      updatedAt: json['updated_at'],
      deleted: json['deleted'],
      deletedBy: json['deleted_by'],
      deletedAt: json['deleted_at'],
      showImage: json['show_image'],
    );
  }
}
