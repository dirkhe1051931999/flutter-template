import 'package:flutter_template_start/bootstrap.dart';
import 'package:flutter_template_start/layouts/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final bootstrap = createAppBootstrap();

    await tester.pumpWidget(
      Layout(
        router: bootstrap.router,
        store: bootstrap.store,
      ),
    );

    expect(find.byType(Layout), findsOneWidget);
  });
}
