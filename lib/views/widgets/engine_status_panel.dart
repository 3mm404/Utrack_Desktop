import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';
import 'section_card.dart';
import 'status_indicator.dart';
import 'ui_controls.dart';

/// Presentation metrics. Never reads CPU, audio latency, or real engine status.
class EngineStatusPanel extends StatelessWidget {
  const EngineStatusPanel({
    super.key,
    this.running = true,
    this.compact = false,
    this.onToggleEngine,
    this.activeZones = 2,
    this.totalZones = 4,
    this.cpu = 8,
    this.latencyMs = 12,
  }) : assert(totalZones >= 0),
       assert(activeZones >= 0 && activeZones <= totalZones),
       assert(cpu >= 0 && cpu <= 100),
       assert(latencyMs >= 0);
  final bool running, compact;
  final VoidCallback? onToggleEngine;
  final int activeZones, totalZones;
  final double cpu, latencyMs;

  @override
  Widget build(BuildContext context) => compact
      ? SectionCard(
          title: 'Estado general',
          compact: true,
          trailing: onToggleEngine == null
              ? null
              : UiIconControl(
                  icon: running ? Icons.stop : Icons.play_arrow,
                  label: running
                      ? 'Detener motor simulado'
                      : 'Iniciar motor simulado',
                  onPressed: onToggleEngine,
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '$activeZones / $totalZones zonas activas',
                style: UiType.body,
              ),
              const SizedBox(height: UiSpace.sm),
              StatusIndicator(
                label: running
                    ? 'En ejecución · simulado'
                    : 'Detenido · simulado',
                status: running ? UiStatus.operational : UiStatus.inactive,
              ),
              const SizedBox(height: UiSpace.lg),
              _PerformanceMetric(
                label: 'CPU · simulada',
                value: '${cpu.toStringAsFixed(0)}%',
                progress: cpu / 100,
              ),
              const SizedBox(height: UiSpace.md),
              _PerformanceMetric(
                label: 'Latencia · simulada',
                value: '${latencyMs.toStringAsFixed(0)} ms',
                progress: (latencyMs / 100).clamp(0, 1),
              ),
            ],
          ),
        )
      : SectionCard(
          title: 'Estado general',
          compact: compact,
          subtitle: compact
              ? 'Datos simulados'
              : 'Métricas de ejemplo · simuladas',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Zonas activas', style: UiType.caption),
                  ),
                  Text('$activeZones / $totalZones', style: UiType.body),
                ],
              ),
              const SizedBox(height: UiSpace.lg),
              const Divider(),
              const SizedBox(height: UiSpace.sm),
              StatusIndicator(
                label: running
                    ? 'Motor en ejecución · simulado'
                    : 'Motor detenido · simulado',
                status: running ? UiStatus.operational : UiStatus.inactive,
              ),
              if (onToggleEngine != null)
                Padding(
                  padding: const EdgeInsets.only(top: UiSpace.lg),
                  child: OutlinedButton.icon(
                    onPressed: onToggleEngine,
                    icon: Icon(running ? Icons.stop : Icons.play_arrow),
                    label: Text(
                      running
                          ? 'Detener motor simulado'
                          : 'Iniciar motor simulado',
                    ),
                  ),
                ),
              const SizedBox(height: UiSpace.xl),
              _PerformanceMetric(
                label: 'Uso de CPU',
                value: '${cpu.toStringAsFixed(0)}%',
                progress: cpu / 100,
              ),
              const SizedBox(height: UiSpace.xl),
              _PerformanceMetric(
                label: 'Latencia',
                value: '${latencyMs.toStringAsFixed(0)} ms',
                progress: (latencyMs / 100).clamp(0, 1),
                description: compact ? null : 'Escala visual: 0–100 ms',
              ),
              const SizedBox(height: UiSpace.xl),
              if (!compact)
                const Text(
                  'Valores de demostración. No son mediciones del sistema.',
                  style: UiType.caption,
                ),
            ],
          ),
        );
}

class _PerformanceMetric extends StatelessWidget {
  const _PerformanceMetric({
    required this.label,
    required this.value,
    required this.progress,
    this.description,
  });
  final String label, value;
  final String? description;
  final double progress;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(child: Text(label, style: UiType.caption)),
          Text(value, style: UiType.body),
        ],
      ),
      const SizedBox(height: UiSpace.md),
      LinearProgressIndicator(
        value: progress,
        minHeight: UiSpace.xs,
        borderRadius: UiRadii.control,
        color: UiColors.accent,
        backgroundColor: UiColors.border,
        semanticsLabel: '$label: $value · simulado',
        semanticsValue: '${(progress * 100).round()}%',
      ),
      if (description != null) ...[
        const SizedBox(height: UiSpace.sm),
        Text(description!, style: UiType.caption),
      ],
    ],
  );
}
