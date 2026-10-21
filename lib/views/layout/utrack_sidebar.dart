import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';
import '../design/ui_palette.dart';
import '../widgets/cherbyte_mark.dart';

const shellLabels = [
  'Inicio',
  'Zonas',
  'Biblioteca',
  'Dispositivos',
  'Ajustes',
  'Programación',
];
const shellIcons = [
  Icons.home_outlined,
  Icons.multitrack_audio,
  Icons.library_music_outlined,
  Icons.speaker_group_outlined,
  Icons.settings,
  Icons.calendar_month_outlined,
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
    decoration: BoxDecoration(
      color: UiPalette.of(context).surface,
      border: Border(right: UiDecor.of(context).border),
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
                Padding(
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
                          color: UiPalette.of(context).text,
                        ),
                      ),
                      Text('ENGINE', style: UiText.of(context).caption),
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
                          ? UiPalette.of(context).elevated
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: UiRadii.card,
                        side: BorderSide(
                          color: selected == i
                              ? UiPalette.of(
                                  context,
                                ).accent.withValues(alpha: .4)
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
                                    ? UiPalette.of(context).blue
                                    : UiPalette.of(context).muted,
                              ),
                              if (expanded) ...[
                                const SizedBox(width: UiSpace.md),
                                Expanded(
                                  child: Text(
                                    shellLabels[i],
                                    style: UiText.of(context).body.copyWith(
                                      color: selected == i
                                          ? UiPalette.of(context).blue
                                          : UiPalette.of(context).muted,
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
                  color: connected
                      ? UiPalette.of(context).operational
                      : UiPalette.of(context).muted,
                ),
                if (expanded) ...[
                  const SizedBox(width: UiSpace.sm),
                  Expanded(
                    child: Text(status, style: UiText.of(context).caption),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
