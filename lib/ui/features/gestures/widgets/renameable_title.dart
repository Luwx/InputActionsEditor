import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/app_state/app_router.dart';

class RenameableTitle extends HookConsumerWidget {
  const RenameableTitle({
    required this.name,
    required this.titleStyle,
    required this.onRename,
    this.editingName,
    super.key,
  });

  final String name;

  /// Seeds the field when the displayed [name] is a placeholder rather than the
  /// stored value.
  final String? editingName;
  final TextStyle? titleStyle;
  final void Function(String)? onRename;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRenaming = useState(false);
    final controller = useTextEditingController();
    final focusNode = useFocusNode();

    useEffect(() {
      void onFocusChange() {
        if (!focusNode.hasFocus && isRenaming.value) {
          isRenaming.value = false;
        }
      }

      focusNode.addListener(onFocusChange);
      return () => focusNode.removeListener(onFocusChange);
    }, const []);

    ref.listen(selectedGestureProvider, (prev, next) {
      if (prev != next && isRenaming.value) isRenaming.value = false;
    });

    void startRename() {
      final initial = editingName ?? name;
      controller
        ..text = initial
        ..selection = TextSelection(
          baseOffset: 0,
          extentOffset: initial.length,
        );
      isRenaming.value = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => focusNode.requestFocus(),
      );
    }

    void doConfirm() {
      onRename!(controller.text.trim());
      isRenaming.value = false;
    }

    if (isRenaming.value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FTextField(
                control: FTextFieldControl.managed(controller: controller),
                focusNode: focusNode,
                hint: 'Name',
                onSubmit: (_) => doConfirm(),
              ),
            ),
            const SizedBox(width: 8),
            FButton.icon(
              onPress: doConfirm,
              size: .sm,
              child: const Icon(FLucideIcons.check),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: GestureDetector(
            onTap: startRename,
            child: MouseRegion(
              cursor: SystemMouseCursors.text,
              child: Text(
                name,
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FButton.icon(
          variant: .ghost,
          size: .xs,
          onPress: startRename,
          child: const Icon(FLucideIcons.pencil),
        ),
      ],
    );
  }
}
