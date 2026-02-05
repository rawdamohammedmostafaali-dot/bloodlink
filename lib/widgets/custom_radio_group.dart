import 'package:flutter/material.dart';
class CustomRadioGroup extends StatelessWidget {
  final String groupValue;
  final void Function(String) onChanged;
  const CustomRadioGroup({
    required this.groupValue,
    required this.onChanged,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "نوع المستخدم",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          RadioListTile(
            title: const Text("متبرع"),
            value: "donor",
            groupValue: groupValue,
            onChanged: (val) => onChanged(val!),
          ),
          RadioListTile(
            title: const Text("مريض"),
            value: "patient",
            groupValue: groupValue,
            onChanged: (val) => onChanged(val!),
          ),
        ],
      ),
    );
  }
}

