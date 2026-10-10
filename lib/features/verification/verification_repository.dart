import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/cloudinary_service.dart';

class VerificationRepository {
  VerificationRepository(this._db, this._cloudinary);

  final FirebaseFirestore _db;
  final CloudinaryService _cloudinary;

  /// Renvoi d'une nouvelle photo apres un refus : envoie l'image a Cloudinary,
  /// met a jour driverIdentity/{uid} et repasse le livreur en "pending".
  Future<void> resubmit({required String uid, required XFile photo}) async {
    final url = await _cloudinary.uploadImage(photo);
    final batch = _db.batch();
    batch.update(_db.collection('driverIdentity').doc(uid), {
      'idUrl': url,
      'submittedAt': FieldValue.serverTimestamp(),
      'rejectReason': FieldValue.delete(),
    });
    batch.update(_db.collection('drivers').doc(uid), {
      'verificationStatus': 'pending',
    });
    await batch.commit();
  }
}
