// // lib/routes.dart
// import 'package:flutter/material.dart';
// import 'package:yelloskye/view/forgot_password_screen.dart';
// import 'package:yelloskye/view/home_screen.dart';
// import 'package:yelloskye/view/login_screen.dart';
// import 'package:yelloskye/view/signup_screen.dart';


// class AppRoutes {
//   static const String login = '/login';
//   static const String signup = '/signup';
//   static const String forgotPassword = '/forgot-password';
//   static const String home = '/home';

//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case login:
//         return MaterialPageRoute(builder: (_) => LoginScreen());
//       case signup:
//         return MaterialPageRoute(builder: (_) => SignupScreen());
//       case forgotPassword:
//         return MaterialPageRoute(builder: (_) => ForgotPasswordScreen());
//       case home:
//         return MaterialPageRoute(builder: (_) => HomeScreen());
//       default:
//         return MaterialPageRoute(
//           builder: (_) => Scaffold(
//             body: Center(
//               child: Text('No route defined for ${settings.name}'),
//             ),
//           ),
//         );
//     }
//   }
// }