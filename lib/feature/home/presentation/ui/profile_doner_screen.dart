/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:intl/intl.dart';

class DonorProfileScreen extends StatefulWidget {
  const DonorProfileScreen({super.key});

  @override
  State<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  String formatDate(DateTime? date) {
    if (date == null) return 'Not available';
    return DateFormat('dd / MM / yyyy').format(date);
  }

  int daysSince(DateTime date) => DateTime.now().difference(date).inDays;
  int monthsSince(DateTime date) => (daysSince(date) / 30).floor();
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
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: bloodController, decoration: const InputDecoration(labelText: "Blood Type")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(uid).update({
                'name': nameController.text,
                'bloodType': bloodController.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> addDonation() async {
    final now = DateTime.now();

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'lastDonationDate': Timestamp.fromDate(now),
    });
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userName = userDoc.data()?['name'] ?? 'Unknown';
    final bloodType = userDoc.data()?['bloodType'] ?? '';

    await FirebaseFirestore.instance.collection('donation_history').add({
      'donorId': uid,
      'donorName': userName,
      'bloodType': bloodType,
      'date': Timestamp.fromDate(now),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), backgroundColor: Colors.red, centerTitle: true),
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
          final Timestamp? lastDonationTimestamp = user['lastDonationDate'];

          DateTime? lastDonationDate;
          int days = 0;
          int months = 0;
          double progress = 0;
          bool canDonate = true;

          if (lastDonationTimestamp != null) {
            lastDonationDate = lastDonationTimestamp.toDate();
            days = daysSince(lastDonationDate);
            months = monthsSince(lastDonationDate);
            progress = (days / 90).clamp(0.0, 1.0);
            canDonate = days >= 90;
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
              Text("🩸 Blood Type: $bloodType", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              const Text("👤 Donor", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Last Donation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(lastDonationDate != null
                          ? "📅 ${formatDate(lastDonationDate)}"
                          : "No donations yet"),
                      if (lastDonationDate != null) ...[
                        const SizedBox(height: 6),
                        Text("⏳ $days days (~ $months months ago)"),
                      ],
                      const SizedBox(height: 16),
                      const Text("Progress towards next donation"),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade300,
                          color: canDonate ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        canDonate ? "✅ Ready to donate" : "❌ ${90 - days} days remaining",
                        style: TextStyle(color: canDonate ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.favorite),
                  label: const Text("Add Donation"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canDonate ? Colors.red : Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: canDonate
                      ? () async {
                    await addDonation();
                  }
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}*/