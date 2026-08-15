import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/config_issues.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

const _warningLight = Color(0xFFB45309);
const _warningDark = Color(0xFFF5A742);

Future<void> showConfigIssuesDialog(
  BuildContext context,
  List<ConfigIssue> issues,
) {
  final l10n = context.l10n;
  return showFDialog<void>(
    context: context,
    builder: (ctx, style, animation) => AppDialog(
      style: style,
      animation: animation,
      constraints: const BoxConstraints(minWidth: 360, maxWidth: 560),
      title: Text(l10n.configIssuesTitle(issues.length)),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.configIssuesDialogBody,
              style: ctx.theme.typography.body.sm.copyWith(
                color: ctx.theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final issue in issues) _IssueRow(issue: issue),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        FButton(
          onPress: () => Navigator.of(ctx).pop(),
          child: Text(l10n.actionClose),
        ),
      ],
    ),
  );
}

class _IssueRow extends StatelessWidget {
  const _IssueRow({required this.issue});

  final ConfigIssue issue;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final warning = Theme.of(context).brightness == Brightness.dark
        ? _warningDark
        : _warningLight;

    final source = switch (issue.source) {
      ConfigIssueSource.conditions => l10n.configIssuesSourceConditions,
      ConfigIssueSource.endConditions => l10n.configIssuesSourceEndConditions,
      ConfigIssueSource.actionConditions =>
        l10n.configIssuesSourceActionConditions,
      ConfigIssueSource.deviceRule => l10n.configIssuesSourceDeviceRule,
    };
    final device = issue.device;
    final where = device == null
        ? '${l10n.configIssuesDeviceRule} · $source'
        : '${device.name} · '
              '${issue.gestureName ?? l10n.configIssuesUnnamedGesture}'
              ' · $source';

    final metaStyle = typography.body.xs.copyWith(
      color: colors.mutedForeground,
    );
    final mono = typography.body.sm.copyWith(fontFamily: 'monospace');
    final line = issue.line;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(where, style: metaStyle, overflow: .ellipsis),
              ),
              if (line != null) ...[
                const SizedBox(width: 8),
                Text(l10n.configIssuesLine(line), style: metaStyle),
              ],
            ],
          ),
          const SizedBox(height: 4),
          if (issue.context.isEmpty)
            SelectableText(issue.raw, style: mono.copyWith(color: warning))
          else
            _Block(issue: issue, style: mono, warning: warning),
        ],
      ),
    );
  }
}

/// The enclosing gesture, action, or rule as it appears in the file, with the
/// offending line in [warning].
class _Block extends StatelessWidget {
  const _Block({
    required this.issue,
    required this.style,
    required this.warning,
  });

  final ConfigIssue issue;
  final TextStyle style;
  final Color warning;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final start = issue.contextStart ?? 1;
    final gutterWidth = '${start + issue.context.length}'.length;
    final muted = style.copyWith(color: colors.mutedForeground);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.muted,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText.rich(
          TextSpan(
            children: [
              for (final (index, text) in issue.context.indexed) ...[
                TextSpan(
                  text: '${'${start + index}'.padLeft(gutterWidth)}  ',
                  style: muted.copyWith(color: colors.border),
                ),
                TextSpan(
                  text: text,
                  style: start + index == issue.line
                      ? style.copyWith(color: warning)
                      : muted,
                ),
                if (index < issue.context.length - 1)
                  const TextSpan(text: '\n'),
              ],
            ],
          ),
          style: style,
        ),
      ),
    );
  }
}
