import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUtils {

  static Future<String?> uploadImage(File imageFile, String adminId,
      String imageType) async {
    try {
      String fileName = "$adminId/$imageType.jpg";
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL(); // Get the image URL
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  static Future<File?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }

  static ClipRRect getClipRRectImage (String picUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Image.network(
        picUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            width: 50,
            height: 50,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
      ),
    );
  }
}
