import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/back_arrow.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../services/mock_database_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  late Map<String, dynamic> userData;

  @override
  void initState() {
    super.initState();
    // Load current user data from mock service
    userData = MockDataService.getCurrentUser();// leading
    
    // Initialize controllers with current data
    _nameController.text = userData['full_name'] ?? '';
    _emailController.text = userData['email'] ?? '';
    _phoneController.text = userData['phone_number'] ?? '';
    
    // Format date if available
    if (userData['date_of_birth'] != null) {
      final dob = DateTime.parse(userData['date_of_birth']);
      _dateController.text = '${dob.day}/${dob.month}/${dob.year}';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // Parse existing date if available
    DateTime initialDate = DateTime(2000);
    if (_dateController.text.isNotEmpty) {
      try {
        final parts = _dateController.text.split('/');
        if (parts.length == 3) {
          initialDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (e) {
        // Use default if parsing fails
        initialDate = DateTime(2000);
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // In a real app, you would call an API here to update the user profile

      // MockDataService.updateUser({
      //   'full_name': _nameController.text,
      //   'email': _emailController.text,
      //   'phone_number': _phoneController.text,
      //   'date_of_birth': _dateController.text,
      // });
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        
        SnackBar(
          
          content:  Text(loc.profileUpdated),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context, true); // Return true to indicate profile was updated
    }
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CustomBackArrow(),
                  Expanded(
                    child: Center(
                      child: Text(
                        loc.editProfile,
                        style: AppText.bold.copyWith(
                          fontSize: 24,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Form Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        // Full Name field
                        Text(
                          loc.fullName,
                          style: AppText.medium.copyWith(
                            fontSize: 14,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: loc.enterFullName,
                            hintStyle: AppText.regular.copyWith(
                              color: AppColors.darkBlue.withOpacity(0.4),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: AppColors.darkBlue.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: AppColors.darkBlue.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return loc.pleaseEnterName;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Email field
                        Text(
                          loc.email,
                          style: AppText.medium.copyWith(
                            fontSize: 14,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: loc.enterEmail,
                            hintStyle: AppText.regular.copyWith(
                              color: AppColors.darkBlue.withOpacity(0.4),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AppColors.darkBlue.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: AppColors.darkBlue.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return loc.pleaseEnterEmail;
                            }
                            if (!value.contains('@')) {
                              return loc.validEmail;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Phone field
                        Text(
                          loc.phoneNumber,
                          style: AppText.medium.copyWith(
                            fontSize: 14,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: '+213794691377',
                            hintStyle: AppText.regular.copyWith(
                              color: AppColors.darkBlue.withOpacity(0.4),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.phone_outlined,
                              color: AppColors.darkBlue.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: AppColors.darkBlue.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return loc.enterPhoneNumber;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Date of Birth
                        Text(
                          loc.dateOfBirth,
                          style: AppText.medium.copyWith(
                            fontSize: 14,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          decoration: InputDecoration(
                            hintText: loc.dobFormat,
                            hintStyle: AppText.regular.copyWith(
                              color: AppColors.darkBlue.withOpacity(0.4),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.calendar_today,
                              color: AppColors.darkBlue.withOpacity(0.5),
                              size: 20,
                            ),
                            filled: true,
                            fillColor: AppColors.darkBlue.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // New Password field
                        Text(
                          loc.newPassword,
                          style: AppText.medium.copyWith(
                            fontSize: 14,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: _obscureNewPassword,
                          decoration: InputDecoration(
                            hintText: loc.enterNewPassword,
                            hintStyle: AppText.regular.copyWith(
                              color: AppColors.darkBlue.withOpacity(0.4),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: AppColors.darkBlue.withOpacity(0.5),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.darkBlue.withOpacity(0.5),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: AppColors.darkBlue.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                value.length < 6) {
                              return loc.passwordMinLength;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Confirm new password field
                        Text(
                          loc.confirmNewPassword,
                          style: AppText.medium.copyWith(
                            fontSize: 14,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            hintText: loc.enterConfirmNewPassword,
                            hintStyle: AppText.regular.copyWith(
                              color: AppColors.darkBlue.withOpacity(0.4),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: AppColors.darkBlue.withOpacity(0.5),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.darkBlue.withOpacity(0.5),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: AppColors.darkBlue.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (_newPasswordController.text.isNotEmpty) {
                              if (value == null || value.isEmpty) {
                                return loc.pleaseConfirmPassword;
                              }
                              if (value != _newPasswordController.text) {
                                return loc.passwordsDoNotMatch;
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _cancel,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFFFFC7C7), // Light red/pink
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  loc.cancel,
                                  style: AppText.medium.copyWith(
                                    fontSize: 16,
                                    color: AppColors.darkBlue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.lightBlue,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  loc.editProfile,
                                  style: AppText.medium.copyWith(
                                    fontSize: 16,
                                    color: AppColors.darkBlue,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

