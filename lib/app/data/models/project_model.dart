class ProjectModel {
  final String id;
  final String clientId;
  final String name;
  final String? description;
  final double totalBudget;
  final double totalReceived;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status; // 'active', 'completed', 'on-hold'
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.clientId,
    required this.name,
    this.description,
    required this.totalBudget,
    this.totalReceived = 0.0,
    this.startDate,
    this.endDate,
    required this.status,
    required this.createdAt,
  });

  // Computed property: remaining budget
  double get remainingBudget => totalBudget - totalReceived;

  // Computed property: progress percentage
  double get progressPercentage {
    if (totalBudget == 0) return 0.0;
    return (totalReceived / totalBudget) * 100;
  }

  // Check if project is complete
  bool get isFullyPaid => totalReceived >= totalBudget;

  // Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'name': name,
        'description': description,
        'totalBudget': totalBudget,
        'totalReceived': totalReceived,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  // Create from JSON
  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        id: json['id'] as String,
        clientId: json['clientId'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        totalBudget: (json['totalBudget'] as num).toDouble(),
        totalReceived: (json['totalReceived'] as num?)?.toDouble() ?? 0.0,
        startDate: json['startDate'] != null
            ? DateTime.parse(json['startDate'] as String)
            : null,
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'] as String)
            : null,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  // CopyWith method for easy updates
  ProjectModel copyWith({
    String? id,
    String? clientId,
    String? name,
    String? description,
    double? totalBudget,
    double? totalReceived,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? createdAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      description: description ?? this.description,
      totalBudget: totalBudget ?? this.totalBudget,
      totalReceived: totalReceived ?? this.totalReceived,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ProjectModel(id: $id, clientId: $clientId, name: $name, description: $description, totalBudget: $totalBudget, totalReceived: $totalReceived, remainingBudget: $remainingBudget, startDate: $startDate, endDate: $endDate, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProjectModel &&
        other.id == id &&
        other.clientId == clientId &&
        other.name == name &&
        other.description == description &&
        other.totalBudget == totalBudget &&
        other.totalReceived == totalReceived &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.status == status &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        clientId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        totalBudget.hashCode ^
        totalReceived.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        status.hashCode ^
        createdAt.hashCode;
  }
}
