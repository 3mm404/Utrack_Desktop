import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';
import 'liquid_card.dart';
import 'panel_header.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.trailing,
    this.compact = false,
  });
  final bool compact;
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => LiquidCard(
    child: Padding(
      padding: EdgeInsets.all(compact ? UiSpace.lg : UiSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PanelHeader(title: title, subtitle: subtitle, trailing: trailing),
          SizedBox(height: compact ? UiSpace.lg : UiSpace.xl),
          child,
        ],
      ),
    ),
  );
}
