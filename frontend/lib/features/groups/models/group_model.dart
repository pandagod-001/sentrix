class Group {
  final String id;
  final String name;
  final String description;
  final String type; // 'family' or 'official'
  final String? imageUrl;
  final List<String> memberIds;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.imageUrl,
    required this.memberIds,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    required this.isActive,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type,
        'imageUrl': imageUrl,
        'memberIds': memberIds,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'isActive': isActive,
      };

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        type: json['type'] as String,
        imageUrl: json['imageUrl'] as String?,
        memberIds: List<String>.from(json['memberIds'] as List),
        createdBy: json['createdBy'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
        isActive: json['isActive'] as bool? ?? true,
      );

  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    String? imageUrl,
    List<String>? memberIds,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) =>
      Group(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        type: type ?? this.type,
        imageUrl: imageUrl ?? this.imageUrl,
        memberIds: memberIds ?? this.memberIds,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isActive: isActive ?? this.isActive,
      );
}
