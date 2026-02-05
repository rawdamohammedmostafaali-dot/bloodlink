import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_faq_screen.dart';

class SupportScreen extends StatelessWidget {
  final bool isAdmin;
  const SupportScreen({super.key, required this.isAdmin});
  final String phoneNumber = "01012345678";
  final String emailAddress = "support@example.com";
  final String whatsappNumber = "201012345678";

  Future<void> _launchPhone() async {
    final Uri url = Uri.parse("tel:$phoneNumber");
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }

  Future<void> _launchEmail() async {
    final Uri url = Uri.parse("mailto:$emailAddress");
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }

  Future<void> _launchWhatsApp() async {
    final String message = Uri.encodeComponent("مرحبًا، أحتاج دعم من تطبيق قطرة دم");
    final Uri url = Uri.parse("https://wa.me/$whatsappNumber?text=$message");
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }

  void _goToAddFaq(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddFaqScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الدعم"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ContactButton(
                  icon: Icons.phone,
                  label: "اتصال",
                  color: Colors.green,
                  onTap: _launchPhone,
                ),
                _ContactButton(
                  icon: Icons.email,
                  label: "بريد",
                  color: Colors.blue,
                  onTap: _launchEmail,
                ),
                _ContactButton(
                  icon: FontAwesomeIcons.whatsapp,

                  label: "واتساب",
                  color: Colors.greenAccent.shade700,
                  onTap: _launchWhatsApp,
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("إضافة سؤال جديد"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _goToAddFaq(context),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "يمكنك التواصل معنا عبر أي من الخيارات أعلاه لطلب الدعم أو الاستفسار عن التطبيق.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
