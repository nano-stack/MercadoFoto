import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;

  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  bool _loading       = false;
  bool _loadingGoogle = false;
  bool _obscurePass   = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Email / Password ────────────────────────────────────────────────────
  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();

    if (!email.contains('@')) { _snack('Ingresa un correo válido'); return; }
    if (pass.length < 6)      { _snack('Mínimo 6 caracteres');     return; }

    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await AuthService.loginConEmail(email, pass);
      } else {
        await AuthService.registrarConEmail(email, pass);
      }
      _irAHome();
    } catch (e) {
      final msg = AuthService.mensajeError(e);
      if (msg.isNotEmpty) _snack(msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Google ──────────────────────────────────────────────────────────────
  Future<void> _google() async {
    setState(() => _loadingGoogle = true);
    try {
      await AuthService.loginConGoogle();
      _irAHome();
    } catch (e) {
      final msg = AuthService.mensajeError(e);
      if (msg.isNotEmpty) _snack(msg);
    } finally {
      if (mounted) setState(() => _loadingGoogle = false);
    }
  }

  // ── Navegación ───────────────────────────────────────────────────────────
  void _irAHome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.carbon,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Image.asset('assets/images/logo.png', height: 44),
              const SizedBox(height: 36),

              // Headline
              Text(
                _isLogin ? 'Bienvenido' : 'Crear cuenta',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isLogin
                    ? 'Ingresa a tu cuenta OkVenta'
                    : 'Únete y empieza a vender hoy',
                style: const TextStyle(fontSize: 15, color: AppColors.grayMid),
              ),
              const SizedBox(height: 36),

              // ── Botón Google ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _loadingGoogle ? null : _google,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.divider),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loadingGoogle
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: AppColors.primary, strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://developers.google.com/identity/images/g-logo.png',
                              height: 20,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.g_mobiledata_rounded,
                                size: 24,
                                color: AppColors.carbon,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Continuar con Google',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Divisor "o" ───────────────────────────────────────────────
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'o',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.grayMid,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),

              const SizedBox(height: 20),

              // ── Email ─────────────────────────────────────────────────────
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    fontSize: 15, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_outlined,
                      color: AppColors.grayMid, size: 20),
                ),
              ),
              const SizedBox(height: 14),

              // ── Password ──────────────────────────────────────────────────
              TextField(
                controller: _passCtrl,
                obscureText: _obscurePass,
                style: const TextStyle(
                    fontSize: 15, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                      color: AppColors.grayMid, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePass
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.grayMid,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Botón principal ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: AppColors.surface, strokeWidth: 2.5),
                        )
                      : Text(
                          _isLogin ? 'Ingresar' : 'Crear cuenta',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Toggle login ↔ registro ───────────────────────────────────
              Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    _isLogin = !_isLogin;
                    _emailCtrl.clear();
                    _passCtrl.clear();
                  }),
                  child: Text(
                    _isLogin
                        ? '¿No tienes cuenta? Regístrate gratis'
                        : '¿Ya tienes cuenta? Ingresa',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // ── Explorar sin cuenta ───────────────────────────────────────
              Center(
                child: TextButton(
                  onPressed: _irAHome,
                  child: const Text(
                    'Explorar sin cuenta →',
                    style: TextStyle(
                        color: AppColors.grayMid, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
