class TransactionModel {
  final int id;
  final int agentId;
  final bool annulee;
  final String date;
  final double montant;
  final int receiverId;
  final int senderId;
  final String type;
  final String? createdAt;
  final bool deleted;
  final String? deletedAt;
  final String? updatedAt;
  final String? agentTelephone;
  final String receiverTelephone;
  final String senderTelephone;

  TransactionModel({
    required this.id,
    required this.agentId,
    required this.annulee,
    required this.date,
    required this.montant,
    required this.receiverId,
    required this.senderId,
    required this.type,
    this.createdAt,
    required this.deleted,
    this.deletedAt,
    this.updatedAt,
    this.agentTelephone,
    required this.receiverTelephone,
    required this.senderTelephone,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      agentId: json['agent_id'],
      annulee: json['annulee'],
      date: json['date'],
      montant: json['montant'],
      receiverId: json['receiver_id'],
      senderId: json['sender_id'],
      type: json['type'],
      createdAt: json['created_at'],
      deleted: json['deleted'],
      deletedAt: json['deleted_at'],
      updatedAt: json['updated_at'],
      agentTelephone: json['agent_telephone'],
      receiverTelephone: json['receiver_telephone'],
      senderTelephone: json['sender_telephone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agent_id': agentId,
      'annulee': annulee,
      'date': date,
      'montant': montant,
      'receiver_id': receiverId,
      'sender_id': senderId,
      'type': type,
      'created_at': createdAt,
      'deleted': deleted,
      'deleted_at': deletedAt,
      'updated_at': updatedAt,
      'agent_telephone': agentTelephone,
      'receiver_telephone': receiverTelephone,
      'sender_telephone': senderTelephone,
    };
  }
}
