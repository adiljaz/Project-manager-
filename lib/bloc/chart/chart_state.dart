part of 'chart_cubit.dart';

abstract class ChartState extends Equatable {
  const ChartState();
  
  @override
  List<Object> get props => [];
}

class ChartInitial extends ChartState {}

class ChartLoading extends ChartState {}

class ChartLoaded extends ChartState {
  final List<Project> projects;
  final int selectedChartIndex;
  final bool isFullScreen;
  final List<List<FlSpot>> dataSets;
  final List<String> axisLabels;
  final List<Color> chartColors;
  final List<String> chartTypes;

  const ChartLoaded({
    required this.projects,
    required this.selectedChartIndex,
    required this.isFullScreen,
    required this.dataSets,
    required this.axisLabels,
    required this.chartColors,
    required this.chartTypes,
  });
  
  @override
  List<Object> get props => [
    projects, 
    selectedChartIndex, 
    isFullScreen, 
    dataSets, 
    axisLabels, 
    chartColors, 
    chartTypes
  ];
  
  ChartLoaded copyWith({
    List<Project>? projects,
    int? selectedChartIndex,
    bool? isFullScreen,
    List<List<FlSpot>>? dataSets,
    List<String>? axisLabels,
    List<Color>? chartColors,
    List<String>? chartTypes,
  }) {
    return ChartLoaded(
      projects: projects ?? this.projects,
      selectedChartIndex: selectedChartIndex ?? this.selectedChartIndex,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      dataSets: dataSets ?? this.dataSets,
      axisLabels: axisLabels ?? this.axisLabels,
      chartColors: chartColors ?? this.chartColors,
      chartTypes: chartTypes ?? this.chartTypes,
    );
  }
}
 
class ChartError extends ChartState {
  final String message;
  
  const ChartError(this.message);
  
  @override
  List<Object> get props => [message];
}