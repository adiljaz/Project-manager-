import 'package:equatable/equatable.dart';

class LocationState extends Equatable {
  final double latitude;
  final double longitude;
  final String locationName;
  final bool isLoading;
  final String? errorMessage;

  const LocationState({
    required this.latitude,
    required this.longitude,
    required this.locationName,
    this.isLoading = false,
    this.errorMessage,
  });

  LocationState copyWith({
    double? latitude,
    double? longitude,
    String? locationName,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, locationName, isLoading, errorMessage];
}
