import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:test_grid_app/core/repositories/task_repository.dart';

class HomeState {
  const HomeState({this.successfulUrls = const [], this.isLoading = true});

  final List<String> successfulUrls;
  final bool isLoading;
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeState());

  final TaskRepository _repository;

  Future<void> loadSuccessfulUrls() async {
    try {
      final urls = await _repository.loadSuccessfulUrls();
      emit(
        HomeState(successfulUrls: List.unmodifiable(urls), isLoading: false),
      );
    } catch (_) {
      emit(const HomeState(isLoading: false));
    }
  }
}
