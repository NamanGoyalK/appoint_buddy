import 'package:appoint_buddy/repos/firebase_patient_repo.dart';
import 'package:appoint_buddy/screens/loading_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'backend/auth_cubit.dart';
import 'backend/calender_cubit.dart';
import 'backend/day_cubit.dart';
import 'backend/patient_cubit.dart';
import 'core/app_colors.dart';
import 'repos/firebase_auth_repo.dart';
import 'screens/auth_page.dart';
import 'screens/home_page.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of the application.
  MyApp({super.key});

  //auth repo
  final authRepo = FirebaseAuthRepo();
  //patient repo
  final patientRepo = FirebasePatientRepo();

  @override
  Widget build(BuildContext context) {
    //Providing cubits
    return MultiBlocProvider(
      providers: [
        //Auth Cubit
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(
            authRepo: authRepo,
          )..checkAuth(),
        ),
        //Patient Cubit
        BlocProvider<PatientCubit>(
          create: (_) => PatientCubit(
            patientRepo: patientRepo,
          ),
        ),
        // Calendar Format Cubit
        BlocProvider<CalendarFormatCubit>(
          create: (_) => CalendarFormatCubit(),
        ),
        // Day Cubit
        BlocProvider<DayCubit>(
          create: (_) => DayCubit(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(0.9),
              boldText: false,
            ), // 🔹 Prevents system text scaling
            child: child!,
          );
        },
        theme: appThemeMain().copyWith(
          colorScheme: appThemeMain().colorScheme.copyWith(),
        ),
        darkTheme: appThemeDark().copyWith(
          colorScheme: appThemeDark().colorScheme.copyWith(),
        ),
        themeMode: ThemeMode.system,
        home: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, authState) {
            if (authState is AuthError) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    authState.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
              );
            }
          },
          builder: (context, authState) {
            if (kDebugMode) {
              print('Current State:$authState');
            }

            //Unauthenticated --> AuthPage
            if (authState is Authenticated) {
              return HomePage();
            }
            //Authenticated --> HomePage
            if (authState is UnAuthenticated) {
              return const AuthPage();
            }
            //AuthLoading --> loading...
            else {
              return const Scaffold(
                body: Center(
                  child: LoadingPage(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
