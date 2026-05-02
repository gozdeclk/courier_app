import 'package:flutter/material.dart';

enum UserRole { admin, courier }

class PackageItem {
  final String id;
  final String name;
  final String status; // pending, assigned, delivered
  final String assignedCourierId;

  const PackageItem({
    required this.id,
    required this.name,
    required this.status,
    required this.assignedCourierId,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.currentRole = UserRole.courier,
    this.currentCourierId = 'courier_1',
  });

  final UserRole currentRole;
  final String currentCourierId;

  List<PackageItem> _fakePackages() => const [
        PackageItem(
          id: 'p1',
          name: 'Laptop Paketi',
          status: 'pending',
          assignedCourierId: 'courier_1',
        ),
        PackageItem(
          id: 'p2',
          name: 'Telefon Kutusu',
          status: 'assigned',
          assignedCourierId: 'courier_2',
        ),
        PackageItem(
          id: 'p3',
          name: 'Evrak Teslimi',
          status: 'delivered',
          assignedCourierId: 'courier_1',
        ),
      ];

  List<PackageItem> _visiblePackages() {
    final allPackages = _fakePackages();

    if (currentRole == UserRole.admin) {
      return allPackages;
    }

    // Kurye: sadece kendine atanmış paketler
    return allPackages
        .where((pkg) => pkg.assignedCourierId == currentCourierId)
        .toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Beklemede';
      case 'assigned':
        return 'Atandı';
      case 'delivered':
        return 'Teslim Edildi';
      default:
        return 'Bilinmiyor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final packages = _visiblePackages();
    final isAdmin = currentRole == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Admin Ana Sayfa' : 'Kurye Ana Sayfa'),
        actions: [
          IconButton(
            onPressed: () {
              // Profil sayfasına yönlendirme yapılabilir.
            },
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
                return Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    title: Text(
                      pkg.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _statusColor(pkg.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(_statusLabel(pkg.status)),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PackageDetailScreen(package: pkg),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                // Paket ekleme sayfasına gidilebilir.
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class PackageDetailScreen extends StatelessWidget {
  const PackageDetailScreen({super.key, required this.package});

  final PackageItem package;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paket Detayı')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Text('Paket ID: ${package.id}'),
                const SizedBox(height: 6),
                Text('Durum: ${package.status}'),
                const SizedBox(height: 6),
                Text('Atanan Kurye: ${package.assignedCourierId}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}