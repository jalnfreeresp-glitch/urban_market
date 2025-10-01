import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Logger _logger = Logger();

  Future<String> uploadProductImage(
      File image, String productId) async {
    try {
      // Crea un nombre de archivo único para la imagen.
      final String fileExtension = p.extension(image.path);
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final String uploadPath = 'product_images/$productId/$fileName';

      // Crea una referencia a la ubicación a la que deseas subir el archivo.
      final Reference ref = _storage.ref().child(uploadPath);

      // Sube el archivo.
      final UploadTask uploadTask = ref.putFile(image);

      // Espera a que se complete la subida.
      final TaskSnapshot snapshot = await uploadTask;

      // Obtiene la URL de descarga.
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      // Maneja cualquier error.
      _logger.e('Error al subir la imagen del producto: $e');
      rethrow;
    }
  }
}