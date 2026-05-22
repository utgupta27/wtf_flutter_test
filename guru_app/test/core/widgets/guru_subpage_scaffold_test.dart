import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guru_app/core/widgets/guru_subpage_scaffold.dart';

void main() {
  testWidgets('back button navigates to home', (tester) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/sub',
          builder: (context, state) => const GuruSubpageScaffold(
            title: Text('Sub'),
            body: Text('Subpage'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    router.go('/sub');
    await tester.pumpAndSettle();

    expect(find.text('Subpage'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });
}
