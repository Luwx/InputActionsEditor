import 'dart:async';

import 'package:dbus/dbus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/conditions/gesture_exceptions.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/edits/group_edits.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Lists the apps mouse gestures are turned off in. Each change is saved right
/// away, unless other gesture edits are waiting to be saved.
class ExceptionsScreen extends ConsumerStatefulWidget {
  const ExceptionsScreen({super.key});

  @override
  ConsumerState<ExceptionsScreen> createState() => _ExceptionsScreenState();
}

class _ExceptionsScreenState extends ConsumerState<ExceptionsScreen> {
  static const _pickSeconds = 5;
  static const _editorClass = 'dev.luwx.input_actions_editor';

  final _appController = TextEditingController();
  Timer? _pickTimer;
  int _pickRemaining = 0;
  _Notice? _notice;

  @override
  void dispose() {
    _pickTimer?.cancel();
    _appController.dispose();
    super.dispose();
  }

  Future<void> _change(
    GestureExceptionsTarget target,
    Condition? Function(Condition?) update,
  ) async {
    final controller = ref.read(configControllerProvider.notifier);
    final otherEdits = ref.read(configSessionProvider).gesturesDirty.isDirty;
    controller.add(
      UpdateGestureGroup(
        target.location,
        (group) => group.copyWith(conditions: update(group.conditions)),
      ),
      scope: const GesturesScope(),
    );
    if (otherEdits) {
      setState(() => _notice = _Notice.unsaved);
      return;
    }
    final saved = await controller.saveGestures();
    if (mounted) {
      setState(() => _notice = saved ? null : _Notice.saveFailed);
    }
  }

  Future<void> _add(GestureExceptionsTarget target) async {
    final app = _appController.text.trim();
    if (app.isEmpty) return;
    _appController.clear();
    await _change(target, (conditions) => withExceptionApp(conditions, app));
  }

  void _startPick() {
    _pickTimer?.cancel();
    setState(() {
      _pickRemaining = _pickSeconds;
      _notice = null;
    });
    _pickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_pickRemaining > 1) {
        setState(() => _pickRemaining--);
        return;
      }
      timer.cancel();
      setState(() => _pickRemaining = 0);
      unawaited(_finishPick());
    });
  }

  Future<void> _finishPick() async {
    final app = await _appUnderPointer();
    if (!mounted) return;
    setState(() {
      if (app == null || app.isEmpty) {
        _notice = _Notice.pickFailed;
      } else if (app == _editorClass) {
        _notice = _Notice.pickedEditor;
      } else {
        _appController.text = app;
      }
    });
  }

  /// Asks the InputActions plugin which app class is under the pointer.
  Future<String?> _appUnderPointer() async {
    final client = DBusClient.session();
    try {
      final reply =
          await DBusRemoteObject(
            client,
            name: 'org.inputactions',
            path: DBusObjectPath('/'),
          ).callMethod(
            'org.inputactions',
            'variables',
            [const DBusString(exceptionVariable)],
            replySignature: DBusSignature('s'),
          );
      final text = reply.returnValues.first.asString();
      final separator = text.indexOf(': ');
      return separator == -1 ? null : text.substring(separator + 2).trim();
    } on Object {
      return null;
    } finally {
      await client.close();
    }
  }

  String? _noticeText(AppLocalizations l10n) => switch (_notice) {
    null => null,
    _Notice.unsaved => l10n.exceptionsNoticeUnsaved,
    _Notice.saveFailed => l10n.exceptionsNoticeSaveFailed,
    _Notice.pickFailed => l10n.exceptionsNoticePickFailed,
    _Notice.pickedEditor => l10n.exceptionsNoticePickedEditor,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final target = gestureExceptionsTarget(ref.watch(draftConfigProvider));
    final muted = typography.body.sm.copyWith(color: colors.mutedForeground);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          l10n.exceptionsTitle,
          style: typography.body.lg.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(l10n.exceptionsDescription, style: muted),
        const SizedBox(height: 20),
        if (target == null)
          Text(l10n.exceptionsNoGroup, style: muted)
        else ...[
          Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FTextField(
                  control: FTextFieldControl.managed(
                    controller: _appController,
                  ),
                  hint: l10n.exceptionsFieldHint,
                  onSubmit: (_) => unawaited(_add(target)),
                ),
              ),
              FButton(
                variant: .outline,
                onPress: _pickRemaining > 0 ? null : _startPick,
                child: Text(
                  _pickRemaining > 0
                      ? l10n.exceptionsPickCountdown(_pickRemaining)
                      : l10n.exceptionsPick,
                ),
              ),
              FButton(
                onPress: () => unawaited(_add(target)),
                child: Text(l10n.exceptionsAdd),
              ),
            ],
          ),
          if (_noticeText(l10n) case final String notice) ...[
            const SizedBox(height: 8),
            Text(notice, style: muted),
          ],
          const SizedBox(height: 16),
          if (target.apps.isEmpty)
            Text(l10n.exceptionsEmpty, style: muted)
          else
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: colors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  for (final (index, app) in target.apps.indexed) ...[
                    if (index > 0) Container(height: 1, color: colors.border),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              app,
                              style: typography.body.sm,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          FButton.icon(
                            variant: .ghost,
                            size: .sm,
                            onPress: () => unawaited(
                              _change(
                                target,
                                (conditions) =>
                                    withoutExceptionApp(conditions, app),
                              ),
                            ),
                            child: Icon(
                              FLucideIcons.trash2,
                              color: colors.destructive,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 16),
          Text(
            l10n.exceptionsAppliesTo(
              target.group.gestures.length,
              target.group.name,
            ),
            style: muted,
          ),
          if (target.outsideCount > 0)
            Text(l10n.exceptionsOutside(target.outsideCount), style: muted),
        ],
      ],
    );
  }
}

enum _Notice { unsaved, saveFailed, pickFailed, pickedEditor }
