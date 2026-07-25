import 'package:flutter_test/flutter_test.dart';

import 'package:memory_bootle/main.dart';

void main() {
  testWidgets('App renders home page', (WidgetTester tester) async {
    await tester.pumpWidget(const MemoryBottleApp());

    // 验证首页主要元素存在
    expect(find.text('写下记忆'), findsOneWidget);
    expect(find.text('查看记忆'), findsOneWidget);
    expect(find.text('拾取漂流瓶'), findsOneWidget);
  });
}
