part of 'tooltip_widgets.dart';

class KeySequenceTooltip extends StatelessWidget {
  const KeySequenceTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final t = context.theme.typography;
    final mono = t.xs.copyWith(fontFamily: 'monospace');
    return TooltipShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 14,
        children: [
          Text(l10n.tooltip_keySequence_body),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              _SectionLabel(
                l10n.tooltip_keySequence_chordSectionLabel,
                FLucideIcons.keyboard,
                colors,
                t,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.muted.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(4),
                ),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    _KeyChordRow(
                      keys: const ['ctrl', '+', 'c'],
                      colors: colors,
                      t: t,
                    ),
                    _KeyChordRow(
                      keys: const ['shift', '+', 'alt', '+', 'f4'],
                      colors: colors,
                      t: t,
                    ),
                  ],
                ),
              ),
              Text(
                l10n.tooltip_keySequence_chordDesc,
                style: t.xs.copyWith(color: colors.mutedForeground),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              _SectionLabel(
                l10n.tooltip_keySequence_tokenSectionLabel,
                FLucideIcons.gitCommitHorizontal,
                colors,
                t,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.muted.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          _tokenSpan('+ctrl', colors, t, press: true),
                          TextSpan(text: ',  ', style: mono),
                          _tokenSpan('+c', colors, t, press: true),
                          TextSpan(text: ',  ', style: mono),
                          _tokenSpan('-c', colors, t, press: false),
                          TextSpan(text: ',  ', style: mono),
                          _tokenSpan('-ctrl', colors, t, press: false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      _pressChip('+', colors, t),
                      Text(l10n.tooltip_keySequence_pressLabel, style: t.xs),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      _releaseChip('-', colors, t),
                      Text(l10n.tooltip_keySequence_releaseLabel, style: t.xs),
                    ],
                  ),
                ],
              ),
              Text(
                l10n.tooltip_keySequence_tokenDesc,
                style: t.xs.copyWith(color: colors.mutedForeground),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ButtonSequenceTooltip extends StatelessWidget {
  const ButtonSequenceTooltip({super.key});

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
          Text(l10n.tooltip_buttonSequence_body),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: colors.muted.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      _tokenSpan('+left', colors, t, press: true),
                      TextSpan(
                        text: ',  ',
                        style: t.xs.copyWith(fontFamily: 'monospace'),
                      ),
                      _tokenSpan('-left', colors, t, press: false),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      _tokenSpan('+right', colors, t, press: true),
                      TextSpan(
                        text: ',  ',
                        style: t.xs.copyWith(fontFamily: 'monospace'),
                      ),
                      _tokenSpan('+left', colors, t, press: true),
                      TextSpan(
                        text: ',  ',
                        style: t.xs.copyWith(fontFamily: 'monospace'),
                      ),
                      _tokenSpan('-left', colors, t, press: false),
                      TextSpan(
                        text: ',  ',
                        style: t.xs.copyWith(fontFamily: 'monospace'),
                      ),
                      _tokenSpan('-right', colors, t, press: false),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4,
                      children: [
                        _pressChip('+', colors, t),
                        Text(
                          l10n.tooltip_buttonSequence_pressLabel,
                          style: t.xs,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4,
                      children: [
                        _releaseChip('-', colors, t),
                        Text(
                          l10n.tooltip_buttonSequence_releaseLabel,
                          style: t.xs,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          _Note(l10n.tooltip_buttonSequence_noteButtons, colors, t),
        ],
      ),
    );
  }
}
