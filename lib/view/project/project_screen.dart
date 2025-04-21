import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yelloskye/bloc/auth/auth_cubit.dart';
import 'package:yelloskye/view/auth/login_screen.dart';
import 'package:yelloskye/view/project/addproject/add.dart';
import 'package:yelloskye/view/project/widgets/emptystate.dart';
import 'package:yelloskye/view/project/widgets/errorview.dart';
import 'package:yelloskye/view/project/widgets/projectcard.dart.dart';
import 'package:yelloskye/view/project/widgets/searachbar.dart';
import '../../bloc/project/project_cubit.dart';
import '../../bloc/project/project_state.dart';
import '../../core/constants/colors.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProjectCubit>().loadProjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshProjects() async {
    await context.read<ProjectCubit>().loadProjects();
  }

  void _navigateToAddProject() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProjectScreen()),
    );
  }

  void _onSearchChanged(String value) {
    context.read<ProjectCubit>().searchProjects(value);
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<ProjectCubit>().searchProjects('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      
        title: const Text(
          'Projects',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent, 
        elevation: 2,

        actions: [
          IconButton( 
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil( 
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              ); 
              context.read<AuthCubit>().signOut();
            },
            icon: Icon(Icons.logout), 
          ), 
        ],
      ),
      body: Column(
        children: [
          // Extracted search bar widget
          SearchBarWidget(
            controller: _searchController,
            hintText: 'Search projects...',
            onChanged: _onSearchChanged,
            onClear: _clearSearch,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshProjects,
              child: _buildProjectList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList() {
    return BlocBuilder<ProjectCubit, ProjectState>(
      builder: (context, state) {
        if (state is ProjectLoading) {
          return _buildShimmerLoading();
        } else if (state is ProjectError) {
          return ErrorView(message: state.message, onRetry: _refreshProjects);
        } else if (state is ProjectLoaded) {
          if (state.filteredProjects.isEmpty) {
            return const EmptyStateView(
              icon: Icons.search_off,
              message: 'No projects found',
            );
          }

          return ListView.builder(
            itemCount: state.filteredProjects.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) {
              final project = state.filteredProjects[index];
              return ProjectCard(project: project);
            },
          );
        } else {
          return const EmptyStateView(
            icon: Icons.folder_outlined,
            message: 'No projects available',
          );
        }
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          itemCount: 6, // Show 6 shimmer items while loading
          itemBuilder:
              (_, __) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shimmer for the top section (like title)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Container(
                          width: double.infinity,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      // Shimmer for the description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Shimmer for another line of text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Shimmer for the bottom section (like date or tags)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 80,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Container(
                              width: 50,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
