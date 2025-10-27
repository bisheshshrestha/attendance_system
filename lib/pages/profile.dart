import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api_services/person.dart';
import '../api_services/person_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Person? user;
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final fetchedUser = await PersonService().getPerson();
    setState(() {
      user = fetchedUser;
    });
  }

  Future<void> pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source);
    Navigator.pop(context);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const CircularProgressIndicator();
    return Scaffold(
      backgroundColor: const Color(0xFF070046),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070046),
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          children: [
            // Profile Picture
            Center(
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: const Color(0xFF152874),
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Choose image source",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await pickImage(ImageSource.camera);
                                },
                                icon: const Icon(Icons.camera_alt,
                                    size: 60, color: Colors.white),
                              ),
                              const SizedBox(width: 35),
                              IconButton(
                                onPressed: () async {
                                  await pickImage(ImageSource.gallery);
                                },
                                icon: const Icon(Icons.image,
                                    size: 60, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: selectedImage != null
                          ? FileImage(selectedImage!)
                          : null,
                      child: selectedImage == null
                          ? const Icon(Icons.person,
                          size: 70, color: Color(0xFF070046))
                          : null,
                    ),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF1E88E5),
                      child: const Icon(Icons.edit,
                          color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // User Info
            Text(
              user!.username,
              style: const TextStyle(
                color: Color(0xFF1E88E5),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              user!.email,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Container(width: 240, height: 3, color: Colors.white54),
            const SizedBox(height: 25),
            buildTextField(label: "Name", value: user!.name),
            const SizedBox(height: 15),
            buildTextField(label: "Working branch", value: "Cairo"),
            const SizedBox(height: 15),
            buildTextField(label: "Major", value: "IT"),
            const SizedBox(height: 15),
            buildTextField(label: "Birthday", value: user!.birthday),
          ],
        ),
      ),
    );
  }

  Widget buildTextField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF152874),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextFormField(
            initialValue: value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: const InputDecoration(
              suffixIcon: Icon(Icons.edit, color: Colors.white70),
              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
