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
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final avail = await BiometricService.instance.isAvailable();
    setState(() => _biometricAvailable = avail);
  }

  Future<void> _loginBiometric() async {
    final success = await BiometricService.instance.authenticate();
    if (success && mounted) {
      context.read<AuthBloc>().add(BiometricLoginEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // Logo & Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.egg_alt_rounded, size: 64, color: cs.primary),
              ).let((w) => Center(child: w)),
              const SizedBox(height: 24),
              Text(
                'Duck Farm Manager',
                style: tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Manajemen Peternakan Bebek Modern',
                style: tt.bodyMedium?.copyWith(color: cs.outline),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _userCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      BlocConsumer<AuthBloc, AuthState>(
                        listener: (ctx, state) {
                          if (state is AuthSuccess) {
                            Navigator.pushReplacementNamed(ctx, '/dashboard');
                          } else if (state is AuthError) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        builder: (ctx, state) {
                          return FilledButton.icon(
                            onPressed: state is AuthLoading
                                ? null
                                : () => ctx.read<AuthBloc>().add(
                                    LoginEvent(
                                      username: _userCtrl.text,
                                      password: _passCtrl.text,
                                    ),
                                  ),
                            icon: state is AuthLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.login),
                            label: const Text('Masuk'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Biometric
              if (_biometricAvailable) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _loginBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Login dengan Fingerprint'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Extension helper
extension WidgetX on Widget {
  Widget let(Widget Function(Widget) fn) => fn(this);
}
