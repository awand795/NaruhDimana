class Item {
  final int? id;
  final String name;
  final String location;
  final String category;
  final String? tags;
  final String? notes;
  final String? photoPath;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? reminderTime;
  final String reminderRepeat;
  final String createdAt;
  final String updatedAt;

  const Item({
    this.id,
    required this.name,
    required this.location,
    required this.category,
    this.tags,
    this.notes,
    this.photoPath,
    this.latitude,
    this.longitude,
    this.address,
    this.reminderTime,
    this.reminderRepeat = 'none',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as int?,
      name: map['name'] as String,
      location: map['location'] as String,
      category: map['category'] as String,
      tags: map['tags'] as String?,
      notes: map['notes'] as String?,
      photoPath: map['photo_path'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      address: map['address'] as String?,
      reminderTime: map['reminder_time'] as String?,
      reminderRepeat: map['reminder_repeat'] as String? ?? 'none',
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'location': location,
      'category': category,
      'tags': tags,
      'notes': notes,
      'photo_path': photoPath,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'reminder_time': reminderTime,
      'reminder_repeat': reminderRepeat,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Item copyWith({
    int? id,
    String? name,
    String? location,
    String? category,
    String? tags,
    String? notes,
    String? photoPath,
    double? latitude,
    double? longitude,
    String? address,
    String? reminderTime,
    String? reminderRepeat,
    String? createdAt,
    String? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderRepeat: reminderRepeat ?? this.reminderRepeat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'category': category,
      'tags': tags,
      'notes': notes,
      'photo_path': photoPath,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'reminder_time': reminderTime,
      'reminder_repeat': reminderRepeat,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
