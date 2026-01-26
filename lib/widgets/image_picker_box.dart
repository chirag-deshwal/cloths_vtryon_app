import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class ImagePickerBox extends StatelessWidget {
  final String label;
  final XFile? image;
  final VoidCallback onTap;

  const ImagePickerBox({
    Key? key,
    required this.label,
    required this.image,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey,
            width: 2,
            style: BorderStyle
                .none, // We will simulate dash or just use solid? Let's use solid for now but a clearer one.
          ),
        ),
        // To actually get a dashed border without the package, we can use a custom painter or just stick to a nice solid one.
        // I will use a solid border but with a nice color.
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade400,
              width: 2,
            ), // Solid border
          ),
          child: image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(
                    10,
                  ), // slightly less than container
                  child: kIsWeb
                      ? Image.network(image!.path, fit: BoxFit.cover)
                      : Image.file(File(image!.path), fit: BoxFit.cover),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 40,
                      color: Colors.grey[600],
                    ),
                    SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
