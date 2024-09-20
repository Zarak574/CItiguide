import 'dart:convert'; // For base64Encode
import 'dart:io' as io; // Import io for mobile
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http; // For web image handling

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final picker = ImagePicker();
  final _textController = TextEditingController();
  bool _isUploading = false;
  XFile? _selectedFile;
  String? _previewUrl;

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    try {
      String fileName = '${DateTime.now().toString()}_${_selectedFile!.name}';
      Reference storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');

      if (kIsWeb) {
        final uploadTask = storageRef.putData(await _selectedFile!.readAsBytes());
        await uploadTask.whenComplete(() async {
          final url = await storageRef.getDownloadURL();
          await _addPostToFirestore(url);
        });
      } else {
        final file = io.File(_selectedFile!.path);
        final uploadTask = storageRef.putFile(file);
        await uploadTask.whenComplete(() async {
          final url = await storageRef.getDownloadURL();
          await _addPostToFirestore(url);
        });
      }
    } catch (e) {
      print('Error uploading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload file.')));
    }
  }

  Future<void> _addPostToFirestore(String? url) async {
    final data = {
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': [],
    };

    if (url != null) {
      data['url'] = url;
    }
    if (_textController.text.trim().isNotEmpty) {
      data['content'] = _textController.text.trim();
    }

    try {
      await FirebaseFirestore.instance.collection('posts').add(data);
      Navigator.of(context).pop(); // Go back to previous screen
    } catch (e) {
      print('Failed to add post: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add post.')));
    }
  }

  Future<void> _chooseFile(String type) async {
    XFile? file;
    if (type == 'image') {
      file = await picker.pickImage(source: ImageSource.gallery);
    } else if (type == 'video') {
      file = await picker.pickVideo(source: ImageSource.gallery);
    }

    if (file != null) {
      setState(() {
        _selectedFile = file;
        _previewUrl = null; // Reset preview URL
      });

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        setState(() {
          _previewUrl = 'data:image/${file?.name.split('.').last};base64,$base64String';
        });
      } else {
        setState(() {
          _previewUrl = file?.path;
        });
      }
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _previewUrl = null;
    });
  }

  Future<void> _submitPost() async {
    setState(() {
      _isUploading = true;
    });

    try {
      if (_selectedFile != null) {
        await _uploadFile();
      } else if (_textController.text.trim().isNotEmpty) {
        await _addPostToFirestore(null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No content to upload.')));
      }
    } catch (e) {
      print('Failed to add post: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add post.')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isUploading)
              const Center(child: CircularProgressIndicator()),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all( color: Colors.grey.shade300, width: 1),
              ),
              constraints: BoxConstraints(
                maxWidth: 400, 
                maxHeight: 300, 
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Write something...',
                        border: InputBorder.none, 
                      ),
                      style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                      maxLines: 2,
                    ),
                  ),
                  Expanded(
                    child: _previewUrl != null
                        ? kIsWeb
                            ? Image.network(
                                _previewUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Image.file(
                                io.File(_previewUrl!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                        : Container(), 
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _chooseFile('image');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.image, color: Color(0xFF56C6D3),),
                  label: Text('Select Image', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    _chooseFile('video');
                  },
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.video_collection, color: Color(0xFF56C6D3),),
                  label: Text('Select Video', style: TextStyle(color:Theme.of(context).colorScheme.inversePrimary)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Center(
            //   child: 
            ElevatedButton(
                onPressed: _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF8340),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Upload', style: TextStyle(color: Colors.white, fontSize: 16),),
              ),
            // ),
          ],
        ),
      ),
    );
  }
}
