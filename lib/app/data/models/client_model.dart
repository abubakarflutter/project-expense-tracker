class ClientModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? company;
  final DateTime createdAt;

  ClientModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.company,
    required this.createdAt,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'company': company,
        'createdAt': createdAt.toIso8601String(),
      };

  // Create from JSON
  factory ClientModel.fromJson(Map<String, dynamic> json) => ClientModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        company: json['company'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  // CopyWith method for easy updates
  ClientModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? company,
    DateTime? createdAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ClientModel(id: $id, name: $name, email: $email, phone: $phone, company: $company, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ClientModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.company == company &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        company.hashCode ^
        createdAt.hashCode;
  }
}
