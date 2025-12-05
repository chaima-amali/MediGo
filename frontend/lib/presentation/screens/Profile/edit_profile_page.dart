import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/presentation/widgets/back_arrow.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/logic/cubits/user_cubit.dart';
import 'package:geocoding/geocoding.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../Register/Enter_location.dart';

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
  final _locationController = TextEditingController();
  String? _selectedGender;
  User? _currentUser;

  // Helper function to normalize gender to English
  String? _normalizeGender(String? gender) {
    if (gender == null || gender.isEmpty) return null;
    
    // If already in English format, return as is
    if (gender == 'Male' || gender == 'Female') return gender;
    
    // Convert from Arabic
    if (gender == 'ذكر' || gender.toLowerCase().contains('male')) return 'Male';
    if (gender == 'أنثى' || gender.toLowerCase().contains('female')) return 'Female';
    
    // Convert from French
    if (gender == 'Homme') return 'Male';
    if (gender == 'Femme') return 'Female';
    
    return null;
  }

  // Fetch location name from coordinates using reverse geocoding
  Future<void> _fetchLocationFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final locationName = '${place.locality ?? ''}, ${place.country ?? ''}'.trim();
        setState(() {
          _locationController.text = locationName.isNotEmpty ? locationName : 'Unknown location';
        });
        // Note: Location name is only displayed, not saved to DB until user clicks save
      }
    } catch (e) {
      print('Error fetching location: $e');
      setState(() {
        _locationController.text = 'Location unavailable';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Load user data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final userState = context.read<UserCubit>().state;
    if (userState is UserAuthenticated || userState is UserLoaded) {
      _currentUser = userState is UserAuthenticated 
          ? userState.user 
          : (userState as UserLoaded).user;
      
      print('👤 Loading user data:');
      print('   Name: ${_currentUser?.name}');
      print('   Email: ${_currentUser?.email}');
      print('   Phone: ${_currentUser?.phone}');
      print('   Gender: ${_currentUser?.gender}');
      print('   DOB: ${_currentUser?.dob}');
      print('   Location: ${_currentUser?.locationName}');
      print('   Lat: ${_currentUser?.latitude}, Lon: ${_currentUser?.longitude}');
      
      // Initialize controllers with current data
      _nameController.text = _currentUser?.name ?? '';
      _emailController.text = _currentUser?.email ?? '';
      _phoneController.text = _currentUser?.phone ?? '';
      // Normalize gender to English format for consistency
      _selectedGender = _normalizeGender(_currentUser?.gender);
      
      // Get location name from database or fetch from coordinates
      if (_currentUser?.locationName != null && _currentUser!.locationName!.isNotEmpty) {
        _locationController.text = _currentUser!.locationName!;
      } else if (_currentUser?.latitude != null && _currentUser?.longitude != null) {
        // Fetch location name from coordinates
        _fetchLocationFromCoordinates(_currentUser!.latitude!, _currentUser!.longitude!);
      } else {
        _locationController.text = 'No location set';
      }
      
      // Format date if available - convert from YYYY-MM-DD to DD/MM/YYYY for display
      if (_currentUser?.dob != null && _currentUser!.dob.isNotEmpty) {
        try {
          final dob = DateTime.parse(_currentUser!.dob);
          _dateController.text = '${dob.day.toString().padLeft(2, '0')}/${dob.month.toString().padLeft(2, '0')}/${dob.year}';
        } catch (e) {
          print('Error parsing date: $e');
          // If parsing fails, maybe it's already in DD/MM/YYYY format
          _dateController.text = _currentUser!.dob;
        }
      }
      
      setState(() {});
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

  void _saveProfile() async {
    if (_formKey.currentState!.validate() && _currentUser != null) {
      final loc = AppLocalizations.of(context)!;
      
      // Parse date from DD/MM/YYYY format to YYYY-MM-DD format
      String dobFormatted = _currentUser!.dob;
      if (_dateController.text.isNotEmpty) {
        try {
          final parts = _dateController.text.split('/');
          if (parts.length == 3) {
            dobFormatted = '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
          }
        } catch (e) {
          print('Error formatting date: $e');
        }
      }
      
      // Create updated user object
      final updatedUser = _currentUser!.copyWith(
        name: _nameController.text,
        phone: _phoneController.text,
        gender: _selectedGender ?? _currentUser!.gender,
        dob: dobFormatted,
      );
      
      // Update user in database
      await context.read<UserCubit>().updateUser(updatedUser);
      
      // Wait a moment for the state to fully propagate
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Check if update was successful - updateUser already reloads and emits UserLoaded
      final state = context.read<UserCubit>().state;
      print('🔍 Edit profile save state: ${state.runtimeType}');
      if (state is UserError) {
        print('❌ Error updating user: ${state.error}');
      }
      if (state is UserLoaded) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.profileUpdated),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context, true);
        }
      } else if (state is UserError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
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
                          enabled: false,
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
                        // Gender field
                        Text(
                          loc.gender,
                          style: AppText.medium.copyWith(
                            fontSize: 14,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedGender == null || (_selectedGender != 'Male' && _selectedGender != 'Female') ? null : _selectedGender,
                          decoration: InputDecoration(
                            hintText: loc.selectGender,
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
                          items: [
                            DropdownMenuItem(value: 'Male', child: Text(loc.male)),
                            DropdownMenuItem(value: 'Female', child: Text(loc.female)),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        // Location field
                        Text(
                          loc.location,
                          style: AppText.medium.copyWith(
                            fontSize: 14,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _locationController,
                          readOnly: true,
                          onTap: () async {
                            // Navigate to location selection page
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EnterLocationPage(
                                  email: _currentUser?.email ?? '',
                                  isEditMode: true,
                                  currentUserId: _currentUser?.userId,
                                ),
                              ),
                            );
                            
                            // Reload user data if location was updated
                            if (result == true) {
                              _loadUserData();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: loc.location,
                            hintStyle: AppText.regular.copyWith(
                              color: AppColors.darkBlue.withOpacity(0.4),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.location_on_outlined,
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
                                      const Color(0xFFFF9494), // Coral/pink
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
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5DD3D3), // Cyan/turquoise
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
                                    color: Colors.white,
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
    _locationController.dispose();
    super.dispose();
  }
}

