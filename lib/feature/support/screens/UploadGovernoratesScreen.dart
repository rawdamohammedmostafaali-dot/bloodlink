import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadGovernoratesScreen extends StatefulWidget {
  const UploadGovernoratesScreen({super.key});

  @override
  State<UploadGovernoratesScreen> createState() => _UploadGovernoratesScreenState();
}

class _UploadGovernoratesScreenState extends State<UploadGovernoratesScreen> {
  bool isUploading = false;

  final List<Map<String, dynamic>> governorates = [
  {"name": "القاهرة", "hospitals": ["مستشفى الدم الرئيسي", "مستشفى النيل التخصصي", "مركز الدم السادس من أكتوبر"]},
{"name": "الجيزة", "hospitals": ["مستشفى الجيزة العام", "مركز الدم الجيزة", "مستشفى الملك فيصل"]},
{"name": "الإسكندرية", "hospitals": ["مستشفى سموحة", "مستشفى الإسكندرية العام", "مركز الدم الإسكندرية"]},
{"name": "الدقهلية", "hospitals": ["مستشفى المنصورة العام", "مستشفى دم المنصورة"]},
{"name": "البحيرة", "hospitals": ["مستشفى دمنهور المركزي", "مستشفى أبو حمص"]},
{"name": "المنوفية", "hospitals": ["مستشفى شبين الكوم العام", "مركز الدم المنوفية"]},
{"name": "الغربية", "hospitals": ["مستشفى طنطا العام", "مركز الدم الغربية"]},
{"name": "القليوبية", "hospitals": ["مستشفى بنها العام", "مركز الدم القليوبية"]},
{"name": "الشرقية", "hospitals": ["مستشفى الزقازيق العام", "مركز الدم الشرقية"]},
{"name": "السويس", "hospitals": ["مستشفى السويس العام", "مركز الدم السويس"]},
{"name": "الإسماعيلية", "hospitals": ["مستشفى الإسماعيلية العام", "مركز الدم الإسماعيلية"]},
{"name": "بني سويف", "hospitals": ["مستشفى بني سويف العام", "مركز الدم بني سويف"]},
{"name": "الفيوم", "hospitals": ["مستشفى الفيوم العام", "مركز الدم الفيوم"]},
{"name": "المنيا", "hospitals": ["مستشفى المنيا العام", "مركز الدم المنيا"]},
{"name": "أسيوط", "hospitals": ["مستشفى أسيوط العام", "مركز الدم أسيوط"]},
{"name": "سوهاج", "hospitals": ["مستشفى سوهاج العام", "مركز الدم سوهاج"]},
{"name": "قنا", "hospitals": ["مستشفى قنا العام", "مركز الدم قنا"]},
{"name": "الأقصر", "hospitals": ["مستشفى الأقصر العام", "مركز الدم الأقصر"]},
{"name": "أسوان", "hospitals": ["مستشفى أسوان العام", "مركز الدم أسوان"]},
{"name": "البحر الأحمر", "hospitals": ["مستشفى الغردقة العام", "مركز الدم البحر الأحمر"]},
{"name": "الوادي الجديد", "hospitals": ["مستشفى الخارجة العام", "مركز الدم الوادي الجديد"]},
{"name": "شمال سيناء", "hospitals": ["مستشفى العريش العام", "مركز الدم شمال سيناء"]},
{"name": "جنوب سيناء", "hospitals": ["مستشفى شرم الشيخ", "مركز الدم جنوب سيناء"]},
{"name": "مطروح", "hospitals": ["مستشفى مرسى مطروح", "مركز الدم مطروح"]}
];

  Future<void> uploadGovernorates() async {
    setState(() => isUploading = true);
    final firestore = FirebaseFirestore.instance;

    try {
      for (var gov in governorates) {
        await firestore.collection('governorates').doc(gov['name']).set({
          'name': gov['name'],
          'hospitals': gov['hospitals'],
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم رفع كل المحافظات والمستشفيات ✅")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ: $e")));
    } finally {
      setState(() => isUploading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("رفع المحافظات والمستشفيات"), backgroundColor: Colors.red),
      body: Center(
        child: ElevatedButton(
          onPressed: isUploading ? null : uploadGovernorates,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
          child: isUploading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("رفع البيانات على Firestore", style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
