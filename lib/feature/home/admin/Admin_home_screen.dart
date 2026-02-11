import 'package:flutter/material.dart';
import '../../support/screens/add_staff_screen.dart';
import '../../support/screens/staff_list_screen.dart';
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "قطرة دم",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE5E5), Color(0xFFFF7F7F)], // خلفية وردي فاتح إلى أحمر دافئ
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddStaffScreen()),
                    );
                  },
                  icon: const Icon(Icons.person_add, size: 28,color: Colors.black87,),
                  label: const Text(
                    "إضافة موظف",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.black87),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: Colors.red.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    shadowColor: Colors.black26,
                    elevation: 6,
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StaffListScreen()),
                    );
                  },
                  icon: const Icon(Icons.list_alt, size: 28,color: Colors.black87,),
                  label: const Text(
                    "قائمة الموظفين",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.black87),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: Colors.pink.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    shadowColor: Colors.black26,
                    elevation: 6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
