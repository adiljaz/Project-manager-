import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yelloskye/bloc/addproject/add_cubit.dart';
import 'package:yelloskye/bloc/addproject/add_state.dart';
import 'package:yelloskye/view/project/addproject/basicinfo.dart';
import 'package:yelloskye/view/project/addproject/image.dart';
import 'package:yelloskye/view/project/addproject/location.dart';
import 'package:yelloskye/view/project/addproject/vidoe.dart';
import '../../../bloc/project/project_cubit.dart';
import '../../../core/constants/colors.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({Key? key}) : super(key: key);

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late AddProjectCubit _addProjectCubit;

  @override
  void initState() {
    super.initState();
    _addProjectCubit = AddProjectCubit(
      projectCubit: context.read<ProjectCubit>(),
    );
    _addProjectCubit.requestPermissions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addProjectCubit.close();
    super.dispose();
  }
 
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _addProjectCubit,
      child: BlocConsumer<AddProjectCubit, AddProjectState>(
        listenWhen: (previous, current) {
          // Respond to state changes only when upload completes
          return current.uploadProgress == 1.0 &&
              !previous.isSuccess &&
              current.isSuccess;
        },
        listener: (context, state) {
          if (state.error != null) {
            _showMessage(state.error!, isError: true);
            _addProjectCubit.clearError();
          }

          // When upload is complete and success is true, show message and navigate
          if (state.isSuccess && state.uploadProgress == 1.0) {
            _showMessage('Project added successfully!');

            // Force navigation to occur after build is complete
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Try direct navigation to ProjectScreen
              Navigator.of(context).pop();
            });
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Add New Project'),
              backgroundColor: AppColors.primary,
              elevation: 2,
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: _showHelpDialog,
                ),
              ],
            ),
            body:
                state.isLoading
                    ? _buildLoadingView(state)
                    : _buildFormView(context, state),
            bottomNavigationBar:
                state.isLoading ? null : _buildBottomButton(context, state),
          );
        },
      ),
    );
  }

  Widget _buildLoadingView(AddProjectState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loader
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * 3.14,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: null,
                        strokeWidth: 3,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: state.uploadProgress,
                        strokeWidth: 6,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 30),

          // Status message with fade-in animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Text(
                  state.uploadStatus,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          const SizedBox(height: 26),

          // Progress bar with animation
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upload Progress',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(state.uploadProgress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: state.uploadProgress),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  builder: (context, animatedValue, child) {
                    return LinearProgressIndicator(
                      value: animatedValue,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(state.uploadProgress, context),
                      ),
                      minHeight: 10,
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Cancel button
          if (state.uploadProgress < 1.0)
            TextButton.icon(
              onPressed: () {
                // Add cancel upload functionality here
              },
              icon: const Icon(Icons.cancel_outlined, size: 16),
              label: const Text('Cancel Upload'),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
            ),

          // Success animation when complete
          if (state.uploadProgress >= 1.0)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 36 * value,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // Helper function to get color based on progress
  Color _getProgressColor(double progress, BuildContext context) {
    if (progress < 0.3) {
      return Colors.orange;
    } else if (progress < 0.7) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  Widget _buildFormView(BuildContext context, AddProjectState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BasicInfoSection(
              nameController: _nameController,
              descriptionController: _descriptionController,
            ),
            const SizedBox(height: 20),
            ImageSection(
              thumbnailImage: state.thumbnailImage,
              projectImages: state.projectImages,
              onPickThumbnail:
                  () => context.read<AddProjectCubit>().pickThumbnail(),
              onPickImages: () => context.read<AddProjectCubit>().pickImages(),
              onRemoveImage:
                  (index) => context.read<AddProjectCubit>().removeImage(index),
            ),
            const SizedBox(height: 20),
            VideoSection(
              projectVideos: state.projectVideos,
              onPickVideo: () => context.read<AddProjectCubit>().pickVideo(),
              onRemoveVideo:
                  (index) => context.read<AddProjectCubit>().removeVideo(index),
            ),
            const SizedBox(height: 20),
            LocationSectionPage(
              initialLatitude: state.latitude,
              initialLongitude: state.longitude,
              initialLocationName: state.locationName,
              onLocationChanged:
                  (lat, lng) =>
                      context.read<AddProjectCubit>().updateLocation(lat, lng),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, AddProjectState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed:
            () => context.read<AddProjectCubit>().submitProject(
              formKey: _formKey,
              name: _nameController.text,
              description: _descriptionController.text,
            ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Save Project',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('How to Add a Project'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  '1. Basic Information',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Enter your project name and description.'),
                SizedBox(height: 16),
                Text(
                  '2. Media Files',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Add a thumbnail image, additional project images, and videos.',
                ),
                SizedBox(height: 16),
                Text(
                  '3. Location',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Use your current location or select a location on the map.',
                ),
                SizedBox(height: 16),
                Text('4. Save', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Click "Save Project" when you\'re done to upload your project.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Got it', style: TextStyle(color: AppColors.primary)),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}
