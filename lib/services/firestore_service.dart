import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/package_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AppUser> getUserById(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return AppUser.fromMap(doc.data() ?? {}, doc.id);
  }

  Stream<List<PackageModel>> watchPackagesForRole({
    required UserRole role,
    required String userId,
  }) {
    Query<Map<String, dynamic>> query = _db
        .collection('packages')
        .orderBy('createdAt', descending: true);

    if (role == UserRole.courier) {
      query = query.where('courierId', isEqualTo: userId);
    }

    return query.snapshots().map(
          (snap) => snap.docs.map(PackageModel.fromDoc).toList(),
        );
  }

  Future<void> createPackage({
    required String title,
    required String address,
    required String courierId,
    required String adminId,
  }) async {
    final ref = _db.collection('packages').doc();
    await ref.set({
      'title': title,
      'address': address,
      'status': 'assigned',
      'courierId': courierId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await addLog(
      action: 'paket oluşturuldu',
      userId: adminId,
      extra: {'packageId': ref.id},
    );
  }

  Future<void> updatePackageStatus({
    required String packageId,
    required String newStatus,
    required String userId,
  }) async {
    await _db.collection('packages').doc(packageId).update({
      'status': newStatus,
    });

    await addLog(
      action: 'durum değiştirildi',
      userId: userId,
      extra: {'packageId': packageId, 'status': newStatus},
    );
  }

  Future<void> addLog({
    required String action,
    required String userId,
    Map<String, dynamic>? extra,
  }) async {
    await _db.collection('logs').add({
      'action': action,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      ...?extra,
    });
  }
}