import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';
import 'package:yelloskye/bloc/addproject/add_cubit.dart';
import 'package:yelloskye/bloc/addproject/add_state.dart';
import 'package:yelloskye/view/project/addproject/basicinfo.dart';
import 'package:yelloskye/view/project/addproject/image.dart';
import 'package:yelloskye/view/project/addproject/location.dart';
import 'package:yelloskye/view/project/addproject/vidoe.dart';
import '../../../bloc/project/project_cubit.dart';
import '../../../core/constants/colors.dart';
import '../../project/project_screen.dart'; // Import the ProjectScreen

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
          return current.uploadProgress == 1.0 && !previous.isSuccess && current.isSuccess;
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
            body: state.isLoading 
                ? _buildLoadingView(state) 
                : _buildFormView(context, state),
            bottomNavigationBar: state.isLoading 
                ? null 
                : _buildBottomButton(context, state),
          );
        },
      ),
    );
  }

  Widget _buildLoadingView(AddProjectState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            state.uploadStatus,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column( 
              children: [
                LinearProgressIndicator(
                  value: state.uploadProgress,
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Text(
                  '${(state.uploadProgress * 100).toInt()}% complete',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
              onPickThumbnail: () => context.read<AddProjectCubit>().pickThumbnail(),
              onPickImages: () => context.read<AddProjectCubit>().pickImages(),
              onRemoveImage: (index) => context.read<AddProjectCubit>().removeImage(index),
            ),
            const SizedBox(height: 20),
            VideoSection(
              projectVideos: state.projectVideos,
              onPickVideo: () => context.read<AddProjectCubit>().pickVideo(),
              onRemoveVideo: (index) => context.read<AddProjectCubit>().removeVideo(index),
            ),
            const SizedBox(height: 20),
            LocationSectionPage(
            initialLatitude: state.latitude,
              initialLongitude: state.longitude,
              initialLocationName: state.locationName, 
              onLocationChanged: (lat, lng) => 
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
        onPressed: () => context.read<AddProjectCubit>().submitProject(
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