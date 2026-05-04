import 'package:flutter/material.dart';

import '../../models/package_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/package_card.dart';
import '../package_detail.dart';

/// Ana sayfa paket listesi (IndexedStack içinde state korunur).
class HomePackagesTab extends StatelessWidget {
  const HomePackagesTab({
    super.key,
    required this.currentUser,
    required this.scrollController,
    required this.onOpenPackageDetail,
  });

  final AppUser currentUser;
  final ScrollController scrollController;
  final void Function(PackageModel pkg) onOpenPackageDetail;

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return StreamBuilder<List<PackageModel>>(
      stream: firestore.watchPackagesForRole(
        role: currentUser.role,
        userId: currentUser.id,
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
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: packages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final pkg = packages[index];
            return PackageCard(
              packageName: pkg.title,
              status: pkg.status,
              onTap: () => onOpenPackageDetail(pkg),
            );
          },
        );
      },
    );
  }
}
