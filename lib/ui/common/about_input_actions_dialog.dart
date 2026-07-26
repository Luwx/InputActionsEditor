import 'dart:async' show unawaited;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

const _projectUrl = 'https://github.com/luwx/InputActionsEditor';
const _inputActionsUrl = 'https://github.com/taj-ny/InputActions';
const _inputActionsWikiUrl = 'https://wiki.inputactions.org/main/index.html';
const _githubMarkSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8
  8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04
  -3.338.724-4.042-1.61-4.042-1.61C6.096 18.326 5.262 18 5.262
  18c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236
  1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776
  .417-1.305.762-1.605-2.665-.3-5.466-1.332-5.466-5.93
  0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176
  0 0 1.005-.322 3.3 1.23a11.5 11.5 0 0 1 3.003-.404
  c1.02.005 2.045.138 3.003.404 2.28-1.552 3.285-1.23
  3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23
  1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36
  .81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286
  0 .315.21.69.825.57C20.565 22.092 24 17.592 24
  12.297c0-6.627-5.373-12-12-12"/>
</svg>
''';

Future<void> showAboutInputActionsDialog(BuildContext context) {
  return showFDialog<void>(
    context: context,
    builder: (dialogContext, style, animation) => AppDialog(
      style: style,
      animation: animation,
      constraints: const BoxConstraints(minWidth: 380, maxWidth: 500),
      body: const _AboutBody(),
      actions: [
        FButton(
          onPress: () => Navigator.of(dialogContext).pop(),
          child: Text(context.l10n.actionClose),
        ),
      ],
    ),
  );
}

class _AboutBody extends StatelessWidget {
  const _AboutBody();

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'linux/icons/256x256/apps/dev.luwx.input_actions_editor.png',
            width: 96,
            height: 96,
          ),
          const SizedBox(height: 18),
          Text(
            'Input Actions Editor',
            style: typography.body.lg.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Version 0.5.3',
            style: typography.body.sm.copyWith(color: colors.mutedForeground),
          ),
          const SizedBox(height: 16),
          Text(
            'A focused desktop editor for configuring gestures, shortcuts, '
            'and input bindings.',
            style: typography.body.sm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const SizedBox(
            width: 420,
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: _AboutLink(
                    label: 'Editor',
                    url: _projectUrl,
                    github: true,
                  ),
                ),
                Expanded(
                  child: _AboutLink(
                    label: 'Input Actions',
                    url: _inputActionsUrl,
                    github: true,
                  ),
                ),
                Expanded(
                  child: _AboutLink(
                    label: 'Wiki',
                    url: _inputActionsWikiUrl,
                    icon: FLucideIcons.bookOpen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutLink extends StatelessWidget {
  const _AboutLink({
    required this.label,
    required this.url,
    this.icon,
    this.github = false,
  });

  final String label;
  final String url;
  final IconData? icon;
  final bool github;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FButton(
        variant: .outline,
        size: .sm,
        onPress: () => unawaited(_openExternalUrl(context, url)),
        prefix: github
            ? SvgPicture.string(
                _githubMarkSvg,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  context.theme.colors.foreground,
                  BlendMode.srcIn,
                ),
              )
            : Icon(icon, size: 16),
        child: Text(label),
      ),
    );
  }
}

Future<void> _openExternalUrl(BuildContext context, String url) async {
  try {
    await Process.start(
      'xdg-open',
      [url],
      mode: ProcessStartMode.detached,
    );
  } on ProcessException {
    if (!context.mounted) return;
    showFToast(
      context: context,
      variant: .destructive,
      icon: const Icon(FLucideIcons.triangleAlert),
      title: const Text('Could not open the link'),
      description: SelectableText(url),
    );
  }
}
