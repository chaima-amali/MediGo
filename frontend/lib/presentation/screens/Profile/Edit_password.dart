import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/logic/cubits/user_cubit.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/back_arrow.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class EditPasswordPage extends StatefulWidget {
  const EditPasswordPage({super.key});

  @override
  State<EditPasswordPage> createState() => _EditPasswordPageState();
}

class _EditPasswordPageState extends State<EditPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    if (_formKey.currentState!.validate()) {
      final userState = context.read<UserCubit>().state;

      if (userState is UserAuthenticated || userState is UserLoaded) {
        final user = userState is UserAuthenticated
            ? userState.user
            : (userState as UserLoaded).user;

        // Hash the old password to compare with stored hashed password
        final hashedOldPassword = sha256
            .convert(utf8.encode(_oldPasswordController.text))
            .toString();

        // Verify old password matches
        if (user.password != hashedOldPassword) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Old password is incorrect'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          return;
        }

        // Update password (send plain text, backend will hash it)
        final updatedUser = user.copyWith(
          password: _newPasswordController.text,
        );

        await context.read<UserCubit>().updateUser(updatedUser);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password updated successfully'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.lightBlue,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : AppColors.lightBlue,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const CustomBackArrow(),
        title: Text(
          loc.changePassword,
          style: AppText.bold.copyWith(
            fontSize: 24,
            color: isDark ? Colors.white : AppColors.darkBlue,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.oldPassword,
                  style: AppText.medium.copyWith(
                    color: isDark ? Colors.white : AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: _obscureOldPassword,
                  decoration: InputDecoration(
                    hintText: loc.enterOldPassword,
                    hintStyle: AppText.regular.copyWith(
                      color: isDark
                          ? Colors.white70
                          : AppColors.darkBlue.withOpacity(0.4),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.black
                        : Colors.black.withOpacity(0.07),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white : AppColors.darkBlue,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.lightBlue : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureOldPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: isDark ? Colors.white : AppColors.darkBlue,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureOldPassword = !_obscureOldPassword;
                        });
                      },
                    ),
                  ),
                  style: AppText.regular.copyWith(
                    color: isDark ? Colors.white : AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  loc.newPassword,
                  style: AppText.medium.copyWith(
                    color: isDark ? Colors.white : AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    hintText: loc.enterNewPassword,
                    hintStyle: AppText.regular.copyWith(
                      color: isDark
                          ? Colors.white70
                          : AppColors.darkBlue.withOpacity(0.4),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.black
                        : Colors.black.withOpacity(0.07),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white : AppColors.darkBlue,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.lightBlue : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: isDark ? Colors.white : AppColors.darkBlue,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                  style: AppText.regular.copyWith(
                    color: isDark ? Colors.white : AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  loc.confirmNewPassword,
                  style: AppText.medium.copyWith(
                    color: isDark ? Colors.white : AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: loc.enterNewPassword,
                    hintStyle: AppText.regular.copyWith(
                      color: isDark
                          ? Colors.white70
                          : AppColors.darkBlue.withOpacity(0.4),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.black
                        : Colors.black.withOpacity(0.07),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white : AppColors.darkBlue,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.lightBlue : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: isDark ? Colors.white : AppColors.darkBlue,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  style: AppText.regular.copyWith(
                    color: isDark ? Colors.white : AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pink,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          loc.cancel,
                          style: AppText.medium.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _savePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.lightBlue
                              : AppColors.lightBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          loc.changePassword,
                          style: AppText.medium.copyWith(
                            color: isDark ? Colors.black : AppColors.darkBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
