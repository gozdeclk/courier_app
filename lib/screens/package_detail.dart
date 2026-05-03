import 'package:flutter/material.dart';
import '../models/user_role.dart';

enum UserRole { admin, courier }

class PackageDetailData {
  final String id;
  final String name;
  final String address;
  final String assignedCourierName;
  final String status; // pending, assigned, delivered

  const PackageDetailData({
    required this.id,
    required this.name,
    required this.address,
    required this.assignedCourierName,
    required this.status,
  });

  PackageDetailData copyWith({String? status}) {
    return PackageDetailData(
      id: id,
      name: name,
      address: address,
      assignedCourierName: assignedCourierName,
      status: status ?? this.status,
    );
  }
}

class PackageDetailScreen extends StatefulWidget {
  const PackageDetailScreen({
    super.key,
    required this.package,
    required this.currentRole,
  });

  final PackageDetailData package;
  final UserRole currentRole;

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  late PackageDetailData _package;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _package = widget.package;
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

  Future<void> _markDelivered() async {
    if (_package.status == 'delivered') return;

    setState(() {
      _isUpdating = true;
    });

    // Fake update (Firestore update yerine)
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() {
      _package = _package.copyWith(status: 'delivered');
      _isUpdating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCourier = widget.currentRole == UserRole.courier;

    return Scaffold(
      appBar: AppBar(title: const Text('Paket Detayı')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 1.5,
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
                  _package.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 14),
                _InfoRow(label: 'Adres', value: _package.address),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 120,
                      child: Text(
                        'Durum',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _statusColor(_package.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(_statusLabel(_package.status)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  label: 'Atanan Kurye',
                  value: _package.assignedCourierName,
                ),
                if (isCourier) ...[
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: (_isUpdating || _package.status == 'delivered')
                          ? null
                          : _markDelivered,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isUpdating
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4),
                            )
                          : Text(
                              _package.status == 'delivered'
                                  ? 'Teslim Edildi'
                                  : 'Teslim edildi',
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}