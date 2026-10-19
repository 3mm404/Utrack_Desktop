import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';
import '../widgets/status_indicator.dart';
import '../widgets/ui_controls.dart';

class UtrackHeader extends StatelessWidget {
  const UtrackHeader({
    super.key,
    required this.title,
    required this.status,
    required this.connected,
    required this.onSettings,
    required this.onSearch,
  });
  final String title, status;
  final bool connected;
  final VoidCallback onSettings;
  final ValueChanged<String> onSearch;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final narrow = constraints.maxWidth < 700;
      final search = TextField(
        onSubmitted: onSearch,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'Buscar sección…',
          prefixIcon: Icon(Icons.search),
        ),
      );
      return Padding(
        padding: const EdgeInsets.all(UiSpace.lg),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: narrow ? Text(title, style: UiType.heading) : search,
                ),
                const SizedBox(width: UiSpace.lg),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: narrow ? 48 : 260),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: UiColors.input,
                      borderRadius: UiRadii.control,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(UiSpace.md),
                      child: StatusIndicator(
                        label: status,
                        status: connected
                            ? UiStatus.operational
                            : UiStatus.inactive,
                        showLabel: !narrow,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: UiSpace.sm),
                UiIconControl(
                  label: 'Abrir ajustes',
                  onPressed: onSettings,
                  icon: Icons.tune,
                  circular: true,
                ),
              ],
            ),
            if (narrow) ...[const SizedBox(height: UiSpace.md), search],
          ],
        ),
      );
    },
  );
}
