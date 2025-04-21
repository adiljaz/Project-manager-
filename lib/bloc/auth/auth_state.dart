import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

// Initial state
class AuthInitial extends AuthState {}

// Loading state during authentication operations
class AuthLoading extends AuthState {}

// Authenticated state with user ID
class AuthAuthenticated extends AuthState {
  final String userId;
  
  const AuthAuthenticated({required this.userId});
  
  @override
  List<Object?> get props => [userId];
}

// Unauthenticated state
class AuthUnauthenticated extends AuthState {}

// Error state with error message
class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Password reset email sent
class AuthPasswordResetSent extends AuthState {}