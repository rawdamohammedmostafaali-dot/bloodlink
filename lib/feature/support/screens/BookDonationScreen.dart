import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookDonationScreen extends StatefulWidget {
  const BookDonationScreen({super.key});

  @override
  State<BookDonationScreen> createState() => _BookDonationScreenState();
}

class _BookDonationScreenState extends State<BookDonationScreen> {
  String? selectedGovernorate;
  String? selectedHospital;
  Map<String, List<String>> hospitalsByGovernorate = {};
  bool isLoading = true;

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

  @override
  void initState() {
    super.initState();
    addGovernoratesIfEmpty().then((_) => fetchGovernorates());
  }

  Future<void> addGovernoratesIfEmpty() async {
    final collection =
    FirebaseFirestore.instance.collection('governorates');
    final snapshot = await collection.get();

    if (snapshot.docs.isEmpty) {
      for (var gov in governorates) {
        await collection.add(gov);
      }
    }
  }

  Future<void> fetchGovernorates() async {
    setState(() => isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('governorates')
          .get();

      Map<String, List<String>> data = {};

      for (var doc in snapshot.docs) {
        String name = doc['name'];
        List<String> hospitals =
        List<String>.from(doc['hospitals'] ?? []);
        data[name] = hospitals;
      }

      setState(() {
        hospitalsByGovernorate = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text("حدث خطأ أثناء تحميل البيانات: $e"),
        ),
      );
    }
  }

  Future<void> showConfirmationDialog() async {
    bool? donatedToday;
    bool? hasMedicalIssue;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("تأكيد التبرع"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("هل تبرعت اليوم؟"),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text("نعم"),
                          value: true,
                          groupValue: donatedToday,
                          onChanged: (val) {
                            setStateDialog(() {
                              donatedToday = val;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text("لا"),
                          value: false,
                          groupValue: donatedToday,
                          onChanged: (val) {
                            setStateDialog(() {
                              donatedToday = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                      "هل لديك أي مانع طبي يمنع التبرع؟"),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text("نعم"),
                          value: true,
                          groupValue: hasMedicalIssue,
                          onChanged: (val) {
                            setStateDialog(() {
                              hasMedicalIssue = val;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text("لا"),
                          value: false,
                          groupValue: hasMedicalIssue,
                          onChanged: (val) {
                            setStateDialog(() {
                              hasMedicalIssue = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: (donatedToday != null &&
                      hasMedicalIssue != null)
                      ? () async {
                    if (donatedToday ==
                        false &&
                        hasMedicalIssue ==
                            false) {
                      await FirebaseFirestore
                          .instance
                          .collection(
                          'bookings')
                          .add({
                        "governorate":
                        selectedGovernorate,
                        "hospital":
                        selectedHospital,
                        "status":
                        "confirmed",
                        "donatedToday":
                        donatedToday,
                        "date":
                        DateTime.now(),
                      });

                      Navigator.of(context)
                          .pop();

                      ScaffoldMessenger.of(
                          context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                              "تم تأكيد الحجز بنجاح!"),
                        ),
                      );
                    } else {
                      await FirebaseFirestore
                          .instance
                          .collection(
                          'bookings')
                          .add({
                        "governorate":
                        selectedGovernorate,
                        "hospital":
                        selectedHospital,
                        "status":
                        "canceled",
                        "donatedToday":
                        donatedToday,
                        "date":
                        DateTime.now(),
                      });

                      Navigator.of(context)
                          .pop();

                      ScaffoldMessenger.of(
                          context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                              "تم إلغاء الحجز بسبب الحالة."),
                        ),
                      );
                    }
                  }
                      : null,
                  style: ElevatedButton
                      .styleFrom(
                      backgroundColor:
                      Colors.red),
                  child:
                  const Text("تأكيد"),
                )
              ],
            );
          },
        );
      },
    );
  }

  Widget buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((e) =>
          DropdownMenuItem(
              value: e,
              child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> hospitals =
    selectedGovernorate != null
        ? hospitalsByGovernorate[
    selectedGovernorate] ??
        []
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'حجز موعد التبرع'),
        backgroundColor: Colors.red,
      ),
      body: isLoading
          ? const Center(
          child:
          CircularProgressIndicator())
          : Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .stretch,
          children: [
            const Text(
                "اختر المحافظة"),
            const SizedBox(
                height: 8),
            buildDropdown(
              value:
              selectedGovernorate,
              items:
              hospitalsByGovernorate
                  .keys
                  .toList(),
              hint:
              "اختر المحافظة",
              onChanged: (val) {
                setState(() {
                  selectedGovernorate =
                      val;
                  selectedHospital =
                  null;
                });
              },
            ),
            const SizedBox(
                height: 20),
            const Text(
                "اختر المستشفى"),
            const SizedBox(
                height: 8),
            buildDropdown(
              value:
              selectedHospital,
              items: hospitals,
              hint:
              "اختر المستشفى",
              onChanged: (val) {
                setState(() {
                  selectedHospital =
                      val;
                });
              },
            ),
            const SizedBox(
                height: 30),
            ElevatedButton(
              onPressed:
              selectedGovernorate !=
                  null &&
                  selectedHospital !=
                      null
                  ? showConfirmationDialog
                  : null,
              style: ElevatedButton
                  .styleFrom(
                backgroundColor:
                Colors.red,
                padding:
                const EdgeInsets
                    .symmetric(
                    vertical: 16),
              ),
              child: const Text(
                "تأكيد الحجز",
                style: TextStyle(
                    fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
