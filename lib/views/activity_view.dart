import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/engine_controller.dart';
import 'widgets/section_card.dart';

class ActivityView extends StatelessWidget {
  const ActivityView({super.key, required this.controller});
  final EngineController controller;
  @override
  Widget build(BuildContext context) => SectionCard(
    title: 'Registro de actividad',
    subtitle:
        'Últimos 300 eventos de esta sesión. Los logs del motor también se guardan en Windows.',
    trailing: Wrap(
      children: [
        IconButton(
          tooltip: 'Copiar registro',
          onPressed: () => Clipboard.setData(
            ClipboardData(
              text: controller.activity
                  .map((e) => '${e.time.toIso8601String()} ${e.message}')
                  .join('\n'),
            ),
          ),
          icon: const Icon(Icons.copy),
        ),
        IconButton(
          tooltip: 'Limpiar vista',
          onPressed: controller.clearActivity,
          icon: const Icon(Icons.clear_all),
        ),
      ],
    ),
    child: controller.activity.isEmpty
        ? const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Todavía no hay eventos.'),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controller.activity.reversed
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.time.hour.toString().padLeft(2, '0')}:${entry.time.minute.toString().padLeft(2, '0')}:${entry.time.second.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Color(0xff57d5be),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: SelectableText(
                            entry.message,
                            style: const TextStyle(
                              fontFamily: 'Consolas',
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
  );
}
