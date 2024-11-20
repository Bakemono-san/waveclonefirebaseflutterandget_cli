class AccountModel {
  final int? id;
  final double plafond;
  final double solde;
  final String type;
  final String? createdAt;
  final bool deleted;
  final String? deletedAt;
  final String? updatedAt;
  final String userId;
  final double sommeDepot;
  final bool plafonnee;

  AccountModel({
    this.id,
    required this.plafond,
    required this.solde,
    required this.type,
    this.createdAt,
    required this.deleted,
    this.deletedAt,
    this.updatedAt,
    required this.userId,
    required this.sommeDepot,
    required this.plafonnee,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      plafond: json['plafond'],
      solde: json['solde'],
      type: json['type'],
      createdAt: json['created_at'],
      deleted: json['deleted'],
      deletedAt: json['deleted_at'],
      updatedAt: json['updated_at'],
      userId: json['user_id'],
      sommeDepot: json['somme_depot'],
      plafonnee: json['plafonnee'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plafond': plafond,
      'solde': solde,
      'type': type,
      'created_at': createdAt,
      'deleted': deleted,
      'deleted_at': deletedAt,
      'updated_at': updatedAt,
      'user_id': userId,
      'somme_depot': sommeDepot,
      'plafonnee': plafonnee,
    };
  }
}
