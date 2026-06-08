import 'package:flutter_test/flutter_test.dart';

import 'package:memory_bottle/main.dart';

void main() {
  testWidgets('App renders home page', (WidgetTester tester) async {
    await tester.pumpWidget(const MemoryBottleApp());

    // 等待第一帧渲染（避免 pumpAndSettle 触发 Provider 错误回调）
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('记忆漂流瓶'), findsOneWidget);
    expect(find.text('写下记忆'), findsOneWidget);
    expect(find.text('查看记忆'), findsOneWidget);
  });
}
