part of 'tooltip_widgets.dart';

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, this.icon, this.colors, this.t);

  final String label;
  final IconData icon;
  final FColors colors;
  final FTypography t;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Icon(icon, size: 10, color: colors.mutedForeground),
        Text(
          label.toUpperCase(),
          style: t.body.xs.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.mutedForeground,
            fontSize: 9.5,
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }
}

class _ExRow extends StatelessWidget {
  const _ExRow(this.code, this.annotation, this.colors, this.t);

  final String code;
  final String annotation;
  final FColors colors;
  final FTypography t;

  @override
  Widget build(BuildContext context) {
    final codeBg = colors.muted.withValues(alpha: 0.5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: codeBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(code, style: t.body.xs.copyWith(fontFamily: 'monospace')),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 2),
            child: Text(
              '↳  $annotation',
              style: t.body.xs.copyWith(color: colors.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutcomeRow extends StatelessWidget {
  const _OutcomeRow({
    required this.icon,
    required this.label,
    required this.description,
    required this.iconColor,
    required this.colors,
    required this.t,
  });

  final IconData icon;
  final String label;
  final String description;
  final Color iconColor;
  final FColors colors;
  final FTypography t;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 11, color: iconColor),
        ),
        Flexible(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label  ',
                  style: t.body.xs.copyWith(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: description,
                  style: t.body.xs.copyWith(color: colors.mutedForeground),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text, this.colors, this.t);

  final String text;
  final FColors colors;
  final FTypography t;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            '•',
            style: t.body.xs.copyWith(color: colors.mutedForeground),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: t.body.xs)),
      ],
    );
  }
}

class _IconBullet extends StatelessWidget {
  const _IconBullet(this.icon, this.text, this.iconColor, this.colors, this.t);

  final IconData icon;
  final String text;
  final Color iconColor;
  final FColors colors;
  final FTypography t;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 11, color: iconColor),
        ),
        Flexible(child: Text(text, style: t.body.xs)),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text, this.colors, this.t, {this.icon});

  final String text;
  final FColors colors;
  final FTypography t;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            icon ?? FLucideIcons.info,
            size: 11,
            color: colors.primary.withValues(alpha: 0.75),
          ),
        ),
        Flexible(
          child: Text(
            text,
            style: t.body.xs.copyWith(color: colors.mutedForeground),
          ),
        ),
      ],
    );
  }
}

class _UnitRow extends StatelessWidget {
  const _UnitRow(this.gesture, this.unit, this.mono, this.muted);

  final String gesture;
  final String unit;
  final TextStyle mono;
  final TextStyle muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 118, child: Text(gesture, style: mono)),
        Text(unit, style: muted),
      ],
    );
  }
}

class _LifecycleRow extends StatelessWidget {
  const _LifecycleRow(
    this.name,
    this.description,
    this.mono,
    this.muted, {
    this.isDefault = false,
    this.colors,
    this.t,
  });

  final String name;
  final String description;
  final TextStyle mono;
  final TextStyle muted;
  final bool isDefault;
  final FColors? colors;
  final FTypography? t;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(width: 76, child: Text(name, style: mono)),
        Text(description, style: muted),
        if (isDefault && colors != null && t != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: colors!.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              context.l10n.fieldDefaultHint,
              style: t!.body.xs.copyWith(
                fontSize: 9,
                color: colors!.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _KeyChordRow extends StatelessWidget {
  const _KeyChordRow({
    required this.keys,
    required this.colors,
    required this.t,
  });

  final List<String> keys;
  final FColors colors;
  final FTypography t;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 3,
      children: keys.map((k) {
        if (k == '+') {
          return Text(
            '+',
            style: t.body.xs.copyWith(color: colors.mutedForeground),
          );
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: colors.secondary.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: colors.border),
          ),
          child: Text(
            k,
            style: t.body.xs.copyWith(
              fontFamily: 'monospace',
              color: colors.secondaryForeground,
            ),
          ),
        );
      }).toList(),
    );
  }
}

InlineSpan _tokenSpan(
  String text,
  FColors colors,
  FTypography t, {
  required bool press,
}) {
  final bg = press
      ? colors.primary.withValues(alpha: 0.18)
      : colors.destructive.withValues(alpha: 0.18);
  final fg = press ? colors.primary : colors.destructive;
  return WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: t.body.xs.copyWith(fontFamily: 'monospace', color: fg),
      ),
    ),
  );
}

Widget _pressChip(String text, FColors colors, FTypography t) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
      color: colors.primary.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Text(
      text,
      style: t.body.xs.copyWith(fontFamily: 'monospace', color: colors.primary),
    ),
  );
}

Widget _releaseChip(String text, FColors colors, FTypography t) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
      color: colors.destructive.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Text(
      text,
      style: t.body.xs.copyWith(
        fontFamily: 'monospace',
        color: colors.destructive,
      ),
    ),
  );
}

InlineSpan _chipSpan(String text, FColors colors, FTypography t) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: colors.muted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: t.body.xs.copyWith(fontFamily: 'monospace', fontSize: 10),
      ),
    ),
  );
}

InlineSpan _monoSpan(String text, FColors colors, FTypography t) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: colors.muted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: t.body.xs.copyWith(fontFamily: 'monospace'),
      ),
    ),
  );
}

InlineSpan _errorMonoSpan(String text, FColors colors, FTypography t) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: colors.destructive.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: t.body.xs.copyWith(
          fontFamily: 'monospace',
          color: colors.destructive,
        ),
      ),
    ),
  );
}
