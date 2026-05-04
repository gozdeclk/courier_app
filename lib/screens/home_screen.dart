import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/package_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../widgets/role_based_bottom_nav_bar.dart';
import 'add_package.dart';
import 'package_detail.dart';
import 'tabs/home_packages_tab.dart';
import 'tabs/profile_tab_body.dart';

/// Oturum sonrası ana kabuk: rol bazlı alt gezinme + [IndexedStack] ile sekme durumu korunur.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ScrollController _homeScrollController = ScrollController();

  AppUser? _currentUser;
  bool _isLoadingUser = true;

  /// Aktif sekme; admin için 0–2, kurye için 0–1.
  int _currentIndex = 0;

  List<Widget>? _tabPages;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _homeScrollController.dispose();
    super.dispose();
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
        _currentIndex = 0;
        if (appUser != null) {
          _tabPages = _composeTabPages(appUser);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingUser = false);
    }
  }

  bool get _isAdmin => _currentUser?.role == UserRole.admin;

  /// Profil sekmesinin [BottomNavigationBar] indeksi.
  int _profileNavIndex(bool admin) => admin ? 2 : 1;

  List<CourierOption> get _demoCouriers => const [
        CourierOption(id: 'courier_1', name: 'Ali Veli'),
        CourierOption(id: 'courier_2', name: 'Ayşe Yılmaz'),
      ];

  List<Widget> _composeTabPages(AppUser user) {
    final home = HomePackagesTab(
      key: const PageStorageKey<String>('tab_home_packages'),
      currentUser: user,
      scrollController: _homeScrollController,
      onOpenPackageDetail: _openPackageDetail,
    );

    final profile = ProfileTabBody(
      key: const PageStorageKey<String>('tab_profile'),
      email: user.email,
      role: user.role,
      showBackButton: false,
    );

    if (user.role == UserRole.admin) {
      return [
        home,
        AddPackageScreen(
          key: PageStorageKey<String>('tab_add_${user.id}'),
          embeddedInShell: true,
          adminId: user.id,
          couriers: _demoCouriers,
        ),
        profile,
      ];
    }

    return [home, profile];
  }

  void _openPackageDetail(PackageModel pkg) {
    if (_currentUser == null) return;
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
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

  String _appBarTitle() {
    final admin = _isAdmin;
    if (admin) {
      switch (_currentIndex) {
        case 0:
          return 'Admin Ana Sayfa';
        case 1:
          return 'Paket Ekle';
        case 2:
          return 'Profil';
      }
    } else {
      switch (_currentIndex) {
        case 0:
          return 'Kurye Ana Sayfa';
        case 1:
          return 'Profil';
      }
    }
    return '';
  }

  void _goToProfileTab() {
    if (_currentUser == null) return;
    setState(() => _currentIndex = _profileNavIndex(_isAdmin));
  }

  void _onBottomNavTap(int index) {
    if (index == _currentIndex && index == 0) {
      if (_homeScrollController.hasClients) {
        _homeScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _openSettingsSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ayarlar yakında.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null || _tabPages == null) {
      return const Scaffold(
        body: Center(child: Text('Kullanıcı bilgisi alınamadı.')),
      );
    }

    final user = _currentUser!;
    final admin = user.role == UserRole.admin;
    final profileIdx = _profileNavIndex(admin);
    final pages = _tabPages!;

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: Text(
              _appBarTitle(),
              key: ValueKey<String>('${_currentIndex}_${_appBarTitle()}'),
            ),
          ),
          actions: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOut,
              child: _currentIndex != profileIdx
                  ? IconButton(
                      key: const ValueKey<String>('action_profile'),
                      icon: const Icon(Icons.person_outline),
                      tooltip: 'Profil',
                      onPressed: _goToProfileTab,
                    )
                  : IconButton(
                      key: const ValueKey<String>('action_settings'),
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: 'Ayarlar',
                      onPressed: _openSettingsSnack,
                    ),
            ),
          ],
        ),
        body: IndexedStack(
          key: ValueKey<Object>(user.id),
          index: _currentIndex,
          sizing: StackFit.expand,
          children: pages,
        ),
        floatingActionButton: admin && _currentIndex == 0
            ? FloatingActionButton(
                heroTag: 'home_add_package_fab',
                onPressed: () => setState(() => _currentIndex = 1),
                child: const Icon(Icons.add),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: RoleBasedBottomNavBar(
          currentIndex: _currentIndex,
          userRole: user.role,
          onDestinationSelected: _onBottomNavTap,
        ),
      ),
    );
  }
}
