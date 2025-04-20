// models/chart_data_model.dart
import 'package:flutter/material.dart';

class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class TimeSeriesData {
  final DateTime date;
  final double value;

  TimeSeriesData({
    required this.date,
    required this.value,
  });
}

class ProjectChartData {
  final DateTime date;
  final int completed;
  final int inProgress;
  final int planned;

  ProjectChartData({
    required this.date,
    required this.completed,
    required this.inProgress,
    required this.planned,
  });
}

class TaskChartData {
  final DateTime date;
  final int completed;
  final int overdue;
  final int upcoming;

  TaskChartData({
    required this.date,
    required this.completed,
    required this.overdue,
    required this.upcoming,
  });
}

class ResourceChartData {
  final DateTime date;
  final int budget;
  final int actual;

  ResourceChartData({
    required this.date,
    required this.budget,
    required this.actual,
  });
}