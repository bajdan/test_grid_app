import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:test_grid_app/core/api/task_api_client.dart';
import 'package:test_grid_app/core/repositories/task_repository.dart';
import 'package:test_grid_app/core/repositories/task_repository_impl.dart';
import 'package:test_grid_app/core/storage/url_history_store.dart';
import 'package:test_grid_app/screens/home_screen/home_cubit.dart';
import 'package:test_grid_app/screens/home_screen/home_screen.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key, TaskRepository? repository})
      : repository =
      repository ??
          TaskRepositoryImpl(
            apiClient: TaskApiClient(),
            historyStore: SharedPreferencesUrlHistoryStore(),
          );

  final TaskRepository repository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<TaskRepository>.value(
      value: repository,
      child: MaterialApp(
        title: 'Grid Path Finder',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF009688)),
          useMaterial3: true,
        ),
        home: BlocProvider(
          create: (context) =>
          HomeCubit(context.read<TaskRepository>())..loadSuccessfulUrls(),
          child: const HomeScreen(),
        ),
      ),
    );
  }
}