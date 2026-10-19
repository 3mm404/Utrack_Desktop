import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';

const shellLabels = [
  'Inicio',
  'Zonas',
  'Biblioteca',
  'Dispositivos',
  'Ajustes',
];
const shellIcons = [
  Icons.home_outlined,
  Icons.grid_view,
  Icons.library_music_outlined,
  Icons.speaker_group_outlined,
  Icons.tune,
];

class UtrackSidebar extends StatelessWidget {
  const UtrackSidebar({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.status,
    required this.connected,
    required this.expanded,
  });
  final int selected;
  final ValueChanged<int> onSelected;
  final String status;
  final bool connected, expanded;

  @override
  Widget build(BuildContext context) => Container(
    width: expanded ? 224 : 80,
    decoration: const BoxDecoration(
      color: UiColors.surface,
      border: Border(right: UiEffects.border),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: UiSpace.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.multitrack_audio, color: UiColors.accent),
              if (expanded)
                const Padding(
                  padding: EdgeInsets.only(left: UiSpace.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('UTRACK', style: UiType.title),
                      Text('ENGINE', style: UiType.caption),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(UiSpace.sm),
            children: [
              for (var i = 0; i < shellLabels.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: UiSpace.sm),
                  child: Tooltip(
                    message: shellLabels[i],
                    child: Material(
                      color: selected == i
                          ? UiColors.elevated
                          : Colors.transparent,
                      borderRadius: UiRadii.control,
                      child: InkWell(
                        borderRadius: UiRadii.control,
                        onTap: () => onSelected(i),
                        child: Padding(
                          padding: const EdgeInsets.all(UiSpace.lg),
                          child: Row(
                            mainAxisAlignment: expanded
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.center,
                            children: [
                              Icon(
                                shellIcons[i],
                                color: selected == i
                                    ? UiColors.accent
                                    : UiColors.muted,
                              ),
                              if (expanded) ...[
                                const SizedBox(width: UiSpace.md),
                                Expanded(
                                  child: Text(
                                    shellLabels[i],
                                    style: UiType.body.copyWith(
                                      color: selected == i
                                          ? UiColors.accent
                                          : UiColors.muted,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Tooltip(
          message: status,
          child: Padding(
            padding: const EdgeInsets.all(UiSpace.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: connected ? UiColors.operational : UiColors.muted,
                ),
                if (expanded) ...[
                  const SizedBox(width: UiSpace.sm),
                  Expanded(child: Text(status, style: UiType.caption)),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
