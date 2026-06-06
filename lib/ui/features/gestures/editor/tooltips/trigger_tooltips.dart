part of 'tooltip_widgets.dart';

class TriggerConditionsTooltip extends StatelessWidget {
  const TriggerConditionsTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final t = context.theme.typography;
    return TooltipShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Text(l10n.tooltip_triggerConditions_body),
          _SectionLabel(
            l10n.tooltip_triggerConditions_sectionLabel,
            FLucideIcons.code2,
            colors,
            t,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              _ExRow(
                r'$window_class == firefox',
                l10n.tooltip_triggerConditions_ex1Label,
                colors,
                t,
              ),
              _ExRow(
                r'$window_class == konsole',
                l10n.tooltip_triggerConditions_ex2Label,
                colors,
                t,
              ),
              _ExRow(
                r'$window_id == $window_under_id',
                l10n.tooltip_triggerConditions_ex3Label,
                colors,
                t,
              ),
              _ExRow(
                r'$pointer_position_screen_percentage_x >= 0.95',
                l10n.tooltip_triggerConditions_ex4Label,
                colors,
                t,
              ),
              _ExRow(
                r'$fingers == 3',
                l10n.tooltip_triggerConditions_ex5Label,
                colors,
                t,
              ),
            ],
          ),
          _Note(l10n.tooltip_triggerConditions_noteAnd, colors, t),
        ],
      ),
    );
  }
}

class TriggerEndConditionsTooltip extends StatelessWidget {
  const TriggerEndConditionsTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final t = context.theme.typography;
    return TooltipShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Text(l10n.tooltip_triggerEndConditions_body),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              _OutcomeRow(
                icon: FLucideIcons.check,
                label: l10n.tooltip_triggerEndConditions_metLabel,
                description: l10n.tooltip_triggerEndConditions_metDesc,
                iconColor: colors.primary,
                colors: colors,
                t: t,
              ),
              _OutcomeRow(
                icon: FLucideIcons.x,
                label: l10n.tooltip_triggerEndConditions_notMetLabel,
                description: l10n.tooltip_triggerEndConditions_notMetDesc,
                iconColor: colors.destructive,
                colors: colors,
                t: t,
              ),
            ],
          ),
          _SectionLabel(
            l10n.tooltip_triggerEndConditions_sectionLabel,
            FLucideIcons.lightbulb,
            colors,
            t,
          ),
          _ExRow(
            r'$distance >= 100',
            l10n.tooltip_triggerEndConditions_exLabel,
            colors,
            t,
          ),
        ],
      ),
    );
  }
}

class TriggerIdTooltip extends StatelessWidget {
  const TriggerIdTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final t = context.theme.typography;
    return TooltipShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Text(l10n.tooltip_triggerId_body),
          _SectionLabel(
            l10n.tooltip_triggerId_sectionLabel,
            FLucideIcons.variable,
            colors,
            t,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              _ExRow(
                r'$<id>_active',
                l10n.tooltip_triggerId_ex1Label,
                colors,
                t,
              ),
              _ExRow(
                r'$last_trigger',
                l10n.tooltip_triggerId_ex2Label,
                colors,
                t,
              ),
            ],
          ),
          _Note(
            l10n.tooltip_triggerId_noteChain,
            colors,
            t,
          ),
        ],
      ),
    );
  }
}

class TriggerThresholdTooltip extends StatelessWidget {
  const TriggerThresholdTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final t = context.theme.typography;
    final codeBg = colors.muted.withValues(alpha: 0.5);
    final mono = t.xs.copyWith(fontFamily: 'monospace');
    final muted = t.xs.copyWith(color: colors.mutedForeground);
    return TooltipShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Text(l10n.tooltip_triggerThreshold_body),
          _SectionLabel(
            l10n.tooltip_triggerThreshold_sectionLabel,
            FLucideIcons.ruler,
            colors,
            t,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: codeBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 3,
              children: [
                _UnitRow(
                  l10n.tooltip_thresholdUnit_swipeStroke,
                  l10n.tooltip_thresholdUnit_pixels,
                  mono,
                  muted,
                ),
                _UnitRow(
                  l10n.tooltip_thresholdUnit_wheel,
                  l10n.tooltip_thresholdUnit_scrollTicks,
                  mono,
                  muted,
                ),
                _UnitRow(
                  l10n.tooltip_thresholdUnit_pinch,
                  l10n.tooltip_triggerThreshold_unitPinchScale,
                  mono,
                  muted,
                ),
                _UnitRow(
                  l10n.tooltip_thresholdUnit_rotateCircle,
                  l10n.tooltip_thresholdUnit_degrees,
                  mono,
                  muted,
                ),
                _UnitRow(
                  l10n.tooltip_triggerThreshold_unitPressKey,
                  l10n.tooltip_triggerThreshold_unitPressDesc,
                  mono,
                  muted,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              _Note(l10n.tooltip_triggerThreshold_notePassthrough, colors, t),
              _Note(
                l10n.tooltip_triggerThreshold_noteRange,
                colors,
                t,
                icon: FLucideIcons.arrowRightLeft,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TriggerResumeTimeoutTooltip extends StatelessWidget {
  const TriggerResumeTimeoutTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final t = context.theme.typography;
    return TooltipShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Text(l10n.tooltip_triggerResumeTimeout_body),
          _SectionLabel(
            l10n.tooltip_triggerResumeTimeout_sectionLabel,
            FLucideIcons.lightbulb,
            colors,
            t,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              _Bullet(
                l10n.tooltip_triggerResumeTimeout_bulletMultiTap,
                colors,
                t,
              ),
              _Bullet(l10n.tooltip_triggerResumeTimeout_bulletWheel, colors, t),
            ],
          ),
          _Note(l10n.tooltip_triggerResumeTimeout_noteDisabled, colors, t),
        ],
      ),
    );
  }
}

class TriggerAcceleratedTooltip extends StatelessWidget {
  const TriggerAcceleratedTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final t = context.theme.typography;
    return TooltipShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Text(l10n.tooltip_triggerAccelerated_body),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              _IconBullet(
                FLucideIcons.check,
                l10n.tooltip_triggerAccelerated_bulletOn,
                colors.primary,
                colors,
                t,
              ),
              _IconBullet(
                FLucideIcons.minus,
                l10n.tooltip_triggerAccelerated_bulletOff,
                colors.mutedForeground,
                colors,
                t,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TriggerBlockEventsTooltip extends StatelessWidget {
  const TriggerBlockEventsTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final t = context.theme.typography;
    return TooltipShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Text(l10n.tooltip_triggerBlockEvents_body),
          _SectionLabel(
            l10n.tooltip_triggerBlockEvents_sectionLabel,
            FLucideIcons.lightbulb,
            colors,
            t,
          ),
          _ExRow(
            l10n.tooltip_triggerBlockEvents_exCode,
            l10n.tooltip_triggerBlockEvents_exLabel,
            colors,
            t,
          ),
          _Note(l10n.tooltip_triggerBlockEvents_noteDisable, colors, t),
        ],
      ),
    );
  }
}

class TriggerClearModifiersTooltip extends StatelessWidget {
  const TriggerClearModifiersTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final t = context.theme.typography;
    return TooltipShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${l10n.tooltip_triggerClearModifiers_prefix} '),
                _chipSpan('Ctrl', colors, t),
                const TextSpan(text: '  '),
                _chipSpan('Shift', colors, t),
                const TextSpan(text: '  '),
                _chipSpan('Alt', colors, t),
                const TextSpan(text: '  '),
                _chipSpan('Super', colors, t),
                TextSpan(text: ' ${l10n.tooltip_triggerClearModifiers_suffix}'),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              _Note(
                l10n.tooltip_triggerClearModifiers_noteAuto,
                colors,
                t,
                icon: FLucideIcons.zap,
              ),
              _Note(l10n.tooltip_triggerClearModifiers_noteDisable, colors, t),
            ],
          ),
        ],
      ),
    );
  }
}

class TriggerSetLastTriggerTooltip extends StatelessWidget {
  const TriggerSetLastTriggerTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final t = context.theme.typography;
    return TooltipShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${l10n.tooltip_triggerSetLastTrigger_prefix} '),
                _monoSpan(r'$last_trigger', colors, t),
                TextSpan(text: ' ${l10n.tooltip_triggerSetLastTrigger_suffix}'),
              ],
            ),
          ),
          _Note(
            l10n.tooltip_triggerSetLastTrigger_noteChain,
            colors,
            t,
            icon: FLucideIcons.link2,
          ),
          _Note(l10n.tooltip_triggerSetLastTrigger_noteDisable, colors, t),
        ],
      ),
    );
  }
}
