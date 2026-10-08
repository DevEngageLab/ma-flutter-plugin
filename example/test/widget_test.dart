// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_plugin_engagelab_ma_example/main.dart';

void main() {
  testWidgets(
      'renders standalone MA controls and optional association guidance',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('EngageLab MA 示例'), findsOneWidget);
    expect(find.text('检查 AppPush 自动绑定'), findsNothing);
    expect(find.textContaining('如业务方另行集成并初始化 AppPush'), findsOneWidget);
  });
}
