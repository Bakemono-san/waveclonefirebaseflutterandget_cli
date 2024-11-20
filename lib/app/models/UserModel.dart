class UserModel {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String deletedAt;
  final bool deleted;
  final String telephone;
  final String adresse;
  final String email;
  final bool enabled;
  final String idCardNumber;
  final String nom;
  final String password;
  final String prenom;
  final String qrCode;
  final String status;
  final String roleId;
  final String accountId;

  UserModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.deleted,
    required this.telephone,
    required this.adresse,
    required this.email,
    required this.enabled,
    required this.idCardNumber,
    required this.nom,
    required this.password,
    required this.prenom,
    required this.qrCode,
    required this.status,
    required this.roleId,
    required this.accountId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',  
      createdAt: json['created_at'] ?? '', 
      updatedAt: json['updated_at'] ?? '', 
      deletedAt: json['deleted_at'] ?? '', 
      deleted: json['deleted'] ?? false,
      telephone: json['telephone'] ?? '',
      adresse: json['adresse'] ?? '',
      email: json['email'] ?? '',
      enabled: json['enabled'] ?? true,
      idCardNumber: json['id_card_number'] ?? '',
      nom: json['nom'] ?? '',
      password: json['password'] ?? '',
      prenom: json['prenom'] ?? '',
      qrCode: json['qr_code'] ?? '',
      status: json['status'] ?? '',
      roleId: json['role_id'] ?? '',
      accountId: json['account_id'] ?? '', 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'deleted': deleted,
      'telephone': telephone,
      'adresse': adresse,
      'email': email,
      'enabled': enabled,
      'id_card_number': idCardNumber,
      'nom': nom,
      'password': password,
      'prenom': prenom,
      'qr_code': qrCode,
      'status': status,
      'role_id': roleId,
      'account_id': accountId,
    };
  }
}
