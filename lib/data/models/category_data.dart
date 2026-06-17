class CategoryData {
  final int? id;
  final String name;
  final String slug;
  final int iconCodePoint;
  final int? colorValue;
  final String createdAt;

  const CategoryData({
    this.id,
    required this.name,
    required this.slug,
    this.iconCodePoint = 0xe2c8,
    this.colorValue,
    required this.createdAt,
  });

  factory CategoryData.fromMap(Map<String, dynamic> map) {
    return CategoryData(
      id: map['id'] as int?,
      name: map['name'] as String,
      slug: map['slug'] as String,
      iconCodePoint: map['icon_code_point'] as int? ?? 0xe2c8,
      colorValue: map['color_value'] as int?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'slug': slug,
      'icon_code_point': iconCodePoint,
      'color_value': colorValue,
      'created_at': createdAt,
    };
  }

  CategoryData copyWith({
    int? id,
    String? name,
    String? slug,
    int? iconCodePoint,
    int? colorValue,
    String? createdAt,
  }) {
    return CategoryData(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
