import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageUtils {

  static Future<String?> uploadImage(File imageFile, String adminId,
      String imageType) async {
    try {
      String fileName = "$adminId/$imageType.jpg"; // Store as "adminId/logo.jpg" or "adminId/profilePic.jpg"
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
}
