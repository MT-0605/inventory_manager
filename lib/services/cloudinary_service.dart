import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../config/cloudinary_config.dart';

class CloudinaryService {
  // Create an instance of CloudinaryPublic
  static final cloudinary = CloudinaryPublic(
    CloudinaryConfig.cloudName,
    CloudinaryConfig.uploadPreset,
    cache: false, // Set to true if you want to cache results
  );

  static Future<String?> uploadImage(File file) async {
    try {
      // The uploadFile method requires a CloudinaryFile
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      // Check if the upload was successful before returning the URL
      if (response.secureUrl.isNotEmpty) {
        print('Upload successful: ${response.secureUrl}');
        return response.secureUrl;
      } else {
        // Log the error if the upload failed
        return null;
      }
    } on CloudinaryException catch (e) {
      print('Cloudinary exception: ${e.message}');
      return null;
    } catch (e) {
      print('An unknown error occurred: $e');
      return null;
    }
  }
}