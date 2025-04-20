import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yelloskye/bloc/location/location_cubit.dart';
import 'package:yelloskye/bloc/location/location_state.dart';
import 'package:yelloskye/core/constants/colors.dart';

class LocationSectionPage extends StatelessWidget {
  final double initialLatitude;
  final double initialLongitude;
  final String initialLocationName;
  final Function(double, double)? onLocationChanged;

  const LocationSectionPage({
    Key? key,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.initialLocationName,
    this.onLocationChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationCubit(
        initialLatitude: initialLatitude,
        initialLongitude: initialLongitude,
        initialLocationName: initialLocationName,
      ),
      child: LocationSectionView(onLocationChanged: onLocationChanged),
    );
  }
}

class LocationSectionView extends StatefulWidget {
  final Function(double, double)? onLocationChanged;

  const LocationSectionView({Key? key, this.onLocationChanged}) : super(key: key);

  @override
  State<LocationSectionView> createState() => _LocationSectionViewState();
}

class _LocationSectionViewState extends State<LocationSectionView> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Initialize markers after the first build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<LocationCubit>().state;
      _updateMapMarkers(state);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocationCubit, LocationState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
        
        // Notify parent if location changed and callback is provided
        if (widget.onLocationChanged != null) {
          widget.onLocationChanged!(state.latitude, state.longitude);
        }

        // Update map when location changes
        _updateMapMarkers(state);
        _moveCamera(state);
      },
      builder: (context, state) {
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.location_on, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Project Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                
                // Location Display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location Name
                      Row(
                        children: [
                          Icon(Icons.place, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.locationName.isNotEmpty ? state.locationName : 'Select a location',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Map
                SizedBox(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        GoogleMap(
                          onMapCreated: (controller) {
                            _mapController = controller;
                            _moveCamera(state);
                          },
                          initialCameraPosition: CameraPosition(
                            target: LatLng(state.latitude, state.longitude),
                            zoom: 15,
                          ),
                          markers: _markers,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: true,
                          mapToolbarEnabled: false,
                          onTap: (position) {
                            context.read<LocationCubit>().updateLocation(
                                  position.latitude,
                                  position.longitude,
                                );
                          },
                        ),
                        
                        // Loading indicator
                        if (state.isLoading)
                          Container(
                            color: Colors.black.withOpacity(0.3),
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Help text and action button
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tap on map or drag marker to set location',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: state.isLoading 
                          ? null 
                          : () => context.read<LocationCubit>().getCurrentLocation(context),
                      icon: state.isLoading 
                          ? const SizedBox(
                              width: 16, 
                              height: 16, 
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.my_location, size: 18),
                      label: Text(state.isLoading ? 'Locating...' : 'Use My Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateMapMarkers(LocationState state) {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('projectLocation'),
        position: LatLng(state.latitude, state.longitude),
        draggable: true,
        onDragEnd: (newPosition) {
          context.read<LocationCubit>().updateLocation(
                newPosition.latitude,
                newPosition.longitude,
              );
        },
      ),
    );
  }

  void _moveCamera(LocationState state) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(state.latitude, state.longitude),
            zoom: 15,
          ),
        ),
      );
    }
  }
}