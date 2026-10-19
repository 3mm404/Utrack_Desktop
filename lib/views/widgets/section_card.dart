import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';
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
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      borderRadius: UiRadii.card,
      border: Border.fromBorderSide(UiEffects.border),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xff10151a), Color(0xff080c10)],
      ),
      boxShadow: [
        BoxShadow(
          color: Color(0x30000000),
          blurRadius: 16,
          offset: Offset(0, 5),
        ),
      ],
    ),
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
