/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  int daysSince(DateTime date) => DateTime.now().difference(date).inDays;

  Future<String> uploadProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return "";

    final ref = FirebaseStorage.instance.ref().child("profile_images/$uid.jpg");
    await ref.putFile(File(picked.path));
    return await ref.getDownloadURL();
  }

  void editProfile(Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['name']);
    final bloodController = TextEditingController(text: user['bloodType']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تعديل البيانات"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "الاسم")),
            TextField(controller: bloodController, decoration: const InputDecoration(labelText: "فصيلة الدم")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(uid).update({
                'name': nameController.text,
                'bloodType': bloodController.text,
              });
              Navigator.pop(context);
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الملف الشخصي"), backgroundColor: Colors.red, centerTitle: true),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!.data()!;
          final String name = user['name'] ?? '';
          final String bloodType = user['bloodType'] ?? '';
          final String? imageUrl = user['profileImage'];
          final Timestamp? lastRequestTimestamp = user['lastRequestDate'];

          DateTime? lastRequestDate;
          int days = 0;

          if (lastRequestTimestamp != null) {
            lastRequestDate = lastRequestTimestamp.toDate();
            days = daysSince(lastRequestDate);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GestureDetector(
                onTap: () async {
                  final url = await uploadProfileImage();
                  if (url.isNotEmpty) {
                    await FirebaseFirestore.instance.collection('users').doc(uid).update({'profileImage': url});
                  }
                },
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.red.shade100,
                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                  child: imageUrl == null ? const Icon(Icons.person, size: 60, color: Colors.red) : null,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => editProfile(user), icon: const Icon(Icons.edit, color: Colors.red)),
                ],
              ),
              Text("🩸 فصيلة الدم: $bloodType", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              const Text("👤 مريض", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("آخر طلب دم", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (lastRequestDate != null) ...[
                        Text("📅 ${DateFormat('dd / MM / yyyy').format(lastRequestDate)}"),
                        const SizedBox(height: 6),
                        Text("⏳ مرّ $days يوم على آخر طلب"),
                      ] else
                        const Text("لم يتم تقديم أي طلب دم بعد"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.bloodtype),
                  label: const Text("طلب دم جديد"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
*/