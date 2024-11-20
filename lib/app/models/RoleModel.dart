class RoleModel {
  final int id;
  final String? createdAt;
  final bool deleted;
  final String? deletedAt;
  final String? updatedAt;
  final String libelle;

  RoleModel({
    required this.id,
    this.createdAt,
    required this.deleted,
    this.deletedAt,
    this.updatedAt,
    required this.libelle,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      createdAt: json['created_at'],
      deleted: json['deleted'],
      deletedAt: json['deleted_at'],
      updatedAt: json['updated_at'],
      libelle: json['libelle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'deleted': deleted,
      'deleted_at': deletedAt,
      'updated_at': updatedAt,
      'libelle': libelle,
    };
  }
}
