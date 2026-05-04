import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const String _validInviteCode = '123456';

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _inviteCodeFocusNode = FocusNode();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _inviteCodeController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _inviteCodeFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Email boş bırakılamaz.';
    const pattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
    if (!RegExp(pattern).hasMatch(email)) {
      return 'Geçerli bir email adresi girin.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = (value ?? '').trim();
    if (password.isEmpty) return 'Şifre boş bırakılamaz.';
    if (password.length < 6) return 'Şifre en az 6 karakter olmalı.';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final confirmPassword = (value ?? '').trim();
    if (confirmPassword.isEmpty) return 'Şifre tekrarı boş bırakılamaz.';
    if (confirmPassword != _passwordController.text.trim()) {
      return 'Şifreler eşleşmiyor.';
    }
    return null;
  }

  String? _validateInviteCode(String? value) {
    final inviteCode = (value ?? '').trim();
    if (inviteCode.isEmpty) return 'Davet kodu boş bırakılamaz.';
    if (inviteCode != _validInviteCode) return 'Geçersiz davet kodu.';
    return null;
  }

  String _mapRegisterError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Bu email adresi zaten kayıtlı.';
        case 'invalid-email':
          return 'Email adresi geçersiz.';
        case 'weak-password':
          return 'Şifre çok zayıf. En az 6 karakter kullanın.';
        case 'network-request-failed':
          return 'Ağ hatası oluştu. İnternet bağlantınızı kontrol edin.';
        default:
          return 'Kayıt sırasında bir hata oluştu. Tekrar deneyin.';
      }
    }
    return 'Kayıt sırasında bir hata oluştu. Tekrar deneyin.';
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: 'courier',
      );
      await _authService.signOut();

      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _mapRegisterError(error);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.person_add_alt_1_outlined, size: 52),
                      const SizedBox(height: 12),
                      Text(
                        'Courier App',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Yeni hesabınızı oluşturun',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kayıt için davet kodu gereklidir.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        enabled: !_isLoading,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_passwordFocusNode),
                        validator: _validateEmail,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        enabled: !_isLoading,
                        onChanged: (_) {
                          if (_confirmPasswordController.text.isNotEmpty) {
                            _formKey.currentState?.validate();
                          }
                        },
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_confirmPasswordFocusNode),
                        validator: _validatePassword,
                        decoration: InputDecoration(
                          labelText: 'Şifre',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            tooltip: _obscurePassword ? 'Şifreyi göster' : 'Şifreyi gizle',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.next,
                        enabled: !_isLoading,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_inviteCodeFocusNode),
                        validator: _validateConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Şifre Tekrar',
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          suffixIcon: IconButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            tooltip: _obscureConfirmPassword
                                ? 'Şifreyi göster'
                                : 'Şifreyi gizle',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _inviteCodeController,
                        focusNode: _inviteCodeFocusNode,
                        enabled: !_isLoading,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        onFieldSubmitted: (_) => _isLoading ? null : _handleRegister(),
                        validator: _validateInviteCode,
                        decoration: InputDecoration(
                          labelText: 'Davet Kodu',
                          hintText: '6 haneli kod',
                          prefixIcon: const Icon(Icons.key_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.25),
                            ),
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
                          onPressed: _isLoading ? null : _handleRegister,
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
                              : const Text('Kayıt Ol'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        child: const Text('Zaten hesabın var mı? Giriş yap'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}