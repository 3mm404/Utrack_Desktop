import 'accessible_controls.dart';
import 'package:flutter/material.dart';
import '../../models/engine_status.dart';

class PlaylistDownloadControl extends StatelessWidget {
  const PlaylistDownloadControl({
    super.key,
    required this.playlist,
    required this.enabled,
    required this.pending,
    required this.onAction,
  });
  final PlaylistInfo playlist;
  final bool enabled, pending;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final d = playlist.download;
    final label = d.active
        ? 'Cancelar descarga'
        : d.ready
        ? 'Verificar y actualizar'
        : 'Descargar playlist';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: AccessibleIconButton(
            tooltip: label,
            onPressed:
                enabled &&
                    !pending &&
                    playlist.songs.isNotEmpty &&
                    d.state != 'checking'
                ? onAction
                : null,
            icon: Icon(
              d.active
                  ? Icons.close
                  : d.ready
                  ? Icons.download_done
                  : Icons.download_outlined,
            ),
          ),
        ),
        if (d.state != 'not_downloaded')
          Text(d.label, style: Theme.of(context).textTheme.bodySmall),
        if (d.active) ...[
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: d.state == 'downloading' && d.total > 0
                ? (d.completed / d.total).clamp(0.0, 1.0)
                : null,
          ),
        ],
        if (d.message.isNotEmpty)
          Text(d.message, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
