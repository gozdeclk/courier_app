import 'package:flutter/material.dart';

import '../models/user_model.dart';
import 'tabs/profile_tab_body.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.email,
    required this.role,
  });

  final String email;
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Geri dön',
        ),
      ),
      body: ProfileTabBody(
        email: email,
        role: role,
        showBackButton: true,
      ),
    );
  }
}
