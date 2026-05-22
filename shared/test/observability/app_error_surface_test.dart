import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/observability/app_error_surface.dart';

void main() {
  testWidgets('error snackbar shows Copy error action', (tester) async {
    final messengerKey = GlobalKey<ScaffoldMessengerState>();
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: messengerKey,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AppErrorSurface.showError(
                context,
                userMessage: 'Something went wrong',
                technicalDetail: 'status=500',
              ),
              child: const Text('Trigger'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Trigger'));
    await tester.pump();

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text(AppErrorSurface.copyActionLabel), findsOneWidget);
  });

  testWidgets('info snackbar has no copy action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  AppErrorSurface.showInfo(context, 'All good'),
              child: const Text('Info'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Info'));
    await tester.pump();

    expect(find.text('All good'), findsOneWidget);
    expect(find.text(AppErrorSurface.copyActionLabel), findsNothing);
  });
}
