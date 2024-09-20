import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:rolebase/widgets/bottom_navigation.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {

    int _currentIndex = 3;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  
  late User? _user;
  Map<String, dynamic>? _userData;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController= TextEditingController();

  XFile? pickedFile;
  late Uint8List imageBytes;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (_user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get();

        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>?;
          if (_userData != null) {
            _usernameController.text = _userData!['username'] ?? '';
            _bioController.text = _userData!['bio'] ?? '';
            _emailController.text = _user!.email ?? '';
          }
        });
      } catch (e) {
        print('Failed to fetch user data: $e');
      }
    }
  }

  Future<void> _updateUserData() async {
    if (_user != null) {
      try {
        // Update username
        await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({
          'username': _usernameController.text,
          'bio': _bioController.text,
        });

        // await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({
        //   'bio': _bioController.text,
        // });

        // Handle email update
        if (_emailController.text != _user!.email) {
          await _user!.updateEmail(_emailController.text);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        print('Failed to update user data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        pickedFile = pickedImage;
      });

      // Read the file as bytes
      imageBytes = await pickedFile!.readAsBytes();
      await _uploadImage(); // Upload the image and refresh data
    } else {
      print('No image selected.');
    }
  }

  Future<void> _uploadImage() async {
    if (pickedFile != null) {
      try {
        String imageUrl = await uploadImageToFirebase(imageBytes);

        // Update Firestore with image URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .update({'profile_picture': imageUrl});

        // Refresh user data to reflect changes
        await _fetchUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
      } catch (error) {
        print('Failed to upload image: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload profile picture')),
        );
      }
    }
  }

  Future<String> uploadImageToFirebase(Uint8List imageBytes) async {
    try {
      String filename = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images')
          .child(filename);

      await ref.putData(imageBytes);

      String imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } catch (error) {
      print('Error uploading image to Firebase Storage: $error');
      throw error;
    }
  }

  void _showEditDialog(String fieldType) {
    TextEditingController controller;
    String title;
    String initialValue;

    if (fieldType == 'username') {
      controller = _usernameController;
      title = 'Edit Username';
      initialValue = _usernameController.text;
    } else if(fieldType == 'bio'){
      controller = _bioController;
      title = 'Edit Bio';
      initialValue = _bioController.text;
    } else {
      controller = _emailController;
      title = 'Edit Email';
      initialValue = _emailController.text;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.background, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),  
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter new $fieldType',
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF56C6D3),  
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF56C6D3), 
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF56C6D3), 
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFFFF8340),  
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _updateUserData();
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF56C6D3), 
              ),
            ),
          ),
        ],
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _userData != null
          ? Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFF8340), width: 4),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _userData!['profile_picture'] != null
                                ? NetworkImage(_userData!['profile_picture'])
                                : null,
                            child: _userData!['profile_picture'] == null
                                ? Icon(Icons.person, size: 60, color: Colors.grey[700])
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: -5, 
                          right: -5,  
                          child: InkWell(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),  
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF8340),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.add_a_photo, size: 20, color: Colors.white), 
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Username',  
                          style: TextStyle(
                            fontSize: 16, 
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        const SizedBox(height: 2),  
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,  
                                ),
                                enabled: false,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF56C6D3)),
                              onPressed: () => _showEditDialog('username'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',  
                          style: TextStyle(
                            fontSize: 16,  
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        const SizedBox(height: 4),  
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,  
                                ),
                                enabled: false,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF56C6D3)),
                              onPressed: () => _showEditDialog('email'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bio',  
                          style: TextStyle(
                            fontSize: 16,  
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        const SizedBox(height: 4),  
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _bioController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,  
                                ),
                                enabled: false,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF56C6D3)),
                              onPressed: () => _showEditDialog('bio'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: _updateUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF56C6D3),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
          )
          

          : const Center(child: CircularProgressIndicator()),
          
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      )
    );
  }
}
