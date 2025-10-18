class InvoiceModel {
  final String id;
  final String projectId;
  final String invoiceNumber;
  final double amount;
  final DateTime paymentDate;
  final String description;
  final String paymentMethod; // 'bank_transfer', 'cash', 'check', 'online'
  final String status; // 'paid', 'pending'
  final DateTime createdAt;

  InvoiceModel({
    required this.id,
    required this.projectId,
    required this.invoiceNumber,
    required this.amount,
    required this.paymentDate,
    required this.description,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  // Check if invoice is paid
  bool get isPaid => status == 'paid';

  // Check if invoice is pending
  bool get isPending => status == 'pending';

  // Get formatted payment method
  String get formattedPaymentMethod {
    switch (paymentMethod) {
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'cash':
        return 'Cash';
      case 'check':
        return 'Check';
      case 'online':
        return 'Online Payment';
      default:
        return paymentMethod;
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'invoiceNumber': invoiceNumber,
        'amount': amount,
        'paymentDate': paymentDate.toIso8601String(),
        'description': description,
        'paymentMethod': paymentMethod,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  // Create from JSON
  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
        id: json['id'] as String,
        projectId: json['projectId'] as String,
        invoiceNumber: json['invoiceNumber'] as String,
        amount: (json['amount'] as num).toDouble(),
        paymentDate: DateTime.parse(json['paymentDate'] as String),
        description: json['description'] as String,
        paymentMethod: json['paymentMethod'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  // CopyWith method for easy updates
  InvoiceModel copyWith({
    String? id,
    String? projectId,
    String? invoiceNumber,
    double? amount,
    DateTime? paymentDate,
    String? description,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'InvoiceModel(id: $id, projectId: $projectId, invoiceNumber: $invoiceNumber, amount: $amount, paymentDate: $paymentDate, description: $description, paymentMethod: $paymentMethod, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InvoiceModel &&
        other.id == id &&
        other.projectId == projectId &&
        other.invoiceNumber == invoiceNumber &&
        other.amount == amount &&
        other.paymentDate == paymentDate &&
        other.description == description &&
        other.paymentMethod == paymentMethod &&
        other.status == status &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        projectId.hashCode ^
        invoiceNumber.hashCode ^
        amount.hashCode ^
        paymentDate.hashCode ^
        description.hashCode ^
        paymentMethod.hashCode ^
        status.hashCode ^
        createdAt.hashCode;
  }
}
