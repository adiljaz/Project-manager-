import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:yelloskye/bloc/location/location_state.dart';
import 'package:yelloskye/core/constants/colors.dart';

// Location State

// Location Cubit
class LocationCubit extends Cubit<LocationState> {
  LocationCubit({
    required double initialLatitude,
    required double initialLongitude,
    required String initialLocationName,
  }) : super(LocationState(
          latitude: initialLatitude,
          longitude: initialLongitude,
          locationName: initialLocationName,
        ));

  Future<void> updateLocation(double latitude, double longitude) async {
    // First update coordinates immediately
    emit(state.copyWith(
      latitude: latitude,
      longitude: longitude,
      isLoading: true,
    ));
    
    // Then try to get the location name
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String locationName = _formatAddress(place);
        emit(state.copyWith(
          locationName: locationName,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          locationName: 'Unknown Location',
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        locationName: 'Unknown Location',
        isLoading: false,
        errorMessage: 'Error getting location name',
      ));
    }
  }

  void updateLocationName(String name) {
    emit(state.copyWith(locationName: name));
  }

  String _formatAddress(Placemark place) {
    List<String> addressParts = [];
    
    if (place.street != null && place.street!.isNotEmpty) {
      addressParts.add(place.street!);
    }
    
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressParts.add(place.subLocality!);
    }
    
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }
    
    if (place.country != null && place.country!.isNotEmpty) {
      addressParts.add(place.country!);
    }
    
    return addressParts.isNotEmpty ? addressParts.join(', ') : 'Unknown Location';
  }

  Future<void> getCurrentLocation(BuildContext context) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServicesDialog(context);
        emit(state.copyWith(isLoading: false));
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(state.copyWith(
            isLoading: false,
            errorMessage: 'Location permissions are denied',
          ));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Location permissions are permanently denied',
        ));
        return;
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update location with coordinates
      await updateLocation(position.latitude, position.longitude);

    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Error getting location: $e',
      ));
    }
  }

  void _showLocationServicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Please enable location services to use your current location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('ENABLE'),
          ),
        ],
      ),
    );
  }
}  