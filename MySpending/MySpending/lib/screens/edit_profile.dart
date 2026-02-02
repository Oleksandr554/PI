import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_data.dart';

class EditProfileScreen extends StatefulWidget {
  final UserData userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  String? newImagePath;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.userData.username);
    _emailCtrl = TextEditingController(text: widget.userData.email);
    newImagePath = widget.userData.imagePath;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        newImagePath = file.path;
      });
    }
  }

  void _save() {
    widget.userData.username = _nameCtrl.text;
    widget.userData.email = _emailCtrl.text;
    widget.userData.imagePath = newImagePath;

    Navigator.pop(context, true);
  }
  
  Widget _smallBtn(IconData icon, {VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(width: 1.5, color: Colors.black),
      ),
      child: Icon(icon, size: 20),
    )
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  backgroundColor: const Color(0xFFDCEAF2),
  elevation: 0,
  leading: Padding(
  padding: const EdgeInsets.all(12),
  child: _smallBtn(
    Icons.arrow_back,
    onTap: () => Navigator.pop(context),
  ),
),

  title: const Text("Edit profile",
      style: TextStyle(color: Colors.black,fontSize: 24, fontWeight: FontWeight.w500)),
),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
  onTap: _pickImage,
  child: Container(
    width: 110,
    height: 110,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,

        ),
      ],
    ),
    child: ClipOval(
      child: newImagePath != null
          ? Image.file(
              File(newImagePath!),
              fit: BoxFit.cover,
            )
          : const Icon(
              Icons.person,
              size: 60,
              color: Colors.black54,
            ),
    ),
  ),
),

            const SizedBox(height: 20),

            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _save,
              child: const Text("Save",
              style: TextStyle(color: Color(0xFF000000))),),
          ],
        ),
      ),
    );
  }
}
