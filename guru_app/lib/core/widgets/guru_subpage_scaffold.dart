import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Scaffold for screens below Home: AppBar back + Android system back handling.
class GuruSubpageScaffold extends StatelessWidget {
  const GuruSubpageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.preferPop = false,
  });

  final Widget title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  /// When true, back tries [GoRouter.pop] first (e.g. conversation → chat list).
  final bool preferPop;

  void _handleBack(BuildContext context) {
    if (preferPop && context.canPop()) {
      context.pop();
      return;
    }
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _handleBack(context);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
            onPressed: () => _handleBack(context),
          ),
          title: title,
          actions: actions,
        ),
        body: body,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
