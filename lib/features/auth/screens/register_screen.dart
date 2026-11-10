import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../shared/widgets/blueprint_background.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_input.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  String? _successMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormFilled =>
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.trim().isNotEmpty;

  Future<void> _handleRegister() async {
    if (!_isFormFilled) return;
    setState(() {
      _errorMessage = null;
      _successMessage = null;
      _isLoading = true;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _successMessage = 'Pendaftaran berhasil! Mengalihkan ke dashboard...';
        });
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          context.go('/dashboard');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      body: BlueprintBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: NeoCard(
                  shadowOffset: 8.0,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo Neobrutalism
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: NeoColors.surfaceLight,
                          border: Border.all(color: NeoColors.black, width: 4.0),
                          boxShadow: NeoColors.hardShadow(offset: 4.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'BUAT AKUN BARU',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: NeoColors.textDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Ayo daftar dan kelola finansial Anda dengan cerdas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: NeoColors.textMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Input Nama Lengkap
                      NeoInput(
                        label: 'Nama Lengkap',
                        hintText: 'Masukkan nama lengkap Anda',
                        controller: _nameController,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      // Input Email
                      NeoInput(
                        label: 'Email',
                        hintText: 'Masukkan email aktif Anda',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      // Input Kata Sandi
                      NeoInput(
                        label: 'Kata Sandi',
                        hintText: 'Minimal 6 karakter',
                        controller: _passwordController,
                        obscureText: true,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      // Error Banner
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: NeoColors.dangerRed,
                            border: Border.all(color: NeoColors.black, width: 2.0),
                            boxShadow: NeoColors.hardShadow(offset: 4.0),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: NeoColors.textLight,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Success Banner
                      if (_successMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: NeoColors.successGreen,
                            border: Border.all(color: NeoColors.black, width: 2.0),
                            boxShadow: NeoColors.hardShadow(offset: 4.0),
                          ),
                          child: Text(
                            _successMessage!,
                            style: const TextStyle(
                              color: NeoColors.textLight,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Tombol Daftar
                      NeoButton(
                        text: 'Daftar',
                        onPressed: (_isFormFilled && !_isLoading) ? _handleRegister : null,
                        isLoading: _isLoading,
                        variant: NeoButtonVariant.primary,
                      ),
                      const SizedBox(height: 24),

                      // Link Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sudah punya akun? ',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: NeoColors.textDark,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: const Text(
                              'Masuk di sini',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: NeoColors.primaryBlue,
                                decoration: TextDecoration.underline,
                                decorationThickness: 2,
                              ),
                            ),
                          ),
                        ],
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

