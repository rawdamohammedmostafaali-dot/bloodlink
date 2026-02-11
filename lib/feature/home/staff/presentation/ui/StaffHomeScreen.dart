import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../support/screens/add_donor_screen.dart';
import '../../cubit/staff_home_cubit.dart';
import '../../cubit/staff_home_state.dart';

class Staffhomescreen extends StatefulWidget {
  late final String staffName;
  Staffhomescreen({super.key, required this.staffName});

  @override
  State<Staffhomescreen> createState() => _StaffHomeWrapperState();
}

class _StaffHomeWrapperState extends State<Staffhomescreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      StaffHomeScreen(staffName: widget.staffName),
      NotificationsScreen(),
    ];
    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Scaffold(
        body: pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Colors.pinkAccent,
          unselectedItemColor: Colors.white70,
          backgroundColor: Colors.red[400],
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'الإشعارات',
            ),
          ],
        ),
      ),
    );
  }
}

class StaffHomeScreen extends StatelessWidget {
  final String staffName;
  const StaffHomeScreen({super.key, required this.staffName});

  Widget dataCard({required IconData icon, required String title, required int count}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xffff5e7e), Color(0xffff91a1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 36, color: Colors.white),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StaffHomeCubit()..fetchData(),
      child: BlocBuilder<StaffHomeCubit, StaffHomeState>(
        builder: (context, state) {
          if (state is StaffHomeLoading) return const Center(child: CircularProgressIndicator());
          if (state is StaffHomeError) return Center(child: Text(state.error));

          if (state is StaffHomeLoaded) {
            return Container(
              color: const Color(0xffff91a1),
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'قطرة دم',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 20),
                            dataCard(icon: Icons.people, title: 'عدد المتبرعين', count: state.donorsCount ?? 0),
                            const SizedBox(height: 16),
                            dataCard(icon: Icons.bloodtype, title: 'عدد طلبات الدم', count: state.requestsCount ?? 0),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text(
                                'إضافة متبرع',
                                style: TextStyle(color: Colors.white, decoration: TextDecoration.none),
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDonorScreen()));
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              icon: const Icon(Icons.notifications, color: Colors.white),
                              label: const Text(
                                'الإشعارات',
                                style: TextStyle(color: Colors.white, decoration: TextDecoration.none),
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> notifications = [
    {'text': 'طلب دم جديد من المريض أحمد', 'isNew': true},
    {'text': 'المتبرع محمد حجز للتبرع غدًا', 'isNew': true},
    {'text': 'تم قبول طلب الدم السابق', 'isNew': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffff1f4),
      appBar: AppBar(
        title: const Text(
          'الإشعارات',
          style: TextStyle(decoration: TextDecoration.none),
        ),
        backgroundColor: const Color(0xffe84c6a),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          final bool isNew = notif['isNew'];

          return Dismissible(
            key: ValueKey(notif['text']),
            direction: DismissDirection.horizontal,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) {
              setState(() {
                notifications.removeAt(index);
              });
            },
            child: Card(
              color: isNew ? const Color(0xffffe6eb) : Colors.white,
              elevation: isNew ? 3 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    if (isNew)
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    const Icon(Icons.notifications, color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        notif['text'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isNew ? FontWeight.bold : FontWeight.normal,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
