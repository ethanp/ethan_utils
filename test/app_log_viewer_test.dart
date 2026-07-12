import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(appLogBuffer.clear);

  testWidgets('AppLogViewer builds selectable logs under CupertinoApp', (
    tester,
  ) async {
    appLogBuffer.record(
      component: 'Test',
      level: AppLogLevel.info,
      message: 'hello selectable',
    );
    appLogBuffer.record(
      component: 'Test',
      level: AppLogLevel.error,
      message: 'boom',
    );

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: SizedBox(
            height: 400,
            child: AppLogViewer(
              style: const AppLogViewerStyle(
                surface: Color(0xFF1C1F23),
                surfaceElevated: Color(0xFF262A30),
                border: Color(0xFF3A404A),
                accent: Color(0xFF2F8F86),
                textPrimary: Color(0xFFF2F4F6),
                textSecondary: Color(0xFFC5CBD3),
                textTertiary: Color(0xFF8B939E),
                warning: Color(0xFFD4A05A),
                error: Color(0xFFD46A6A),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('INFO|Test'), findsOneWidget);
    expect(find.textContaining('ERROR|Test'), findsOneWidget);
    expect(find.byType(SelectableRegion), findsOneWidget);
  });
}
