import 'package:cloud_firestore/cloud_firestore.dart';

class PackageModel {
  final String id;
  final String title;
  final String address;
  final String status; // pending | assigned | delivered
  final String courierId;
  final DateTime createdAt;

  const PackageModel({
    required this.id,
    required this.title,
    required this.address,
    required this.status,
    required this.courierId,
    required this.createdAt,
  });

  factory PackageModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PackageModel(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      address: (data['address'] ?? '') as String,
      status: (data['status'] ?? 'pending') as String,
      courierId: (data['courierId'] ?? '') as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'address': address,
      'status': status,
      'courierId': courierId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PackageModel copyWith({
    String? status,
    String? courierId,
  }) {
    return PackageModel(
      id: id,
      title: title,
      address: address,
      status: status ?? this.status,
      courierId: courierId ?? this.courierId,
      createdAt: createdAt,
    );
  }
}