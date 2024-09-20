import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:ionicons/ionicons.dart';
import 'package:rolebase/widgets/app_bar.dart';
import 'package:rolebase/widgets/custom_dropdown.dart';
import 'package:rolebase/widgets/custom_icon_button.dart';
import 'package:rolebase/widgets/my_drawer.dart';

class InsertRecordForm extends StatefulWidget {
  @override
  _InsertRecordFormState createState() => _InsertRecordFormState();
}

class _InsertRecordFormState extends State<InsertRecordForm> {
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  late String selectedCategory = ''; 
  TextEditingController descriptionController = TextEditingController();
  TextEditingController imageUrlController = TextEditingController();
  TextEditingController latitudeController= TextEditingController();
  TextEditingController longitudeController = TextEditingController();
 late String selectedCityCategory = ''; 
  List<String> filteredCityCategories = [];
  List<String> filteredCategories = [];
  XFile? pickedFile;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  UploadTask? _uploadTask;
  Uint8List? imageBytes;
  String? selectedRecordKey;

  @override
  void initState() {
    super.initState();
    loadCategories();
    loadCityCategories();
  }

Future<void> _pickImage() async {
  final picker = ImagePicker();
  final pickedImage = await picker.pickImage(source: ImageSource.gallery);

  if (pickedImage != null) {
    setState(() {
      pickedFile = pickedImage;
    });

    imageBytes = await pickedFile!.readAsBytes();
  } else {
    print('No image selected.');
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

  void _startUpload(Uint8List imageBytes) {
    String filename =
        DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';

    setState(() {
      _uploadTask = _storage.ref().child(filename).putData(imageBytes);
    });

    _uploadTask!.then((taskSnapshot) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image uploaded successfully")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading image: $error")),
      );
    });
  }


 Future<void> loadCityCategories() async {
    try {
      DatabaseEvent snapshot = await databaseReference.child('city').once();

      if (snapshot.snapshot != null &&
          snapshot.snapshot.value != null &&
          snapshot.snapshot.value is List<dynamic>) {
        List<String> cityCategories = (snapshot.snapshot.value as List<dynamic>)
            .where((category) => category != null)
            .cast<String>()
            .toSet()
            .toList();

        setState(() {
          filteredCityCategories = cityCategories;
          if (!cityCategories.contains(selectedCityCategory)) {
            selectedCityCategory = cityCategories.isNotEmpty ? cityCategories.first : '';
          }
        });
      } else {
        print('No city categories found or invalid data format');
      }
    } catch (error) {
      print('Error loading city categories: $error');
    }
  }

void onCategorySelected(String? value) {
  setState(() {
    selectedCategory = value ?? '';
  });
}

Future<void> loadCategories() async {
  try {
    DatabaseEvent snapshot = await databaseReference.child('categories').once();

    if (snapshot.snapshot != null &&
        snapshot.snapshot.value != null &&
        snapshot.snapshot.value is List<dynamic>) {
      List<String> categories = (snapshot.snapshot.value as List<dynamic>)
          .where((category) => category != null)
          .cast<String>()
          .toSet() 
          .toList();

      setState(() {
        filteredCategories = categories;
        if (!categories.contains(selectedCategory)) {
          selectedCategory = categories.isNotEmpty ? categories.first : '';
        }
      });
    } else {
      print('No categories found or invalid data format');
    }
  } catch (error) {
    print('Error loading categories: $error');
  }
}

 Future<void> insertRecord() async {
  try {
    if (_formKey.currentState!.validate()) {
      String? newRecordKey = databaseReference.child('records').push().key;

      if (pickedFile != null) {
        String imageUrl = await uploadImageToFirebase(imageBytes!);

        Map<String, dynamic> newData = {
          'name': nameController.text,
          'location': locationController.text,
          'category': selectedCategory,
          'city': selectedCityCategory,
          'description': descriptionController.text,
          'imageUrl': imageUrl,
          'latitude': latitudeController.text,
          'longitude': longitudeController.text,
        };

        await databaseReference.child('records').child(newRecordKey!).set(newData);

        print('Record inserted successfully!');
        _formKey.currentState!.reset();
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record inserted successfully')),
        );
      } else {
        print('No image picked.');
      }
    }
  } catch (error) {
    print('Error inserting record: $error');
  }
}

Future<void> updateRecord(String recordKey) async {
  try {
    Map<String, dynamic> updatedData = {
      'name': nameController.text,
      'location': locationController.text,
      'category': selectedCategory,
      'city': selectedCityCategory,
      'description': descriptionController.text,
      'imageUrl': imageUrlController.text,
      'latitude': latitudeController.text,
      'longitude': longitudeController.text,
    };
    await databaseReference.child('records').child(recordKey).update(updatedData);

    print('Record updated successfully!');
  } catch (error) {
    print('Error updating record: $error');
  }
}



TextFormField _buildTextFormField({
  required TextEditingController controller,
  required String labelText, required String? Function(dynamic value) validator,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Color(0xFF0B91A0), fontSize: 18),
      filled: true,
      fillColor: Theme.of(context).colorScheme.secondary,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xFF56C6D3), width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide( width: 1.0),
      ),
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextFormField(
                controller: nameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                }, labelText: 'Name',
              ),
              const SizedBox(height: 16.0),
              _buildTextFormField(
                controller: locationController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                }, labelText: 'Location',
              ),
              const SizedBox(height: 16.0),
              CustomDropdownButton(
                  labelText: 'City',
                  value: selectedCityCategory,
                  items: filteredCityCategories,
                  hint: 'Select City Category',
                  onChanged: (value) {
                    setState(() {
                      selectedCityCategory = value!;
                    });
                  }, 
              ),
              const SizedBox(height: 16.0),
              CustomDropdownButton(
                  labelText: 'Category',
                  value: selectedCategory,
                  items: filteredCategories,
                  hint: 'Select Category',
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  }, 
              ),
              const SizedBox(height: 16.0),
              _buildTextFormField(
                controller: descriptionController,
                labelText: 'Description',
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                }, 
              ),
              const SizedBox(height: 16.0),
               _buildTextFormField(
                controller: latitudeController,
                labelText: 'Latitude',
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter latitude';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
               _buildTextFormField(
                controller: longitudeController,
                labelText: 'Longitude',
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter longitude';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                 style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  backgroundColor: const Color(0xFF56C6D3),
                ),
                onPressed: _pickImage,
                child: const Text('Pick Image', style: TextStyle(color: Colors.white),),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                 style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  backgroundColor: const Color(0xFF56C6D3),
                ),
                onPressed: insertRecord,
                child: const Text('Submit', style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

