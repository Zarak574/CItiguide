// import 'dart:typed_data';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// import 'package:rolebase/all_record_display.dart';
// import 'package:rolebase/widgets/app_bar.dart';
// import 'package:rolebase/widgets/custom_dropdown.dart';
// import 'package:rolebase/widgets/my_drawer.dart';

// class EditRecordScreen extends StatefulWidget {
//   final Map<String, dynamic> record;

//   EditRecordScreen({required this.record}); 

//   @override
//   _EditRecordScreenState createState() => _EditRecordScreenState();
// }

// class _EditRecordScreenState extends State<EditRecordScreen> {
//   DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController locationController = TextEditingController();
//   final TextEditingController categoryController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   final TextEditingController latitudeController = TextEditingController();
//   final TextEditingController longitudeController = TextEditingController();
//   late String selectedCategory = '';
//   late String selectedCityCategory = ''; 
//   List<String> filteredCityCategories = [];
//   List<String> filteredCategories = [];
//   XFile? pickedFile;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   UploadTask? _uploadTask;
//   Uint8List? imageBytes;

//   @override
//   void initState() {
//     super.initState();
//     nameController.text = widget.record['name'];
//     locationController.text = widget.record['location'];
//     categoryController.text = widget.record['category'];
//     descriptionController.text = widget.record['description'];
//     loadCategories();
//     loadCityCategories();
//   }


// Widget _buildImageWidget() {
//   if (widget.record['imageUrl'] != null) {
//     return GestureDetector(
//       onTap: _pickImage,
//       child: Container(
//         width: 200,
//         height: 200,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10.0), // Rounded corners
//           color: Colors.grey.withOpacity(0.5),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(10.0), // Rounded corners
//           child: Image.network(
//             widget.record['imageUrl'],
//             fit: BoxFit.cover,
//           ),
//         ),
//       ),
//     );
//   } else {
//     return GestureDetector(
//       onTap: _pickImage,
//       child: Container(
//         width: 200,
//         height: 200,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10.0), // Rounded corners
//           color: Colors.grey.withOpacity(0.5),
//         ),
//         child: Icon(
//           Icons.add_a_photo,
//           size: 50,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }


// TextFormField _buildTextFormField({
//   required TextEditingController controller,
//   required String labelText,
// }) {
//   return TextFormField(
//     controller: controller,
//     decoration: InputDecoration(
//       labelText: labelText,
//       labelStyle: TextStyle(color: Color(0xFF0B91A0), fontSize: 18),
//       filled: true,
//       fillColor: Color(0xFFF0F9FF),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10.0),
//         borderSide: BorderSide(color: Color(0xFF0B91A0), width: 2.0),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10.0),
//         borderSide: BorderSide(color: Color(0xFFF0F9FF), width: 1.0),
//       ),
//     ),
//   );
// }



// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     drawer: MyDrawer(),
//     appBar: CustomAppBar(),
//     body: Padding(
//       padding: EdgeInsets.all(16.0),
//       child: ListView(
//         children: [
//           _buildImageWidget(),
//           SizedBox(height: 16.0),
//           _buildTextFormField(
//             controller: nameController,
//             labelText: 'Name',
//           ),
//           SizedBox(height: 16.0),
//           _buildTextFormField(
//             controller: locationController,
//             labelText: 'Location',
//           ),
//           SizedBox(height: 16.0),
//            CustomDropdownButton(
//               labelText: 'City',
//               value: selectedCityCategory,
//               items: filteredCityCategories,
//               hint: 'Select City Category',
//               onChanged: (value) {
//                 setState(() {
//                   selectedCityCategory = value!;
//                 });
//               }, 
//             ),
         
//           SizedBox(height: 16.0),
//            CustomDropdownButton(
//             labelText: 'Category',
//               value: selectedCategory,
//               items: filteredCategories,
//               hint: 'Select Category',
//               onChanged: (value) {
//                 setState(() {
//                   selectedCategory = value!;
//                 });
//               },
//             ),
          
//           SizedBox(height: 16.0),
//           _buildTextFormField(
//             controller: descriptionController,
//             labelText: 'Description',
//           ),
//           SizedBox(height: 16.0),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
//               backgroundColor: Color(0xFF0B91A0), 
//             ),
//             onPressed: () {
//               updateRecord();
//             },
//             child: Text('Save Changes', style: TextStyle(color: Colors.white),),
//           ),
//         ],
//       ),
//     ),
//   );
// }


//  Future<void> loadCityCategories() async {
//     try {
//       DatabaseEvent snapshot = await databaseReference.child('city').once();

//       if (snapshot.snapshot != null &&
//           snapshot.snapshot.value != null &&
//           snapshot.snapshot.value is List<dynamic>) {
//         List<String> cityCategories = (snapshot.snapshot.value as List<dynamic>)
//             .where((category) => category != null)
//             .cast<String>()
//             .toSet()
//             .toList();

//         setState(() {
//           filteredCityCategories = cityCategories;
//           if (!cityCategories.contains(selectedCityCategory)) {
//             selectedCityCategory = cityCategories.isNotEmpty ? cityCategories.first : '';
//           }
//         });
//       } else {
//         print('No city categories found or invalid data format');
//       }
//     } catch (error) {
//       print('Error loading city categories: $error');
//     }
//   }

// void onCategorySelected(String? value) {
//   setState(() {
//     selectedCategory = value ?? '';
//   });
// }

// Future<void> loadCategories() async {
//   try {
//     DatabaseEvent snapshot = await databaseReference.child('categories').once();

//     if (snapshot.snapshot != null &&
//         snapshot.snapshot.value != null &&
//         snapshot.snapshot.value is List<dynamic>) {
//       List<String> categories = (snapshot.snapshot.value as List<dynamic>)
//           .where((category) => category != null)
//           .cast<String>()
//           .toSet() 
//           .toList();

//       setState(() {
//         filteredCategories = categories;
//         if (!categories.contains(selectedCategory)) {
//           selectedCategory = categories.isNotEmpty ? categories.first : '';
//         }
//       });
//     } else {
//       print('No categories found or invalid data format');
//     }
//   } catch (error) {
//     print('Error loading categories: $error');
//   }
// }

//  Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedImage = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedImage != null) {
//       setState(() {
//         pickedFile = pickedImage;
//       });

//       imageBytes = await pickedFile!.readAsBytes();
//     } else {
//       print('No image selected.');
//     }
//   }

//   Future<String> uploadImageToFirebase(Uint8List imageBytes) async {
//     try {
//       String filename = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';

//       firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
//           .ref()
//           .child('images')
//           .child(filename);

//       await ref.putData(imageBytes);

//       String imageUrl = await ref.getDownloadURL();
//       return imageUrl;
//     } catch (error) {
//       print('Error uploading image to Firebase Storage: $error');
//       throw error;
//     }
//   }

// void updateRecord() async {
//   try {
//     bool isLatitudeEmpty = latitudeController.text.isEmpty || latitudeController.text == widget.record['latitude'];
//     bool isLongitudeEmpty = longitudeController.text.isEmpty || longitudeController.text == widget.record['longitude'];
//     bool isImageUnchanged = imageBytes == null;

//     bool isAnyFieldChanged = !isLatitudeEmpty || !isLongitudeEmpty || !isImageUnchanged ||
//         nameController.text != widget.record['name'] ||
//         locationController.text != widget.record['location'] ||
//         selectedCategory != widget.record['category'] ||
//         selectedCityCategory != widget.record['city'] ||
//         descriptionController.text != widget.record['description'];

//     if (!isAnyFieldChanged) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('No changes made')),
//       );
//       return;
//     }
//     Map<String, dynamic> updatedFields = {
//       'name': nameController.text,
//       'location': locationController.text,
//       'category': selectedCategory,
//       'city': selectedCityCategory,
//       'description': descriptionController.text,
//     };

//     if (!isLatitudeEmpty) updatedFields['latitude'] = latitudeController.text;
//     if (!isLongitudeEmpty) updatedFields['longitude'] = longitudeController.text;

//     if (!isImageUnchanged) {
//       String imageUrl = await uploadImageToFirebase(imageBytes!);
//       updatedFields['imageUrl'] = imageUrl;
//     }

//     await FirebaseDatabase.instance.ref().child('records').child(widget.record['key']).update(updatedFields);

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Changes saved')),
//     );
//     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AllRecordsDisplay()));
//   } catch (error) {
//     print('Error updating record: $error');
//   }
// }
// }



import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:rolebase/all_record_display.dart';
import 'package:rolebase/widgets/app_bar.dart';
import 'package:rolebase/widgets/custom_dropdown.dart';
import 'package:rolebase/widgets/my_drawer.dart';

class EditRecordScreen extends StatefulWidget {
  final Map<String, dynamic> record;

  EditRecordScreen({required this.record});

  @override
  _EditRecordScreenState createState() => _EditRecordScreenState();
}

class _EditRecordScreenState extends State<EditRecordScreen> {
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  late String selectedCategory = '';
  late String selectedCityCategory = '';
  List<String> filteredCityCategories = [];
  List<String> filteredCategories = [];
  XFile? pickedFile;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  UploadTask? _uploadTask;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.record['name'];
    locationController.text = widget.record['location'];
    selectedCategory = widget.record['category'] ?? '';
    selectedCityCategory = widget.record['city'] ?? '';
    descriptionController.text = widget.record['description'];
    loadCategories();
    loadCityCategories();
  }

  Widget _buildImageWidget() {
    if (widget.record['imageUrl'] != null) {
      return GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0), // Rounded corners
            color: Colors.grey.withOpacity(0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0), // Rounded corners
            child: Image.network(
              widget.record['imageUrl'],
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0), // Rounded corners
            color: Colors.grey.withOpacity(0.5),
          ),
          child: Icon(
            Icons.add_a_photo,
            size: 50,
            color: Colors.white,
          ),
        ),
      );
    }
  }

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Color(0xFF56C6D3), fontSize: 18),
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary,
        // Color(0xFFF0F9FF),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Color(0xFF56C6D3), width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide( width: 1.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildImageWidget(),
            SizedBox(height: 16.0),
            _buildTextFormField(
              controller: nameController,
              labelText: 'Name',
            ),
            SizedBox(height: 16.0),
            _buildTextFormField(
              controller: locationController,
              labelText: 'Location',
            ),
            SizedBox(height: 16.0),
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
            SizedBox(height: 16.0),
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
            SizedBox(height: 16.0),
            _buildTextFormField(
              controller: descriptionController,
              labelText: 'Description',
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                backgroundColor: Color(0xFF56C6D3),
              ),
              onPressed: () {
                updateRecord();
              },
              child: Text('Save Changes', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
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

  Future<void> updateRecord() async {
    try {
      bool isLatitudeEmpty = latitudeController.text.isEmpty || latitudeController.text == widget.record['latitude'];
      bool isLongitudeEmpty = longitudeController.text.isEmpty || longitudeController.text == widget.record['longitude'];
      bool isImageUnchanged = imageBytes == null;

      bool isAnyFieldChanged = !isLatitudeEmpty || !isLongitudeEmpty || !isImageUnchanged ||
          nameController.text != widget.record['name'] ||
          locationController.text != widget.record['location'] ||
          selectedCategory != widget.record['category'] ||
          selectedCityCategory != widget.record['city'] ||
          descriptionController.text != widget.record['description'];

      if (!isAnyFieldChanged) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No changes made')),
        );
        return;
      }
      Map<String, dynamic> updatedFields = {
        'name': nameController.text,
        'location': locationController.text,
        'category': selectedCategory,
        'city': selectedCityCategory,
        'description': descriptionController.text,
      };

      if (!isLatitudeEmpty) updatedFields['latitude'] = latitudeController.text;
      if (!isLongitudeEmpty) updatedFields['longitude'] = longitudeController.text;

      if (!isImageUnchanged) {
        String imageUrl = await uploadImageToFirebase(imageBytes!);
        updatedFields['imageUrl'] = imageUrl;
      }

      await FirebaseDatabase.instance.ref().child('records').child(widget.record['key']).update(updatedFields);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Changes saved')),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AllRecordsDisplay()));
    } catch (error) {
      print('Error updating record: $error');
    }
  }
}
