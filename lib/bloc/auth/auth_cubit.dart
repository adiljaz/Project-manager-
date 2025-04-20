import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yelloskye/bloc/auth/auth_state.dart';
import '../../models/user_model.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  AuthCubit() : super(AuthInitial());
  
  Future<void> checkUserLoggedIn() async {
    emit(AuthLoading());
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        emit(AuthAuthenticated(UserModel(uid: user.uid, email: user.email ?? '')));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        emit(AuthAuthenticated(UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
        )));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(AuthError('No user found for that email.'));
      } else if (e.code == 'wrong-password') {
        emit(AuthError('Wrong password provided.'));
      } else {
        emit(AuthError(e.message ?? 'An error occurred during login.'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> signUp(String email, String password) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        emit(AuthAuthenticated(UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
        )));
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
  
  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      await _auth.sendPasswordResetEmail(email: email);
      emit(AuthUnauthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Failed to send password reset email.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _auth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}