import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/database/dao/user_dao.dart';
import '../../../core/utils/hash_util.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/services/biometric_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserDao _userDao = UserDao();

  AuthBloc() : super(AuthInitial()) {
    on<CheckSessionEvent>(_onCheckSession);
    on<LoginEvent>(_onLogin);
    on<BiometricLoginEvent>(_onBiometricLogin);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckSession(
    CheckSessionEvent e,
    Emitter<AuthState> emit,
  ) async {
    final loggedIn = await SessionManager.isLoggedIn();
    if (loggedIn) {
      final userId = await SessionManager.getUserId();
      final username = await SessionManager.getUsername();
      final fullName = await SessionManager.getFullName();
      if (userId != null && username != null && fullName != null) {
        emit(
          AuthSuccess(userId: userId, username: username, fullName: fullName),
        );
        return;
      }
    }
    emit(AuthLoggedOut());
  }

  Future<void> _onLogin(LoginEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      if (e.username.trim().isEmpty || e.password.trim().isEmpty) {
        emit(const AuthError('Username dan password tidak boleh kosong'));
        return;
      }

      final user = await _userDao.findByUsername(e.username.trim());
      if (user == null) {
        emit(const AuthError('Username tidak ditemukan'));
        return;
      }

      final isValid = HashUtil.verifyPassword(
        e.password,
        user['password_hash'],
      );
      if (!isValid) {
        emit(const AuthError('Password salah'));
        return;
      }

      await SessionManager.saveSession(
        userId: user['id'],
        username: user['username'],
        fullName: user['full_name'],
        fotoPath: user['foto_path'],
      );

      emit(
        AuthSuccess(
          userId: user['id'],
          username: user['username'],
          fullName: user['full_name'],
        ),
      );
    } catch (err) {
      emit(AuthError('Terjadi kesalahan: $err'));
    }
  }

  Future<void> _onBiometricLogin(
    BiometricLoginEvent e,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final biometricEnabled = await SessionManager.isBiometricEnabled();
      if (!biometricEnabled) {
        emit(
          const AuthError(
            'Biometric belum diaktifkan. Login dulu dengan password.',
          ),
        );
        return;
      }

      final authenticated = await BiometricService.instance.authenticate();
      if (!authenticated) {
        emit(const AuthError('Autentikasi fingerprint gagal'));
        return;
      }

      // Ambil sesi yang tersimpan
      final userId = await SessionManager.getUserId();
      final username = await SessionManager.getUsername();
      final fullName = await SessionManager.getFullName();

      if (userId == null || username == null || fullName == null) {
        emit(
          const AuthError('Sesi tidak ditemukan, login dengan password dahulu'),
        );
        return;
      }

      emit(AuthSuccess(userId: userId, username: username, fullName: fullName));
    } catch (err) {
      emit(AuthError('Error: $err'));
    }
  }

  Future<void> _onLogout(LogoutEvent e, Emitter<AuthState> emit) async {
    await SessionManager.clearSession();
    emit(AuthLoggedOut());
  }
}
