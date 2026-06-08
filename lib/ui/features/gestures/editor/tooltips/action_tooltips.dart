part of 'tooltip_widgets.dart';

class ActionConditionsTooltip extends StatelessWidget {
  const ActionConditionsTooltip({super.key});

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
          Text(l10n.tooltip_actionConditions_body),
          _SectionLabel(
            l10n.tooltip_actionConditions_sectionLabel,
            FLucideIcons.gitFork,
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
                l10n.tooltip_actionConditions_ex1Label,
                colors,
                t,
              ),
              _ExRow(
                r'$window_class == code',
                l10n.tooltip_actionConditions_ex2Label,
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

class ActionActivateWindowTooltip extends StatelessWidget {
  const ActionActivateWindowTooltip({super.key});

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
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: l10n.tooltip_actionActivateWindow_bodyPrefix),
                _monoSpan(r'$variable_name', colors, t),
                TextSpan(text: l10n.tooltip_actionActivateWindow_bodySuffix),
              ],
            ),
          ),
          _SectionLabel(
            l10n.tooltip_actionActivateWindow_sectionLabel,
            FLucideIcons.variable,
            colors,
            t,
          ),
          _ExRow(
            r'$initial_window_under_pointer_id',
            l10n.tooltip_actionActivateWindow_variableExLabel,
            colors,
            t,
          ),
          _Note(l10n.tooltip_actionActivateWindow_unknownNote, colors, t),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  FLucideIcons.triangleAlert,
                  size: 11,
                  color: colors.destructive.withValues(alpha: 0.85),
                ),
              ),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: l10n
                            .tooltip_actionActivateWindow_noInterpolationPrefix,
                      ),
                      _errorMonoSpan(r'$name text', colors, t),
                      TextSpan(
                        text: l10n
                            .tooltip_actionActivateWindow_noInterpolationSuffix,
                      ),
                    ],
                  ),
                  style: t.xs.copyWith(color: colors.mutedForeground),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionTriggerOnTooltip extends StatelessWidget {
  const ActionTriggerOnTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final t = context.theme.typography;
    final mono = t.xs.copyWith(fontFamily: 'monospace');
    final muted = t.xs.copyWith(color: colors.mutedForeground);
    final codeBg = colors.muted.withValues(alpha: 0.5);
    return TooltipShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Text(l10n.tooltip_actionTriggerOn_body),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: codeBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                _LifecycleRow(
                  'begin',
                  l10n.tooltip_actionTriggerOn_lifecycleBegin,
                  mono,
                  muted,
                ),
                _LifecycleRow(
                  'update',
                  l10n.tooltip_actionTriggerOn_lifecycleUpdate,
                  mono,
                  muted,
                ),
                _LifecycleRow(
                  'end',
                  l10n.tooltip_actionTriggerOn_lifecycleEnd,
                  mono,
                  muted,
                  isDefault: true,
                  colors: colors,
                  t: t,
                ),
                _LifecycleRow(
                  'cancel',
                  l10n.tooltip_actionTriggerOn_lifecycleCancel,
                  mono,
                  muted,
                ),
                _LifecycleRow(
                  'end_cancel',
                  l10n.tooltip_actionTriggerOn_lifecycleEndCancel,
                  mono,
                  muted,
                ),
                _LifecycleRow(
                  'tick',
                  l10n.tooltip_actionTriggerOn_lifecycleTick,
                  mono,
                  muted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActionIntervalTooltip extends StatelessWidget {
  const ActionIntervalTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final t = context.theme.typography;
    final mono = t.xs.copyWith(fontFamily: 'monospace');
    final muted = t.xs.copyWith(color: colors.mutedForeground);
    final codeBg = colors.muted.withValues(alpha: 0.5);
    return TooltipShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Text(l10n.tooltip_actionInterval_body),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: codeBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                _UnitRow(
                  l10n.tooltip_actionInterval_unitEmptyKey,
                  l10n.tooltip_actionInterval_unitEmptyDesc,
                  mono,
                  muted,
                ),
                _UnitRow(
                  '+',
                  l10n.tooltip_actionInterval_unitPlusDesc,
                  mono,
                  muted,
                ),
                _UnitRow(
                  '-',
                  l10n.tooltip_actionInterval_unitMinusDesc,
                  mono,
                  muted,
                ),
                _UnitRow(
                  '4',
                  l10n.tooltip_actionInterval_unitNDesc,
                  mono,
                  muted,
                ),
              ],
            ),
          ),
          _ExRow(
            'interval: 4  +  on: update  +  wheel',
            l10n.tooltip_actionInterval_exLabel,
            colors,
            t,
          ),
        ],
      ),
    );
  }
}

class ActionThresholdTooltip extends StatelessWidget {
  const ActionThresholdTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final t = context.theme.typography;
    final mono = t.xs.copyWith(fontFamily: 'monospace');
    final muted = t.xs.copyWith(color: colors.mutedForeground);
    final codeBg = colors.muted.withValues(alpha: 0.5);
    return TooltipShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Text(l10n.tooltip_actionThreshold_body),
          _SectionLabel(
            l10n.tooltip_actionThreshold_sectionLabel,
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
                  l10n.tooltip_actionThreshold_unitPinchScale,
                  mono,
                  muted,
                ),
                _UnitRow(
                  l10n.tooltip_thresholdUnit_rotateCircle,
                  l10n.tooltip_thresholdUnit_degrees,
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
              _Note(
                l10n.tooltip_actionThreshold_noteTrigger,
                colors,
                t,
              ),
              _Note(
                l10n.tooltip_actionThreshold_noteRange,
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

class ActionConflictingTooltip extends StatelessWidget {
  const ActionConflictingTooltip({super.key});

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
          Text(l10n.tooltip_actionConflicting_body),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              _OutcomeRow(
                icon: FLucideIcons.check,
                label: l10n.tooltip_actionConflicting_onLabel,
                description: l10n.tooltip_actionConflicting_onDesc,
                iconColor: colors.primary,
                colors: colors,
                t: t,
              ),
              _OutcomeRow(
                icon: FLucideIcons.zap,
                label: l10n.tooltip_actionConflicting_offLabel,
                description: l10n.tooltip_actionConflicting_offDesc,
                iconColor: colors.mutedForeground,
                colors: colors,
                t: t,
              ),
            ],
          ),
          _SectionLabel(
            l10n.tooltip_actionConflicting_sectionLabel,
            FLucideIcons.lightbulb,
            colors,
            t,
          ),
          _ExRow(
            l10n.tooltip_actionConflicting_exCode,
            l10n.tooltip_actionConflicting_exLabel,
            colors,
            t,
          ),
        ],
      ),
    );
  }
}

class ActionLimitTooltip extends StatelessWidget {
  const ActionLimitTooltip({super.key});

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
          Text(l10n.tooltip_actionLimit_body),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              _IconBullet(
                FLucideIcons.infinity,
                l10n.tooltip_actionLimit_bulletUnlimited,
                colors.mutedForeground,
                colors,
                t,
              ),
              _IconBullet(
                FLucideIcons.hash,
                l10n.tooltip_actionLimit_bulletN,
                colors.mutedForeground,
                colors,
                t,
              ),
            ],
          ),
          _ExRow(
            'limit: 1  +  on: update',
            l10n.tooltip_actionLimit_exLabel,
            colors,
            t,
          ),
        ],
      ),
    );
  }
}
