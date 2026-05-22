import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trainer_app/features/home/home_screen.dart';
import 'package:trainer_app/providers/repository_providers.dart';
import '../../fakes/fake_repositories.dart';

Widget _wrap() => ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );

void main() {
  group('HomeScreen (trainer)', () {
    testWidgets('shows greeting with trainer name Aarav', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Hi, Aarav 👋'), findsOneWidget);
    });

    testWidgets('shows Trainer role badge', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Trainer'), findsOneWidget);
    });
  });
}
