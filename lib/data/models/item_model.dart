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

  static const _unset = Object();

  Item copyWith({
    int? id,
    String? name,
    String? location,
    String? category,
    Object? tags = _unset,
    Object? notes = _unset,
    Object? photoPath = _unset,
    Object? latitude = _unset,
    Object? longitude = _unset,
    Object? address = _unset,
    Object? reminderTime = _unset,
    String? reminderRepeat,
    String? createdAt,
    String? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      category: category ?? this.category,
      tags: tags == _unset ? this.tags : tags as String?,
      notes: notes == _unset ? this.notes : notes as String?,
      photoPath: photoPath == _unset ? this.photoPath : photoPath as String?,
      latitude: latitude == _unset ? this.latitude : latitude as double?,
      longitude: longitude == _unset ? this.longitude : longitude as double?,
      address: address == _unset ? this.address : address as String?,
      reminderTime: reminderTime == _unset ? this.reminderTime : reminderTime as String?,
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
