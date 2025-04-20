import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/project/project_cubit.dart';
import '../../bloc/chart/chart_cubit.dart';
import '../../core/constants/colors.dart';

class ResponsiveChartScreen extends StatelessWidget {
  const ResponsiveChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChartCubit(
        projectCubit: context.read<ProjectCubit>(),
      ),
      child: const _ResponsiveChartView(),
    );
  }
}

class _ResponsiveChartView extends StatelessWidget {
  const _ResponsiveChartView();

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 70),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChartCubit, ChartState>(
      listener: (context, state) {
        if (state is ChartError) {
          _showSnackBar(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is ChartInitial || state is ChartLoading) {
          return _buildLoadingScaffold();
        } else if (state is ChartLoaded) {
          return _buildLoadedScaffold(context, state);
        } else {
          // Error state
          return _buildErrorScaffold(context);
        }
      },
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.insert_chart, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Responsive Charts',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Loading chart data...',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.insert_chart, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Responsive Charts',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Unable to load chart data'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<ChartCubit>().loadProjects(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedScaffold(BuildContext context, ChartLoaded state) {
    return Scaffold(
      appBar: state.isFullScreen
          ? null
          : AppBar(
              title: Row(
                children: [
                  Icon(Icons.insert_chart, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Responsive Charts',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: () => context.read<ChartCubit>().toggleFullScreen(),
                  color: AppColors.primary,
                ),
              ],
            ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ChartCubit>().loadProjects(),
        child: _buildResponsiveContent(context, state),
      ),
      floatingActionButton: state.isFullScreen
          ? FloatingActionButton(
              onPressed: () => context.read<ChartCubit>().toggleFullScreen(),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.fullscreen_exit),
            )
          : null,
    );
  }

  Widget _buildResponsiveContent(BuildContext context, ChartLoaded state) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        
        // Determine if we should stack or place side by side based on available space
        final bool shouldStack = isLandscape 
            ? screenWidth < 600 
            : screenHeight < 600;

        if (shouldStack || state.isFullScreen) {
          return _buildStackedLayout(context, state);
        } else if (isLandscape) {
          return _buildLandscapeLayout(context, state);
        } else {
          return _buildPortraitLayout(context, state);
        }
      },
    );
  }

  Widget _buildStackedLayout(BuildContext context, ChartLoaded state) {
    return Column(
      children: [
        if (!state.isFullScreen) _buildChartSelector(context, state),
        Expanded(
          child: state.projects.isEmpty
              ? _buildEmptyState(context)
              : Padding(
                  padding: EdgeInsets.all(state.isFullScreen ? 8.0 : 16.0),
                  child: _buildSelectedChart(state),
                ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, ChartLoaded state) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildChartSelector(context, state),
              Expanded(
                child: state.projects.isEmpty
                    ? _buildEmptyState(context)
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildSelectedChart(state),
                      ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildChartInfo(state),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(BuildContext context, ChartLoaded state) {
    return Column(
      children: [
        _buildChartSelector(context, state),
        Expanded(
          flex: 3,
          child: state.projects.isEmpty
              ? _buildEmptyState(context)
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildSelectedChart(state),
                ),
        ),
        Expanded(
          flex: 2,
          child: _buildChartInfo(state),
        ),
      ],
    );
  }

  Widget _buildChartSelector(BuildContext context, ChartLoaded state) {
    // Safety check to ensure chartTypes isn't empty to prevent range errors
    if (state.chartTypes.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: List.generate(
          state.chartTypes.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () => context.read<ChartCubit>().selectChartType(index),
              child: Container(
                decoration: BoxDecoration(
                  color: state.selectedChartIndex == index
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    state.chartTypes[index],
                    style: TextStyle(
                      color: state.selectedChartIndex == index
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedChart(ChartLoaded state) {
    // Safety checks to prevent range errors
    if (state.dataSets.isEmpty || 
        state.selectedChartIndex >= state.dataSets.length ||
        state.dataSets[state.selectedChartIndex].isEmpty) {
      return const Center(
        child: Text('No chart data available'),
      );
    }
    
    final currentDataSet = state.dataSets[state.selectedChartIndex];
    final currentColor = state.selectedChartIndex < state.chartColors.length
        ? state.chartColors[state.selectedChartIndex]
        : Colors.blue;
        
    // Handle potential empty labels
    final String labelsString = state.selectedChartIndex < state.axisLabels.length
        ? state.axisLabels[state.selectedChartIndex]
        : '';
    final labels = labelsString.isNotEmpty ? labelsString.split(',') : <String>[];
    
    // Get max Y value for scaling
    double maxY = 0;
    for (final spot in currentDataSet) {
      if (spot.y > maxY) maxY = spot.y;
    }
    maxY = (maxY * 1.2).ceilToDouble(); // Add 20% buffer
    maxY = maxY > 0 ? maxY : 10; // Ensure we have a valid maxY

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxY / 6,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final valueInt = value.toInt();
                if (valueInt < 0 || labels.isEmpty || valueInt >= labels.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    labels[valueInt],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 6,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox();
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        minX: 0,
        maxX: currentDataSet.isNotEmpty ? currentDataSet.last.x : 0,
        minY: 0,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 8,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final label = (index >= 0 && index < labels.length) ? labels[index] : '';
                return LineTooltipItem(
                  '${label.isNotEmpty ? "$label: " : ""}${spot.y.toInt()}',
                  TextStyle(color: currentColor, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: currentDataSet,
            isCurved: true,
            gradient: LinearGradient(
              colors: [currentColor.withOpacity(0.8), currentColor],
            ),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 6,
                color: currentColor,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  currentColor.withOpacity(0.3),
                  currentColor.withOpacity(0.05),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartInfo(ChartLoaded state) {
    // Safety check for index bounds
    if (state.chartTypes.isEmpty || state.selectedChartIndex >= state.chartTypes.length) {
      return const SizedBox.shrink();
    }
    
    final titles = [
      'Daily Progress Tracking',
      'Weekly Performance Metrics',
      'Monthly Growth Analysis',
    ];
    
    final descriptions = [
      'Track daily project completions and tasks assigned. This chart shows day-to-day fluctuations in team productivity throughout the week.',
      'Monitor weekly project metrics including new projects started, milestones achieved, and tasks completed by the team.',
      'Analyze monthly performance trends over the year, including completed projects, client satisfaction scores, and team efficiency metrics.',
    ];
    
    final metrics = [
      ['Tasks: 24', 'Completion Rate: 87%', 'Team Members: 8'],
      ['New Projects: 7', 'Milestones: 12', 'Completion Rate: 74%'],
      ['Q1 Growth: 24%', 'Q2 Growth: 35%', 'YoY Change: +41%'],
    ];

    // Make sure we have valid indices
    final titleIndex = state.selectedChartIndex < titles.length ? state.selectedChartIndex : 0;
    final descIndex = state.selectedChartIndex < descriptions.length ? state.selectedChartIndex : 0;
    final metricIndex = state.selectedChartIndex < metrics.length ? state.selectedChartIndex : 0;
    final colorIndex = state.selectedChartIndex < state.chartColors.length ? state.selectedChartIndex : 0;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titles[titleIndex],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              descriptions[descIndex],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Key Metrics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...metrics[metricIndex].map((metric) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: state.chartColors[colorIndex]),
                  const SizedBox(width: 8),
                  Text(
                    metric,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Icon(Icons.close, size: 72, color: Colors.grey[400]), 
          const SizedBox(height: 16),
          Text(
            'No chart data available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some projects to see analytics',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<ChartCubit>().loadProjects(),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  } 
} 