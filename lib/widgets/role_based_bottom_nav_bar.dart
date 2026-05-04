import 'package:flutter/material.dart';

import '../models/user_model.dart';

/// Material [BottomNavigationBar]: yuvarlatılmış üst köşe, gölge ve rol bazlı sekmeler.
class RoleBasedBottomNavBar extends StatelessWidget {
  const RoleBasedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.userRole,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final UserRole userRole;

  static const double topRadius = 20;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isAdmin = userRole == UserRole.admin;

    final items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_outlined),
        activeIcon: const Icon(Icons.home_rounded),
        label: 'Ana Sayfa',
      ),
      if (isAdmin)
        BottomNavigationBarItem(
          icon: const Icon(Icons.add_box_outlined),
          activeIcon: const Icon(Icons.add_box_rounded),
          label: 'Paket Ekle',
        ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person_outline),
        activeIcon: const Icon(Icons.person_rounded),
        label: 'Profil',
      ),
    ];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(topRadius)),
      child: Material(
        elevation: 14,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        color: scheme.surface,
        child: Theme(
          data: theme.copyWith(
            splashColor: scheme.primary.withValues(alpha: 0.12),
            highlightColor: scheme.primary.withValues(alpha: 0.06),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onDestinationSelected,
            elevation: 0,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: scheme.primary,
            unselectedItemColor: scheme.onSurfaceVariant.withValues(alpha: 0.72),
            selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: theme.textTheme.labelSmall,
            showUnselectedLabels: true,
            items: items,
          ),
        ),
      ),
    );
  }
}
