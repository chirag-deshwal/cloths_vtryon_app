import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:typed_data';

import '../widgets/image_picker_box.dart';
import '../api/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  XFile? _personImage;
  XFile? _clothImage;
  String _selectedCategory = 'upper_body';
  bool _isLoading = false;
  Uint8List? _resultImage;

  final Map<String, String> _categories = {
    'Upper Body': 'upper_body',
    'Lower Body': 'lower_body',
    'Overall Body (Dress)': 'dresses',
    'Shoes': 'shoes', // Experimental
  };

  Future<void> _pickImage(bool isPerson) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (isPerson) {
        _personImage = image;
      } else {
        _clothImage = image;
      }
    });
  }

  Future<void> _generate() async {
    if (_personImage == null || _clothImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select both images')));
      return;
    }

    setState(() {
      _isLoading = true;
      _resultImage = null;
    });

    final result = await _apiService.generateTryOn(
      _personImage!,
      _clothImage!,
      _selectedCategory,
    );

    setState(() {
      _isLoading = false;
      _resultImage = result;
    });

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate image. Check API configuration.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Soft background
      appBar: AppBar(
        title: Text(
          'Virtual Try-On',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Visualize your style.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ImagePickerBox(
                    label: "Your Photo",
                    image: _personImage,
                    onTap: () => _pickImage(true),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ImagePickerBox(
                    label: "Cloth",
                    image: _clothImage,
                    onTap: () => _pickImage(false),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                  items: _categories.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.value,
                      child: Text(entry.key, style: TextStyle(fontSize: 16)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategory = val!;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _generate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                shadowColor: Colors.deepPurple.withOpacity(0.4),
              ),
              child: _isLoading
                  ? SpinKitThreeBounce(color: Colors.white, size: 20)
                  : Text(
                      "Try On Now",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            SizedBox(height: 40),
            if (_resultImage != null)
              Column(
                children: [
                  Text(
                    "Result",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(_resultImage!, fit: BoxFit.contain),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
