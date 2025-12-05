import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../src/generated/l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../../logic/cubits/user_cubit.dart';
import '../../../data/models/user.dart';
import '../Home/home_page.dart';
import '../../widgets/back_arrow.dart';

class EnterLocationPage extends StatefulWidget {
  final String email;
  final User? userData;
  final bool isEditMode;
  final int? currentUserId;

  const EnterLocationPage({
    Key? key, 
    required this.email, 
    this.userData,
    this.isEditMode = false,
    this.currentUserId,
  }) : super(key: key);

  @override
  State<EnterLocationPage> createState() => _EnterLocationPageState();
}

class _EnterLocationPageState extends State<EnterLocationPage> {
  final _searchController = TextEditingController();
  List<Map<String, String>> searchResults = [];
  bool _isSearching = false;
  bool _isLoading = false;

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty || query.length < 2) {
      setState(() {
        searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearching = true;
    });

    // Add delay to avoid too many requests while typing
    await Future.delayed(Duration(milliseconds: 500));

    try {
      // Use Photon API (powered by OpenStreetMap) - better for Algeria
      final response = await http.get(
        Uri.parse(
          'https://photon.komoot.io/api/?q=${Uri.encodeComponent(query)}&limit=10&lang=fr&bbox=-8.66,18.96,11.98,37.09',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> features = data['features'] ?? [];
        
        setState(() {
          searchResults = features.where((item) {
            // Filter only Algeria results
            final props = item['properties'];
            return props['country'] == 'Algeria' || 
                   props['country'] == 'Algérie' ||
                   props['countrycode'] == 'DZ';
          }).map((item) {
            final props = item['properties'];
            final coords = item['geometry']['coordinates'];
            
            // Build display name
            String displayName = props['name'] ?? '';
            if (props['city'] != null && props['city'] != displayName) {
              displayName += ', ${props['city']}';
            } else if (props['state'] != null && props['state'] != displayName) {
              displayName += ', ${props['state']}';
            }
            displayName += ', Algeria';
            
            return {
              'display_name': displayName,
              'lat': coords[1].toString(),
              'lon': coords[0].toString(),
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          searchResults = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        searchResults = [];
        _isLoading = false;
      });
      print('Error searching location: $e');
    }
  }

  void _useCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable them in settings.'),
              duration: Duration(seconds: 3),
            ),
          );
          // Open location settings
          await Geolocator.openLocationSettings();
        }
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission permanently denied. Please enable it in app settings.'),
              duration: Duration(seconds: 3),
            ),
          );
          // Open app settings
          await Geolocator.openAppSettings();
        }
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('🌍 GPS Location Retrieved: Latitude=${position.latitude}, Longitude=${position.longitude}');
      
      final userCubit = BlocProvider.of<UserCubit>(context);
      
      if (widget.userData != null) {
        // New signup: Save user with location to database
        // Reverse geocode GPS coordinates to get location name
        String? locationName;
        try {
          final response = await http.get(Uri.parse(
            'https://photon.komoot.io/reverse?lat=${position.latitude}&lon=${position.longitude}&limit=1&countrycodes=dz'
          ));
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['features'] != null && (data['features'] as List).isNotEmpty) {
              locationName = data['features'][0]['properties']['display_name'];
              print('🌍 Reverse geocoded location: $locationName');
            }
          }
        } catch (e) {
          print('⚠️ Reverse geocoding failed: $e');
        }
        
        final userWithLocation = widget.userData!.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
          locationName: locationName,
        );
        print('💾 Saving new user to database with location: ${locationName ?? "GPS coordinates only"}');
        await userCubit.registerUser(userWithLocation);
        
        if (context.mounted) {
          final state = userCubit.state;
          if (state is UserOperationSuccess) {
            print('✅ User registered successfully with location: $locationName');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        }
      } else {
        // Existing user (login or edit): Update location
        // Reverse geocode GPS coordinates to get location name
        String? locationName;
        try {
          final response = await http.get(Uri.parse(
            'https://photon.komoot.io/reverse?lat=${position.latitude}&lon=${position.longitude}&limit=1&countrycodes=dz'
          ));
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['features'] != null && (data['features'] as List).isNotEmpty) {
              locationName = data['features'][0]['properties']['display_name'];
              print('🌍 Reverse geocoded location: $locationName');
            }
          }
        } catch (e) {
          print('⚠️ Reverse geocoding failed: $e');
        }
        
        // Use currentUserId if in edit mode, otherwise get from email
        int? userId = widget.currentUserId;
        if (userId == null) {
          final user = await userCubit.userRepository.getUserByEmail(widget.email);
          userId = user?.userId;
        }
        
        print('👤 Updating location for user: ID=$userId');
        if (userId != null && context.mounted) {
          await userCubit.updateUserLocation(userId, position.latitude, position.longitude, locationName: locationName);
          print('✅ Location saved to database for user $userId: $locationName');
          
          if (widget.isEditMode) {
            // Return to edit profile
            Navigator.pop(context, true);
          } else {
            // Go to home for new login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
      print('❌ Error getting location: $e');
    }
  }

  void _selectLocation(Map<String, String> location) async {
    try {
      final lat = location['lat']!;
      final lon = location['lon']!;
      final latitude = double.parse(lat);
      final longitude = double.parse(lon);
      final locationName = location['display_name']!;
      
      print('📍 Manual Location Selected: $locationName');
      print('🌍 Coordinates: Latitude=$latitude, Longitude=$longitude');
      
      final userCubit = BlocProvider.of<UserCubit>(context);
      
      if (widget.userData != null) {
        // New signup: Save user with location to database
        final userWithLocation = widget.userData!.copyWith(
          latitude: latitude,
          longitude: longitude,
          locationName: locationName,
        );
        print('💾 Saving new user to database with location: $locationName');
        await userCubit.registerUser(userWithLocation);
        
        if (context.mounted) {
          final state = userCubit.state;
          if (state is UserOperationSuccess) {
            print('✅ User registered successfully with location: $locationName');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        }
      } else {
        // Existing user (login or edit): Update location
        // Use currentUserId if in edit mode, otherwise get from email
        int? userId = widget.currentUserId;
        if (userId == null) {
          final user = await userCubit.userRepository.getUserByEmail(widget.email);
          userId = user?.userId;
        }
        
        print('👤 Updating location for user: ID=$userId');
        if (userId != null && context.mounted) {
          await userCubit.updateUserLocation(userId, latitude, longitude, locationName: locationName);
          print('✅ Location saved to database for user $userId');
          
          if (widget.isEditMode) {
            // Return to edit profile
            Navigator.pop(context, true);
          } else {
            // Go to home for new login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving location: $e')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button and title
              Row(
                children: [
                  CustomBackArrow(
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.searchYourLocation,
                    style: AppText.bold.copyWith(
                      fontSize: 20,
                      color: AppColors.darkBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Search field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.darkBlue.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchLocation,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchLocationHint,
                    hintStyle: AppText.regular.copyWith(
                      color: AppColors.darkBlue.withOpacity(0.4),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Use current location button
              InkWell(
                onTap: _useCurrentLocation,
                child: Row(
                  children: [
                    Icon(
                      Icons.my_location,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context)!.useCurrentLocation,
                      style: AppText.medium.copyWith(
                        fontSize: 15,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Search results
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              if (_isSearching && searchResults.isNotEmpty && !_isLoading) ...[
                Text(
                  AppLocalizations.of(context)!.searchResults,
                  style: AppText.regular.copyWith(
                    fontSize: 13,
                    color: AppColors.darkBlue.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final location = searchResults[index];
                      return InkWell(
                        onTap: () => _selectLocation(location),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            location['display_name']!,
                            style: AppText.regular.copyWith(
                              fontSize: 15,
                              color: AppColors.darkBlue,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (_isSearching && searchResults.isEmpty && !_isLoading)
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.noResultsFound,
                    style: AppText.regular.copyWith(
                      fontSize: 14,
                      color: AppColors.darkBlue.withOpacity(0.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
