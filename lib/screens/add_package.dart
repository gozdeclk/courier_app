import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class CourierOption {
  final String id;
  final String name;

  const CourierOption({required this.id, required this.name});
}

class NewPackageDraft {
  final String name;
  final String address;
  final CourierOption courier;

  const NewPackageDraft({
    required this.name,
    required this.address,
    required this.courier,
  });
}

class AddPackageScreen extends StatefulWidget {
  const AddPackageScreen({
    super.key,
    required this.adminId,
    required this.couriers,
    this.embeddedInShell = false,
    this.onPackageAdded,
  });

  final String adminId;
  final List<CourierOption> couriers;
  /// Alt sekmede gösterilirken üst [Scaffold] dışarıda tanımlıdır.
  final bool embeddedInShell;
  final VoidCallback? onPackageAdded;

  @override
  State<AddPackageScreen> createState() => _AddPackageScreenState();
}

class _AddPackageScreenState extends State<AddPackageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  CourierOption? _selectedCourier;
  bool _isLoading = false;
  String? _errorMessage;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.couriers.isNotEmpty) {
      _selectedCourier = widget.couriers.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    setState(() => _errorMessage = null);

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_selectedCourier == null) {
      setState(() => _errorMessage = 'Lütfen bir kurye seçin.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestoreService.createPackage(
        title: _nameController.text.trim(),
        address: _addressController.text.trim(),
        courierId: _selectedCourier!.id,
        adminId: widget.adminId,
      );

      if (!mounted) return;
      if (widget.embeddedInShell) {
        _nameController.clear();
        _addressController.clear();
        _formKey.currentState?.reset();
        if (widget.couriers.isNotEmpty) {
          _selectedCourier = widget.couriers.first;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paket başarıyla eklendi.')),
        );
        widget.onPackageAdded?.call();
      } else {
        Navigator.pop(context);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Paket eklenirken bir hata oluştu.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildFormBody(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Paket adı',
                      prefixIcon: const Icon(Icons.inventory_2_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    validator: (value) {
                      final v = (value ?? '').trim();
                      if (v.isEmpty) return 'Paket adı boş bırakılamaz.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _addressController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Adres',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    validator: (value) {
                      final v = (value ?? '').trim();
                      if (v.isEmpty) return 'Adres boş bırakılamaz.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<CourierOption>(
                    value: _selectedCourier,
                    decoration: InputDecoration(
                      labelText: 'Kurye',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: widget.couriers
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: _isLoading ? null : (v) => setState(() => _selectedCourier = v),
                    validator: (value) {
                      if (value == null) return 'Lütfen bir kurye seçin.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (_errorMessage != null) const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleAdd,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4),
                            )
                          : const Text('Paket Ekle'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embeddedInShell) {
      return _buildFormBody(context);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Paket Ekle')),
      body: _buildFormBody(context),
    );
  }
}