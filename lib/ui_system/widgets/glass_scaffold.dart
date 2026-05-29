import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    required this.title,
    required this.body,
    super.key,
    this.actions = const [],
    this.leading,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final effectiveLeading =
        leading ??
        (Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
              )
            : null);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(220, 235, 255, 0.25),
                Color.fromRGBO(240, 245, 250, 0.12),
                Color.fromRGBO(255, 255, 255, 0.05),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1.0,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                GlassToolbar(
                  title: title,
                  leading: effectiveLeading,
                  actions: actions,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: body,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlassToolbar extends StatelessWidget {
  const GlassToolbar({
    required this.title,
    super.key,
    this.leading,
    this.actions = const [],
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          SizedBox(width: 48, child: leading),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
