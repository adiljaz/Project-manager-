import 'package:flutter_bloc/flutter_bloc.dart';

// Navigation states aren't needed here since we're just using an int,
// but this shows the proper structure if you need to add more functionality later

class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);

  /// Navigates to the specified tab index
  void navigateTo(int index) => emit(index);
  
  /// Returns to the projects tab (index 0)
  void goToProjects() => emit(0);
  
  /// Navigates to the map tab (index 1)
  void goToMap() => emit(1);
  
  /// Navigates to the charts tab (index 2)
  void goToCharts() => emit(2);
}