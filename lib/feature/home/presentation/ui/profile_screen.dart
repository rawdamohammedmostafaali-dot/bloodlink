/*import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()?['imageUrl'] != null) {
        setState(() {
          _imageUrl = doc.data()?['imageUrl'];
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'قص الصورة',
            toolbarColor: Colors.red,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
        ],
      );

      if (cropped != null) {
        File file = File(cropped.path);
        setState(() {
          _image = file;
        });
        await _uploadImage(file);
      }
    }
  }
  Future<void> _uploadImage(File file) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _storage.ref().child('profile_images/${user.uid}.jpg');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    await _firestore.collection('users').doc(user.uid).set({
      'imageUrl': url,
    }, SetOptions(merge: true));

    setState(() {
      _imageUrl = url;
    });
  }
  void _removeImage() async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (_imageUrl != null) {
      try {
        await _storage.refFromURL(_imageUrl!).delete();
      } catch (_) {}
    }
    await _firestore.collection('users').doc(user.uid).set({
      'imageUrl': null,
    }, SetOptions(merge: true));

    setState(() {
      _image = null;
      _imageUrl = null;
    });
  }
  void _showOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.red),
              title: const Text("التقاط صورة"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.red),
              title: const Text("اختيار من المعرض"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_image != null || _imageUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("حذف الصورة"),
                onTap: () {
                  Navigator.pop(context);
                  _removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.red.shade100,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : (_imageUrl != null ? NetworkImage(_imageUrl!) : null) as ImageProvider<Object>?,
                    child: (_image == null && _imageUrl == null)
                        ? const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.red,
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _showOptions,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.red,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Center(
              child: Text(
                "اسم المستخدم",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                "متبرع",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "البيانات الأساسية",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _infoTile(Icons.bloodtype, "فصيلة الدم", "O+"),
            _infoTile(Icons.phone, "رقم الهاتف", "010xxxxxxxx"),
            _infoTile(Icons.location_on, "المحافظة", "القاهرة"),
            _infoTile(Icons.person_outline, "النوع", "متبرع"),

            const SizedBox(height: 16),
            const Text(
              "معلومات التبرع",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _infoTile(Icons.calendar_today, "آخر تبرع", "منذ 3 شهور"),
            _infoTile(Icons.repeat, "عدد مرات التبرع", "5 مرات"),
            _infoTile(Icons.health_and_safety, "متاح للتبرع", "نعم"),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.logout),
                label: const Text("تسجيل الخروج"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
*/