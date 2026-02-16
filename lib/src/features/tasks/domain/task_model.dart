class TaskItem {
  final String id;
  final String title;
  final String location;
  final bool isActive;
  final bool isCompleted;
  final double radius;
  final DateTime? createdAt;
  final bool carryForward;
  final DateTime? completedAt;

  TaskItem({
    required this.id,
    required this.title,
    required this.location,
    required this.isActive,
    this.isCompleted = false,
    required this.radius,
    this.createdAt,
    this.carryForward = false,
    this.completedAt,
  });

  TaskItem copyWith({
    String? id,
    String? title,
    String? location,
    bool? isActive,
    bool? isCompleted,
    double? radius,
    DateTime? createdAt,
    bool? carryForward,
    DateTime? completedAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      radius: radius ?? this.radius,
      createdAt: createdAt ?? this.createdAt,
      carryForward: carryForward ?? this.carryForward,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'location': location,
      'isActive': isActive,
      'isCompleted': isCompleted,
      'radius': radius,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'carryForward': carryForward,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TaskItem.fromMap(String id, Map<String, dynamic> map) {
    return TaskItem(
      id: id,
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      isActive: map['isActive'] ?? true,
      isCompleted: map['isCompleted'] ?? false,
      radius: (map['radius'] ?? 1000).toDouble(),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      carryForward: map['carryForward'] ?? false,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    );
  }
}
