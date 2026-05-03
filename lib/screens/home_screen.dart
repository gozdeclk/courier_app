import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/package_card.dart';
import 'add_package.dart';
import 'package_detail.dart';
import 'profile.dart';
import '../models/user_model.dart';
import '../models/package_model.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  AppUser? _currentUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      if (!mounted) return;
      setState(() => _isLoadingUser = false);
      return;
    }

    try {
      final appUser = await _firestoreService.getUserById(authUser.uid);
      if (!mounted) return;
      setState(() {
        _currentUser = appUser;
        _isLoadingUser = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingUser = false);
    }
  }

  Future<void> _openProfile() async {
    if (_currentUser == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          email: _currentUser!.email,
          role: _currentUser!.role,
        ),
      ),
    );
  }

  Future<void> _openAddPackage() async {
    if (_currentUser?.role != UserRole.admin) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => AddPackageScreen(
          adminId: _currentUser!.id,
          couriers: [
            CourierOption(id: 'courier_1', name: 'Ali Veli'),
            CourierOption(id: 'courier_2', name: 'Ayşe Yılmaz'),
          ],
        ),
      ),
    );
  }

  void _openPackageDetail(PackageModel pkg) {
    if (_currentUser == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PackageDetailScreen(
          currentRole: _currentUser!.role,
          currentUserId: _currentUser!.id,
          package: PackageDetailData(
            id: pkg.id,
            name: pkg.title,
            address: pkg.address,
            assignedCourierName: pkg.courierId,
            status: pkg.status,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Kullanıcı bilgisi alınamadı.')),
      );
    }

    final isAdmin = _currentUser!.role == UserRole.admin;

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
      body: StreamBuilder<List<PackageModel>>(
        stream: _firestoreService.watchPackagesForRole(
          role: _currentUser!.role,
          userId: _currentUser!.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Paketler yüklenirken hata oluştu.'));
          }

          final packages = snapshot.data ?? [];
          if (packages.isEmpty) {
            return const Center(child: Text('Gösterilecek paket bulunamadı.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: packages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final pkg = packages[index];
              return PackageCard(
                packageName: pkg.title,
                status: pkg.status,
                onTap: () => _openPackageDetail(pkg),
              );
            },
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