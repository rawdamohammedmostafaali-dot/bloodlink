
class BloodRequestModel {
  final String bloodType;
  final int amount;
  final String hospital;
  final String governorate;
  final String status;

  BloodRequestModel({
    required this.bloodType,
    required this.amount,
    required this.hospital,
    required this.governorate,
    required this.status,
  });

  factory BloodRequestModel.fromMap(Map<String, dynamic> map) {
    return BloodRequestModel(
      bloodType: map['bloodType'] ?? '-',
      amount: map['amount'] ?? 0,
      hospital: map['hospital'] ?? '-',
      governorate: map['governorate'] ?? '-',
      status: map['status'] ?? 'قيد الانتظار',
    );
  }
}
