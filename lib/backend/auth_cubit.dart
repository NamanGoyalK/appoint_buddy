import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/app_user.dart';
import '../repos/auth_repo.dart';

part 'auth_states.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;

  AuthCubit({required this.authRepo}) : super(AuthInitial()) {
    // Call checkAuth immediately upon creation
    _initializeAuth();
  }

  // Private method to initialize authentication
  void _initializeAuth() {
    if (kDebugMode) {
      print('AuthCubit: Initializing authentication');
    }
    checkAuth();
  }

  // Comprehensive authentication check
  Future<void> checkAuth() async {
    if (kDebugMode) {
      print('AuthCubit: Checking authentication status');
    }

    try {
      // Emit loading state to indicate process is ongoing
      emit(AuthLoading());

      // Small delay to ensure any pending authentication processes complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Attempt to get current user
      final user = await authRepo.getCurrentUser();

      if (kDebugMode) {
        print(
            'AuthCubit: Current user retrieved - ${user?.email ?? "No user"}');
      }

      if (user != null) {
        // User is authenticated
        emit(Authenticated(user));
      } else {
        // No user found
        emit(UnAuthenticated());
      }
    } catch (e) {
      // Handle any unexpected errors
      if (kDebugMode) {
        print('AuthCubit: Authentication check failed - $e');
      }

      emit(AuthError(e.toString()));
      emit(UnAuthenticated());
    }
  }

  // Login method with enhanced error handling
  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      emit(AuthLoading());

      final user = await authRepo.loginWithEmailAndPassword(email, password);

      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      if (kDebugMode) {
        print('AuthCubit: Login failed - $e');
      }

      emit(AuthError(e.toString()));
      emit(UnAuthenticated());
    }
  }

  Future<void> signupWithEmailAndPassword(
      String name, String email, String password) async {
    try {
      emit(AuthLoading());

      final user =
          await authRepo.signupWithEmailAndPassword(name, email, password);

      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      if (kDebugMode) {
        print('AuthCubit: Signup failed - $e');
      }

      emit(AuthError(e.toString()));
      emit(UnAuthenticated());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());

      final user = await authRepo.signInWithGoogle();

      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      if (kDebugMode) {
        print('AuthCubit: Google Sign-In failed - $e');
      }

      emit(AuthError(e.toString()));
      emit(UnAuthenticated());
    }
  }

  Future<void> logout() async {
    try {
      emit(AuthLoading());

      await authRepo.logout();

      emit(UnAuthenticated());
    } catch (e) {
      if (kDebugMode) {
        print('AuthCubit: Logout failed - $e');
      }

      emit(AuthError(e.toString()));
      emit(UnAuthenticated());
    }
  }

  Future<void> sendForgotPasswordLink(String email) async {
    try {
      await authRepo.sendPasswordResetLink(email);
    } catch (e) {
      emit(AuthError('An unexpected error occurred: $e'));
    } finally {
      emit(UnAuthenticated());
    }
  }
}
