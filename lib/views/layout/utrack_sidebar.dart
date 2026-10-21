import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';
import '../widgets/cherbyte_mark.dart';

const shellLabels = [
  'Inicio',
  'Zonas',
  'Biblioteca',
  'Dispositivos',
  'Ajustes',
];
const shellIcons = [
  Icons.home_outlined,
  Icons.multitrack_audio,
  Icons.library_music_outlined,
  Icons.speaker_group_outlined,
  Icons.settings,
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
    width: expanded ? 238 : 80,
    decoration: const BoxDecoration(
      color: UiColors.surface,
      border: Border(right: UiEffects.border),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: UiSpace.xxl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CherbyteMark(size: 48),
              if (expanded)
                const Padding(
                  padding: EdgeInsets.only(left: UiSpace.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UTRACK',
                        style: TextStyle(
                          fontSize: 19,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                          color: UiColors.text,
                        ),
                      ),
                      Text('ENGINE', style: UiType.caption),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: expanded ? 20 : 8,
              vertical: 8,
            ),
            children: [
              for (var i = 0; i < shellLabels.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: UiSpace.xl),
                  child: Tooltip(
                    message: shellLabels[i],
                    child: Material(
                      color: selected == i
                          ? UiColors.elevated
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: UiRadii.card,
                        side: BorderSide(
                          color: selected == i
                              ? UiColors.accent.withValues(alpha: .4)
                              : Colors.transparent,
                        ),
                      ),
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
