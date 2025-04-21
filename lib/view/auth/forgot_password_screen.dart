// views/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yelloskye/bloc/auth/auth_cubit.dart';
import 'package:yelloskye/bloc/auth/auth_state.dart';
import 'package:yelloskye/core/constants/string.dart';
import 'package:yelloskye/core/constants/validator.dart';
import 'package:yelloskye/widgets/custom_button.dart';
import 'package:yelloskye/widgets/custom_text_field.dart';

import '../../../core/constants/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose(); 
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().resetPassword(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        title: Text(
          AppStrings.resetPassword,
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final isSuccess = state is AuthUnauthenticated && 
                           _emailController.text.isNotEmpty; // Check if we came from reset submission
          
          // Show error message if needed
          if (state is AuthError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating, 
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            });
          }
          
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: isSuccess 
                    ? _buildSuccessContent()
                    : Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_reset,
                              size: 80,
                              color: AppColors.primary,
                            ),
                            SizedBox(height: 24),
                            Text(
                              AppStrings.resetPassword,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Enter your email and we\'ll send you a link to reset your password',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 40),
                            AuthTextField(
                              label: AppStrings.email,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                              prefixIcon: Icons.email_outlined,
                            ),
                            SizedBox(height: 32),
                            AuthButton(
                              text: AppStrings.resetPassword,
                              onPressed: _resetPassword,
                              isLoading: isLoading,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 80,
          color: AppColors.success,
        ),
        SizedBox(height: 24),
        Text(
          'Email Sent',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'We\'ve sent a password reset link to your email address. Please check your inbox.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 32),
        AuthButton(
          text: 'Back to Login',
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}