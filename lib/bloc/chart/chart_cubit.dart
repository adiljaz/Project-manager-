import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:yelloskye/bloc/project/project_cubit.dart';
import 'package:yelloskye/bloc/project/project_state.dart';
import 'package:yelloskye/models/project_model.dart';

part 'chart_state.dart';

class ChartCubit extends Cubit<ChartState> {
  final ProjectCubit projectCubit;
  
  // Default chart data
  static final List<String> defaultChartTypes = [
    'Daily Progress',
    'Weekly Metrics',
    'Monthly Performance',
  ];
  
  static final List<List<FlSpot>> defaultDataSets = [
    // Daily data
    [
      FlSpot(0, 3),
      FlSpot(1, 1),
      FlSpot(2, 4),
      FlSpot(3, 2),
      FlSpot(4, 5),
      FlSpot(5, 3),
      FlSpot(6, 6),
    ],
    // Weekly data
    [
      FlSpot(0, 2),
      FlSpot(1, 5),
      FlSpot(2, 3),
      FlSpot(3, 7),
      FlSpot(4, 2),
    ],
    // Monthly data
    [
      FlSpot(0, 4),
      FlSpot(1, 7),
      FlSpot(2, 5),
      FlSpot(3, 8),
      FlSpot(4, 6),
      FlSpot(5, 9),
      FlSpot(6, 7),
      FlSpot(7, 10),
      FlSpot(8, 8),
      FlSpot(9, 12),
      FlSpot(10, 9),
      FlSpot(11, 14),
    ],
  ];
  
  static final List<String> defaultAxisLabels = [
    'Mon,Tue,Wed,Thu,Fri,Sat,Sun',
    'Week 1,Week 2,Week 3,Week 4,Week 5',
    'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec',
  ];
  
  static final List<Color> defaultChartColors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
  ];
  
  ChartCubit({required this.projectCubit}) : super(ChartInitial()) {
    // Initialize with default values
    emit(ChartLoaded(
      projects: [],
      selectedChartIndex: 0,
      isFullScreen: false,
      dataSets: defaultDataSets,
      axisLabels: defaultAxisLabels,
      chartColors: defaultChartColors,
      chartTypes: defaultChartTypes,
    ));
    
    loadProjects();
  }
  
  Future<void> loadProjects() async {
    if (isClosed) return; // Check if the cubit is closed before emitting
    
    emit(ChartLoading());
    
    try {
      await projectCubit.loadProjects();
      
      if (isClosed) return; // Check again after the async operation
      
      // If we're already in a loaded state, get those values
      final currentState = state;
      if (currentState is ChartLoaded) {
        final projects = projectCubit.state is ProjectLoaded 
            ? (projectCubit.state as ProjectLoaded).projects 
            : <Project>[];
        emit(currentState.copyWith(projects: projects));
      } else {
        // This should not happen but just in case
        final projects = projectCubit.state is ProjectLoaded 
            ? (projectCubit.state as ProjectLoaded).projects 
            : <Project>[];
        emit(ChartLoaded(
          projects: projects,
          selectedChartIndex: 0,
          isFullScreen: false,
          dataSets: defaultDataSets,
          axisLabels: defaultAxisLabels,
          chartColors: defaultChartColors,
          chartTypes: defaultChartTypes,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(ChartError('Unable to load project data. Pull down to refresh.'));
      }
    }
  }
  
  void selectChartType(int index) {
    if (isClosed) return;
    
    if (state is ChartLoaded) {
      final currentState = state as ChartLoaded;
      emit(currentState.copyWith(selectedChartIndex: index));
    }
  }
  
  void toggleFullScreen() {
    if (isClosed) return;
    
    if (state is ChartLoaded) {
      final currentState = state as ChartLoaded;
      emit(currentState.copyWith(isFullScreen: !currentState.isFullScreen));
    }
  }
  
  @override
  Future<void> close() {
    // Clean up resources if needed
    return super.close();
  }
}  