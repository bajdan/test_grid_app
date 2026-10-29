import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_grid_app/app.dart';
import 'package:test_grid_app/core/models/coordinate.dart';
import 'package:test_grid_app/core/models/grid_task.dart';
import 'package:test_grid_app/screens/home_screen/home_screen.dart';
import 'package:test_grid_app/screens/preview_screen/preview_screen.dart';
import 'package:test_grid_app/screens/result_list_screen/result_list_screen.dart';
import '../../../support/fake_task_repository.dart';

void main() {
  testWidgets('Home rejects non-HTTPS URLs without starting the process', (
    tester,
  ) async {
    final repository = FakeTaskRepository();
    await tester.pumpWidget(MyApp(repository: repository));
    await tester.enterText(
      find.byKey(const ValueKey('api_url_field')),
      'http://flutter.webspark.dev/flutter/api',
    );

    await tester.tap(find.byKey(const ValueKey('start_button')));
    await tester.pump();

    expect(find.text('Enter a valid full HTTPS URL.'), findsOneWidget);
    expect(repository.fetchCount, 0);
  });

  testWidgets('Home loads and selects a previously successful URL', (
    tester,
  ) async {
    const previousUrl = 'https://flutter.webspark.dev/flutter/api?token=abc';
    await tester.pumpWidget(
      MyApp(
        repository: FakeTaskRepository(successfulUrls: const [previousUrl]),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('saved_url_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(previousUrl).last);
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('api_url_field')))
          .controller!
          .text,
      previousUrl,
    );
  });

  testWidgets(
    'successful submit opens results; Back from results returns Home',
    (tester) async {
      final repository = FakeTaskRepository();
      await tester.pumpWidget(MyApp(repository: repository));
      await tester.enterText(
        find.byKey(const ValueKey('api_url_field')),
        'https://flutter.webspark.dev/flutter/api?token=abc',
      );
      await tester.tap(find.byKey(const ValueKey('start_button')));
      await tester.pumpAndSettle();

      expect(find.text('Process screen'), findsOneWidget);
      expect(find.byKey(const ValueKey('send_results_button')), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('send_results_button')));
      await tester.pumpAndSettle();

      expect(find.byType(ResultListScreen), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('(0,0)->(1,1)->(2,2)'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Home screen'), findsOneWidget);
      expect(find.byKey(const ValueKey('saved_url_dropdown')), findsOneWidget);
    },
  );

  testWidgets(
    'Preview shows coordinate grid colors and returns to the result list',
    (tester) async {
      final repository = FakeTaskRepository(
        tasks: [
          GridTask(
            id: 'task-1',
            field: const ['.X.', '...', 'X..'],
            start: const Coordinate(0, 0),
            end: const Coordinate(2, 2),
          ),
        ],
      );
      await tester.pumpWidget(MyApp(repository: repository));
      await tester.enterText(
        find.byKey(const ValueKey('api_url_field')),
        'https://flutter.webspark.dev/flutter/api',
      );
      await tester.tap(find.byKey(const ValueKey('start_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('send_results_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('result_task-1')));
      await tester.pumpAndSettle();

      expect(find.byType(PreviewScreen), findsOneWidget);
      expect(find.text('(0,0)->(1,1)->(2,2)'), findsOneWidget);
      expect(find.text('(2,2)'), findsAtLeastNWidgets(1));
      expect(
        tester
            .widget<Container>(find.byKey(const ValueKey('grid_cell_0_0')))
            .color,
        const Color(0xFF64FFDA),
      );
      expect(
        tester
            .widget<Container>(find.byKey(const ValueKey('grid_cell_1_1')))
            .color,
        const Color(0xFF4CAF50),
      );
      expect(
        tester
            .widget<Container>(find.byKey(const ValueKey('grid_cell_2_2')))
            .color,
        const Color(0xFF009688),
      );
      expect(
        tester
            .widget<Container>(find.byKey(const ValueKey('grid_cell_1_0')))
            .color,
        Colors.black,
      );
      expect(
        tester
            .widget<Container>(find.byKey(const ValueKey('grid_cell_2_0')))
            .color,
        Colors.white,
      );

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(ResultListScreen), findsOneWidget);
    },
  );

  testWidgets(
    'failed POST shows an error and keeps submit available for retry',
    (tester) async {
      final repository = FakeTaskRepository(failSubmissionCount: 1);
      await tester.pumpWidget(MyApp(repository: repository));
      await tester.enterText(
        find.byKey(const ValueKey('api_url_field')),
        'https://flutter.webspark.dev/flutter/api',
      );
      await tester.tap(find.byKey(const ValueKey('start_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('send_results_button')));
      await tester.pumpAndSettle();

      expect(find.text('Could not send results'), findsOneWidget);
      expect(find.byKey(const ValueKey('send_results_button')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('send_results_button')));
      await tester.pumpAndSettle();
      expect(find.byType(ResultListScreen), findsOneWidget);
      expect(repository.submitCount, 2);
    },
  );

  testWidgets('request errors are shown with a retry action', (tester) async {
    final repository = FakeTaskRepository(
      fetchError: Exception('network unavailable'),
    );
    await tester.pumpWidget(MyApp(repository: repository));
    await tester.enterText(
      find.byKey(const ValueKey('api_url_field')),
      'https://flutter.webspark.dev/flutter/api',
    );
    await tester.tap(find.byKey(const ValueKey('start_button')));
    await tester.pumpAndSettle();

    expect(find.text('network unavailable'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('retry_processing_button')),
      findsOneWidget,
    );
  });

  testWidgets('calculation errors are shown and block submission', (
    tester,
  ) async {
    final repository = FakeTaskRepository(
      tasks: [
        GridTask(
          id: 'unreachable',
          field: const ['.X.', 'XXX', '...'],
          start: const Coordinate(0, 0),
          end: const Coordinate(2, 2),
        ),
      ],
    );
    await tester.pumpWidget(MyApp(repository: repository));
    await tester.enterText(
      find.byKey(const ValueKey('api_url_field')),
      'https://flutter.webspark.dev/flutter/api',
    );
    await tester.tap(find.byKey(const ValueKey('start_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('process_error')), findsOneWidget);
    expect(find.byKey(const ValueKey('send_results_button')), findsNothing);
  });

  testWidgets(
    'empty task data can be submitted and opens an empty result list',
    (tester) async {
      final repository = FakeTaskRepository(tasks: const []);
      await tester.pumpWidget(MyApp(repository: repository));
      await tester.enterText(
        find.byKey(const ValueKey('api_url_field')),
        'https://flutter.webspark.dev/flutter/api',
      );
      await tester.tap(find.byKey(const ValueKey('start_button')));
      await tester.pumpAndSettle();
      expect(find.text('100%'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('send_results_button')));
      await tester.pumpAndSettle();

      expect(find.text('No tasks found.'), findsOneWidget);
      expect(repository.lastSubmittedResults, isEmpty);
    },
  );

  testWidgets('submission shows a loader and disables the send button', (
    tester,
  ) async {
    final submit = Completer<void>();
    final repository = FakeTaskRepository(submissionCompleter: submit);
    await tester.pumpWidget(MyApp(repository: repository));
    await tester.enterText(
      find.byKey(const ValueKey('api_url_field')),
      'https://flutter.webspark.dev/flutter/api',
    );
    await tester.tap(find.byKey(const ValueKey('start_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('send_results_button')));
    await tester.pump();

    final sendButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('send_results_button')),
    );
    expect(sendButton.onPressed, isNull);
    expect(find.byKey(const ValueKey('submit_loader')), findsOneWidget);

    submit.complete();
    await tester.pumpAndSettle();
    expect(find.byType(ResultListScreen), findsOneWidget);
  });
}
