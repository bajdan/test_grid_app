import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_grid_app/core/api/task_api_client.dart';
import 'package:test_grid_app/core/models/coordinate.dart';
import 'package:test_grid_app/core/models/grid_task.dart';
import 'package:test_grid_app/core/models/solved_task.dart';
import 'package:test_grid_app/core/repositories/task_repository_impl.dart';
import 'package:test_grid_app/core/storage/url_history_store.dart';

void main() {
  group('TaskRepositoryImpl', () {
    test('fetches and parses tasks from the full entered URL', () async {
      final uri = Uri.parse(
        'https://flutter.webspark.dev/flutter/api?token=abc',
      );
      final repository = TaskRepositoryImpl(
        apiClient: TaskApiClient(
          client: MockClient((request) async {
            expect(request.method, 'GET');
            expect(request.url, uri);
            return http.Response(
              jsonEncode({
                'error': false,
                'message': '',
                'data': [
                  {
                    'id': 'task-1',
                    'field': ['.X.', '...', 'X..'],
                    'start': {'x': 2, 'y': 1},
                    'end': {'x': 1, 'y': 2},
                  },
                ],
              }),
              200,
            );
          }),
        ),
        historyStore: _MemoryUrlHistoryStore(),
      );

      final tasks = await repository.fetchTasks(uri);

      expect(tasks, hasLength(1));
      expect(tasks.single.id, 'task-1');
      expect(tasks.single.start, const Coordinate(2, 1));
      expect(tasks.single.end, const Coordinate(1, 2));
      expect(
        tasks.single.field[tasks.single.start.y][tasks.single.start.x],
        '.',
      );
    });

    test('rejects API-declared errors and malformed square grids', () async {
      final apiError = TaskRepositoryImpl(
        apiClient: TaskApiClient(
          client: MockClient(
            (_) async => http.Response(
              jsonEncode({'error': true, 'message': 'No tasks', 'data': []}),
              200,
            ),
          ),
        ),
        historyStore: _MemoryUrlHistoryStore(),
      );
      final malformedGrid = TaskRepositoryImpl(
        apiClient: TaskApiClient(
          client: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'error': false,
                'data': [
                  {
                    'id': 'bad',
                    'field': ['..', '.'],
                    'start': {'x': 0, 'y': 0},
                    'end': {'x': 1, 'y': 1},
                  },
                ],
              }),
              200,
            ),
          ),
        ),
        historyStore: _MemoryUrlHistoryStore(),
      );

      await expectLater(
        apiError.fetchTasks(Uri.parse('https://example.com/api')),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'No tasks',
          ),
        ),
      );
      await expectLater(
        malformedGrid.fetchTasks(Uri.parse('https://example.com/api')),
        throwsFormatException,
      );
    });

    test('rejects invalid JSON and coordinates outside the grid', () async {
      final invalidJson = TaskRepositoryImpl(
        apiClient: TaskApiClient(
          client: MockClient((_) async => http.Response('{', 200)),
        ),
        historyStore: _MemoryUrlHistoryStore(),
      );
      final invalidCoordinates = TaskRepositoryImpl(
        apiClient: TaskApiClient(
          client: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'error': false,
                'data': [
                  {
                    'id': 'bad',
                    'field': ['..', '..'],
                    'start': {'x': 2, 'y': 0},
                    'end': {'x': 1, 'y': 1},
                  },
                ],
              }),
              200,
            ),
          ),
        ),
        historyStore: _MemoryUrlHistoryStore(),
      );

      await expectLater(
        invalidJson.fetchTasks(Uri.parse('https://example.com/api')),
        throwsA(isA<ApiException>()),
      );
      await expectLater(
        invalidCoordinates.fetchTasks(Uri.parse('https://example.com/api')),
        throwsFormatException,
      );
    });

    test(
      'sends results to the full entered URL with string coordinates',
      () async {
        final uri = Uri.parse(
          'https://flutter.webspark.dev/flutter/api?token=abc',
        );
        final repository = TaskRepositoryImpl(
          apiClient: TaskApiClient(
            client: MockClient((request) async {
              expect(request.method, 'POST');
              expect(request.url, uri);
              expect(jsonDecode(request.body), [
                {
                  'id': 'task-1',
                  'result': {
                    'steps': [
                      {'x': '0', 'y': '0'},
                      {'x': '0', 'y': '1'},
                    ],
                    'path': '(0,0)->(0,1)',
                  },
                },
              ]);
              return http.Response('', 200);
            }),
          ),
          historyStore: _MemoryUrlHistoryStore(),
        );
        final result = SolvedTask(
          task: GridTask(
            id: 'task-1',
            field: const ['..', '..'],
            start: const Coordinate(0, 0),
            end: const Coordinate(0, 1),
          ),
          steps: const [Coordinate(0, 0), Coordinate(0, 1)],
        );

        await repository.submitResults(uri, [result]);
      },
    );

    test('raises a clear error for a non-success HTTP response', () async {
      final repository = TaskRepositoryImpl(
        apiClient: TaskApiClient(
          client: MockClient((_) async => http.Response('unavailable', 503)),
        ),
        historyStore: _MemoryUrlHistoryStore(),
      );

      await expectLater(
        repository.fetchTasks(Uri.parse('https://example.com/api')),
        throwsA(isA<ApiException>()),
      );
    });
  });

  test(
    'successful URL history persists newest first without duplicates',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = SharedPreferencesUrlHistoryStore();

      await store.saveSuccessful('https://example.com/first');
      await store.saveSuccessful('https://example.com/second');
      await store.saveSuccessful('https://example.com/first');

      expect(await store.load(), [
        'https://example.com/first',
        'https://example.com/second',
      ]);
    },
  );
}

class _MemoryUrlHistoryStore extends UrlHistoryStore {
  final List<String> values = [];

  @override
  Future<List<String>> load() async => List.of(values);

  @override
  Future<void> saveSuccessful(String url) async {
    values
      ..remove(url)
      ..insert(0, url);
  }
}
