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
    {
      "name": "القاهرة",
      "hospitals": ["مستشفى القصر العيني", "مستشفى الهلال الأحمر", "مركز الدم الرئيسي"]
    },
    {
      "name": "الجيزة",
      "hospitals": ["مستشفى إمبابة العام", "مستشفى أم المصريين", "مركز الدم بالهرم"]
    },
    {
      "name": "الإسكندرية",
      "hospitals": ["مستشفى الإسكندرية العام", "مستشفى قصر الشاطئ", "مركز الدم الرئيسي بالإسكندرية"]
    },
    {
      "name": "السويس",
      "hospitals": ["مستشفى السويس العام", "مركز الدم السويس"]
    },
    {
      "name": "بورسعيد",
      "hospitals": ["مستشفى بورسعيد العام", "مركز الدم بورسعيد"]
    },
    {
      "name": "المنصورة",
      "hospitals": ["مستشفى المنصورة العام", "مركز الدم بالمنصورة"]
    },
    {
      "name": "أسوان",
      "hospitals": ["مستشفى أسوان العام", "مركز الدم بأسوان"]
    },
    {
      "name": "الأقصر",
      "hospitals": ["مستشفى الأقصر العام", "مركز الدم بالأقصر"]
    },
    {
      "name": "سوهاج",
      "hospitals": ["مستشفى سوهاج العام", "مركز الدم بسوهاج"]
    },
    {
      "name": "أسيوط",
      "hospitals": ["مستشفى أسيوط العام", "مركز الدم بأسيوط"]
    },
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
        const SnackBar(content: Text("تم رفع كل المحافظات والمستشفيات على Firestore ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ: $e")),
      );
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
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: isUploading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("رفع البيانات على Firestore", style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
