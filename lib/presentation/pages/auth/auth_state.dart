abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final int userId;
  final String username;
  final String fullName;
  const AuthSuccess({
    required this.userId,
    required this.username,
    required this.fullName,
  });
  @override
  List<Object?> get props => [userId, username, fullName];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthLoggedOut extends AuthState {}
