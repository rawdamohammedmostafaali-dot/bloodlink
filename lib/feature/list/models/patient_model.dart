class PatientModel {
  final String id;
  final String name;
  final String bloodType;
  final String location;

  PatientModel({required this.id, required this.name, required this.bloodType, required this.location});
  factory PatientModel.fromMap(String id, Map<String, dynamic> map) {
    return PatientModel(
      id: id,
      name: map['name'] ?? 'بدون اسم',
      bloodType: map['bloodType'] ?? '?',
      location: map['location'] ?? 'غير محدد',
    );
  }
}