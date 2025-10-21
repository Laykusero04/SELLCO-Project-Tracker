class ExpenseCategoryModel {
  final String categoryId;
  final String name;
  final String icon;
  final String color;
  final bool isActive;
  final List<String> subcategories;

  ExpenseCategoryModel({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.color,
    this.isActive = true,
    this.subcategories = const [],
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'category_id': categoryId,
      'name': name,
      'icon': icon,
      'color': color,
      'is_active': isActive,
      'subcategories': subcategories,
    };
  }

  // Create from Firestore document
  factory ExpenseCategoryModel.fromMap(Map<String, dynamic> map) {
    return ExpenseCategoryModel(
      categoryId: map['category_id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      color: map['color'] ?? '',
      isActive: map['is_active'] ?? true,
      subcategories: List<String>.from(map['subcategories'] ?? []),
    );
  }

  // Copy with modifications
  ExpenseCategoryModel copyWith({
    String? categoryId,
    String? name,
    String? icon,
    String? color,
    bool? isActive,
    List<String>? subcategories,
  }) {
    return ExpenseCategoryModel(
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      subcategories: subcategories ?? this.subcategories,
    );
  }
}
