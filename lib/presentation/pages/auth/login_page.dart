import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../../core/services/biometric_service.dart';
 
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}
 
class _LoginPageState extends State<LoginPage> {
  final _formKey    = GlobalKey<FormState>();
  final _userCtrl   = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool _obscure     = true;
  bool _bioAvail    = false;
 
  @override
  void initState() {
    super.initState();
    BiometricService.instance.isAvailable().then((v) => setState(() => _bioAvail = v));
  }
 
  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
 
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthSuccess) {
          Navigator.pushReplacementNamed(ctx, '/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text(state.message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: cs.error,
          ));
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
 
                  // ── Logo
                  Center(
                    child: Container(
                      width: 110, height: 110,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.egg_alt_rounded, size: 64, color: cs.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Selamat Datang!', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  Text('Masuk ke Duck Farm Manager', style: tt.bodyMedium?.copyWith(color: cs.outline), textAlign: TextAlign.center),
                  const SizedBox(height: 40),
 
                  // ── Form Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Username
                          TextFormField(
                            controller: _userCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: (v) => (v?.trim().isEmpty ?? true) ? 'Username wajib diisi' : null,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
 
                          // Password
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) => (v?.isEmpty ?? true) ? 'Password wajib diisi' : null,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _doLogin(context),
                          ),
                          const SizedBox(height: 24),
 
                          // Login Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (ctx, state) => FilledButton.icon(
                              onPressed: state is AuthLoading ? null : () => _doLogin(ctx),
                              icon: state is AuthLoading
                                  ? const SizedBox(width: 18, height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.login_rounded),
                              label: const Text('Masuk'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
 
                  // ── Biometric
                  if (_bioAvail) ...[
                    Row(children: [
                      Expanded(child: Divider(color: cs.outlineVariant)),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('atau', style: tt.bodySmall?.copyWith(color: cs.outline))),
                      Expanded(child: Divider(color: cs.outlineVariant)),
                    ]),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context.read<AuthBloc>().add(BiometricLoginEvent()),
                      icon: const Icon(Icons.fingerprint_rounded, size: 28),
                      label: const Text('Login dengan Fingerprint'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
 
                  const SizedBox(height: 32),
                  // Default credential hint (hapus di production!)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.tertiaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '💡 Default: username = admin, password = admin123',
                      style: tt.bodySmall?.copyWith(color: cs.onTertiaryContainer),
                      textAlign: TextAlign.center,
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
 
  void _doLogin(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(LoginEvent(
        username: _userCtrl.text.trim(),
        password: _passCtrl.text,
      ));
    }
  }
}