import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yelloskye/bloc/auth/auth_cubit.dart';
import 'package:yelloskye/bloc/auth/auth_state.dart';
import 'package:yelloskye/bloc/addproject/add_cubit.dart';
import 'package:yelloskye/bloc/homwnavigation/homerounte_cubit.dart';
import 'package:yelloskye/bloc/location/location_cubit.dart';
import 'package:yelloskye/bloc/project/project_cubit.dart';
import 'package:yelloskye/bloc/projectdetails/projectdetails_cubit.dart';
import 'package:yelloskye/bloc/videoplayer/viodeplayer_cubit.dart';
import 'package:yelloskye/firebase_options.dart';
import 'package:yelloskye/repositories/project_repository.dart';
import 'package:yelloskye/view/home_screen.dart';
import 'package:yelloskye/view/auth/login_screen.dart';
import 'package:yelloskye/core/constants/colors.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:yelloskye/view/splash/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Set preferred orientations (optional)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit()..checkUserLoggedIn(),
        ),
        BlocProvider<ProjectCubit>(
          create: (context) => ProjectCubit(repository: ProjectRepository())..loadProjects(),
        ),
        BlocProvider<AddProjectCubit>(
          create: (context) => AddProjectCubit(
            projectCubit: BlocProvider.of<ProjectCubit>(context),
          ),
        ),
        BlocProvider(
          create: (context) => LocationCubit(
            initialLatitude: 0.0,
            initialLongitude: 0.0,
            initialLocationName: 'Initial Location', 
          ),
        ),
        BlocProvider(
          create: (context) => ProjectDetailsCubit(),  
          child: Container(),
        ),
        BlocProvider(
          create: (context) => VideoPlayerCubit(), 
          child: Container(),
        ),
        BlocProvider(
          create: (context) => NavigationCubit(), 
          child: Container(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false, 
        title: 'YelloSkye',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Roboto',
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        // Use splash screen as the initial screen
        home: SplashScreen(
          nextScreen: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return HomeScreen();
              } else {
                return LoginScreen();
              }
            },
          ),
        ),
      ),
    );
  }
} 