import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  AuthCubit() : super(AuthInitial()) {
    // Check current auth state when created
    checkUserLoggedIn();
  }

  // Check if user is logged in
  Future<void> checkUserLoggedIn() async {
    emit(AuthLoading());
    try {
      final currentUser = _auth.currentUser;
      await Future.delayed(Duration(milliseconds: 300)); // Small delay for Firebase Auth initialization
      
      if (currentUser != null) {
        emit(AuthAuthenticated(userId: currentUser.uid));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    try {
      emit(AuthLoading());
      await Future.delayed(Duration(milliseconds: 500)); // Add delay to show loading state
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        emit(AuthAuthenticated(userId: userCredential.user!.uid));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(AuthError('No user found for that email.'));
      } else if (e.code == 'wrong-password') {
        emit(AuthError('Wrong password provided.'));
      } else if (e.code == 'invalid-email') {
        emit(AuthError('Invalid email format.'));
      } else if (e.code == 'user-disabled') {
        emit(AuthError('This account has been disabled.'));
      } else {
        emit(AuthError(e.message ?? 'An error occurred during login.'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Sign up with email and password
  Future<void> signUp(String email, String password) async {
    try {
      emit(AuthLoading());
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        emit(AuthAuthenticated(userId: userCredential.user!.uid));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(AuthError('The password provided is too weak.'));
      } else if (e.code == 'email-already-in-use') {
        emit(AuthError('The account already exists for that email.'));
      } else {
        emit(AuthError(e.message ?? 'An error occurred during signup.'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      emit(AuthLoading());
      await _auth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      emit(AuthLoading());
      await _auth.sendPasswordResetEmail(email: email);
      emit(AuthPasswordResetSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}