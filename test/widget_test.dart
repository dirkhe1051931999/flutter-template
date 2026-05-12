import 'package:oolaf_flutted/bootstrap.dart';
import 'package:oolaf_flutted/layouts/index.dart';
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
