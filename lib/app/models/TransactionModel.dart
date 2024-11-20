import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  String? id;
  String? agentTelephone;
  bool annulee;
  String date;
  double montant;
  String? receiverTelephone;
  String? senderTelephone;
  String type;
  String? createdAt;
  bool deleted;
  String? deletedAt;
  String? updatedAt;

  TransactionModel({
    this.id,
    required this.annulee,
    required this.date,
    required this.montant,
    required this.type,
    this.createdAt,
    required this.deleted,
    this.deletedAt,
    this.updatedAt,
    this.agentTelephone,
    required this.receiverTelephone,
    this.senderTelephone,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Handling Timestamp fields
    var date = json['date'];
    var createdAt = json['created_at'];
    var updatedAt = json['updated_at'];

    // Check if date, createdAt, and updatedAt are Timestamps or Strings
    if (date is Timestamp) {
      date = date.toDate().toIso8601String();
    } else if (date is String) {
      // If it's already a string, keep it as is
      date = date;
    }

    if (createdAt is Timestamp) {
      createdAt = createdAt.toDate().toIso8601String();
    } else if (createdAt is String) {
      createdAt = createdAt;
    }

    if (updatedAt is Timestamp) {
      updatedAt = updatedAt.toDate().toIso8601String();
    } else if (updatedAt is String) {
      updatedAt = updatedAt;
    }

    return TransactionModel(
      id: json['id'],
      annulee: json['annulee'],
      date: date ?? '', // Handle if date is null
      montant: (json['montant'] is double)
          ? json['montant']
          : (json['montant'] as int).toDouble(),
      type: json['type'],
      createdAt: createdAt,
      deleted: json['deleted'],
      deletedAt: json['deleted_at'],
      updatedAt: updatedAt,
      agentTelephone: json['agent_telephone'],
      receiverTelephone: json['receiver_telephone'],
      senderTelephone: json['sender_telephone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'annulee': annulee,
      'date': date,
      'montant': montant,
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
