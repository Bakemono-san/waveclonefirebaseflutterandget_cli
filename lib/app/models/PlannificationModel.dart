import 'package:get/get.dart';

class Plannification {
  String? id;
  double? montant;
  String? periode;
  String? receiverTelephone;
  String? senderTelephone;
  String? updatedAt;
  String? deletedAt;
  String? createdAt;
  bool? deleted;

  Plannification({
    this.id,
    this.montant,
    this.periode,
    this.receiverTelephone,
    this.senderTelephone,
    this.updatedAt,
    this.deletedAt,
    this.createdAt,
    this.deleted,
  });

  // Factory method to create an object from JSON
  factory Plannification.fromJson(Map<String, dynamic> json) {
    return Plannification(
      id: json['id'] ,
      montant: (json['montant'] as num?)?.toDouble(),
      periode: json['periode'] as String?,
      receiverTelephone: json['receiverTelephone'] as String?,
      senderTelephone: json['senderTelephone'] as String?,
      updatedAt: json['updatedAt'],
      deletedAt: json['deletedAt'] 
          ,
      createdAt: json['createdAt'] 
          ,
      deleted: json['deleted'] as bool?,
    );
  }

  // Method to convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'montant': montant,
      'periode': periode,
      'receiverTelephone': receiverTelephone,
      'senderTelephone': senderTelephone,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
      'createdAt': createdAt,
      'deleted': deleted,
    };
  }

  // Reactive getters for GetX
  final _montant = 0.0.obs;
  final _periode = ''.obs;
  final _receiverTelephone = ''.obs;
  final _senderTelephone = ''.obs;
  final _deleted = false.obs;

  double get reactiveMontant => _montant.value;
  set reactiveMontant(double value) => _montant.value = value;

  String get reactivePeriode => _periode.value;
  set reactivePeriode(String value) => _periode.value = value;

  String get reactiveReceiverTelephone => _receiverTelephone.value;
  set reactiveReceiverTelephone(String value) => _receiverTelephone.value = value;

  String get reactiveSenderTelephone => _senderTelephone.value;
  set reactiveSenderTelephone(String value) => _senderTelephone.value = value;

  bool get reactiveDeleted => _deleted.value;
  set reactiveDeleted(bool value) => _deleted.value = value;
}
