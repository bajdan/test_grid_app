import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:test_grid_app/app.dart';
import '../test/support/fake_task_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user fetches, submits, and previews a shortest path', (
    tester,
  ) async {
    final repository = FakeTaskRepository();
    await tester.pumpWidget(MyApp(repository: repository));
    await tester.enterText(
      find.byKey(const ValueKey('api_url_field')),
      'https://flutter.webspark.dev/flutter/api',
    );
    await tester.tap(find.byKey(const ValueKey('start_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('send_results_button')));
    await tester.pumpAndSettle();

    expect(find.text('(0,0)->(1,1)->(2,2)'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('result_task-1')));
    await tester.pumpAndSettle();
    expect(find.text('Preview screen'), findsOneWidget);
    expect(find.text('(0,0)->(1,1)->(2,2)'), findsOneWidget);
  });
}
