import 'package:flutter/material.dart';
import '../design/ui_appearance.dart';
import '../design/ui_palette.dart';
import '../widgets/status_indicator.dart';
import '../widgets/app_surface.dart';

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
  Icons.settings_outlined,
];

class UtrackHeader extends StatelessWidget {
  const UtrackHeader({
    super.key,
    required this.title,
    required this.status,
    required this.connected,
    this.selected = 0,
    this.onSelected,
  });
  final String title, status;
  final bool connected;
  final int selected;
  final ValueChanged<int>? onSelected;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final palette = UiPalette.of(context);
      final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final showSections = constraints.maxWidth >= 1200 * textScale;
      final navigationGap = ((constraints.maxWidth - 1100) / 10).clamp(
        12.0,
        140.0,
      );
      return AppSurface(
        panel: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Image.asset(
                'assets/branding/utrack-symbol-transparent.png',
                width: 30,
                height: 30,
                cacheWidth: 60,
                semanticLabel: 'UTRACK Sound',
              ),
              const SizedBox(width: 35),
              Flexible(
                flex: 3,
                child: Text(
                  'UTRACK',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiText.of(context).label.copyWith(
                    letterSpacing: 4,
                    fontSize: constraints.maxWidth < 600 ? 12 : 16,
                  ),
                ),
              ),
              if (showSections && onSelected != null) ...[
                const SizedBox(width: 24),
                for (final section in const [
                  (0, 'Inicio'),
                  (1, 'Zonas'),
                  (2, 'Biblioteca'),
                  (4, 'Configuración'),
                ])
                  Padding(
                    padding: EdgeInsets.only(right: navigationGap),
                    child: TextButton(
                      onPressed: () => onSelected!(section.$1),
                      style: TextButton.styleFrom(
                        foregroundColor: selected == section.$1
                            ? palette.accent
                            : palette.text,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            section.$2,
                            style: const TextStyle(fontFamily: 'Roboto'),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            height: 3,
                            width: 24,
                            color: selected == section.$1
                                ? palette.accent
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
              const Spacer(),
              Tooltip(
                message: status,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 170),
                  child: StatusIndicator(
                    label: status,
                    status: connected
                        ? UiStatus.operational
                        : UiStatus.inactive,
                    showLabel: constraints.maxWidth >= 620,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const ThemeToggle(),
              const SizedBox(width: 4),
              PopupMenuButton<int>(
                tooltip: 'Abrir navegación',
                icon: const Icon(Icons.more_horiz_rounded),
                initialValue: selected,
                onSelected: onSelected,
                itemBuilder: (context) => [
                  for (var index = 0; index < shellLabels.length; index++)
                    PopupMenuItem(
                      value: index,
                      child: Tooltip(
                        message: shellLabels[index],
                        child: Row(
                          children: [
                            Icon(shellIcons[index], size: 20),
                            const SizedBox(width: 12),
                            Text(shellLabels[index]),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
