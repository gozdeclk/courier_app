import 'package:flutter/material.dart';

import '../widgets/package_card.dart';
import 'add_package.dart';
import 'package_detail.dart';
import 'profile.dart';
// import '../models/user_role.dart'; // önerilen ortak enum dosyan

enum UserRole { admin, courier } // BUNU ortak dosyaya taşımanı öneriyorum.

class PackageItem {
  final String id;
  final String name;
  final String address;
  final String status; // pending, assigned, delivered
  final String assignedCourierId;
  final String assignedCourierName;

  const PackageItem({
    required this.id,
    required this.name,
    required this.address,
    required this.status,
    required this.assignedCourierId,
    required this.assignedCourierName,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.currentRole = UserRole.courier,
    this.currentCourierId = 'courier_1',
    this.currentEmail = 'user@mail.com',
  });

  final UserRole currentRole;
  final String currentCourierId;
  final String currentEmail;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<PackageItem> _packages = [
    const PackageItem(
      id: 'p1',
      name: 'Laptop Paketi',
      address: 'Kadıköy / İstanbul',
      status: 'pending',
      assignedCourierId: 'courier_1',
      assignedCourierName: 'Ali Veli',
    ),
    const PackageItem(
      id: 'p2',
      name: 'Telefon Kutusu',
      address: 'Beşiktaş / İstanbul',
      status: 'assigned',
      assignedCourierId: 'courier_2',
      assignedCourierName: 'Ayşe Yılmaz',
    ),
    const PackageItem(
      id: 'p3',
      name: 'Evrak Teslimi',
      address: 'Çankaya / Ankara',
      status: 'delivered',
      assignedCourierId: 'courier_1',
      assignedCourierName: 'Ali Veli',
    ),
  ];

  List<PackageItem> _visiblePackages() {
    if (widget.currentRole == UserRole.admin) return _packages;
    return _packages
        .where((p) => p.assignedCourierId == widget.currentCourierId)
        .toList();
  }

  Future<void> _openProfile() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          email: widget.currentEmail,
          role: widget.currentRole,
        ),
      ),
    );
  }

  Future<void> _openAddPackage() async {
    if (widget.currentRole != UserRole.admin) return;

    final result = await Navigator.push<NewPackageDraft>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddPackageScreen(
          couriers: [
            CourierOption(id: 'courier_1', name: 'Ali Veli'),
            CourierOption(id: 'courier_2', name: 'Ayşe Yılmaz'),
          ],
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _packages.insert(
        0,
        PackageItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: result.name,
          address: result.address,
          status: 'assigned',
          assignedCourierId: result.courier.id,
          assignedCourierName: result.courier.name,
        ),
      );
    });
  }

  void _openPackageDetail(PackageItem pkg) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PackageDetailScreen(
          currentRole: widget.currentRole,
          package: PackageDetailData(
            id: pkg.id,
            name: pkg.name,
            address: pkg.address,
            assignedCourierName: pkg.assignedCourierName,
            status: pkg.status,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final packages = _visiblePackages();
    final isAdmin = widget.currentRole == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Admin Ana Sayfa' : 'Kurye Ana Sayfa'),
        actions: [
          IconButton(
            onPressed: _openProfile,
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profil',
          ),
        ],
      ),
      body: packages.isEmpty
          ? const Center(child: Text('Gösterilecek paket bulunamadı.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: packages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final pkg = packages[index];
                return PackageCard(
                  packageName: pkg.name,
                  status: pkg.status,
                  onTap: () => _openPackageDetail(pkg),
                );
              },
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _openAddPackage,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}