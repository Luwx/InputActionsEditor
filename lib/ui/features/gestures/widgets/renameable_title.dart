import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/state/app_router.dart';

class RenameableTitle extends ConsumerStatefulWidget {
  const RenameableTitle({
    required this.name,
    required this.titleStyle,
    required this.onRename,
    super.key,
  });

  final String name;
  final TextStyle? titleStyle;
  final void Function(String)? onRename;

  @override
  ConsumerState<RenameableTitle> createState() => _RenameableTitleState();
}

class _RenameableTitleState extends ConsumerState<RenameableTitle> {
  bool _isRenaming = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isRenaming) {
      setState(() => _isRenaming = false);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startRename() {
    _controller.text = widget.name;
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.name.length,
    );
    setState(() => _isRenaming = true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  void _doConfirm() {
    widget.onRename!(_controller.text.trim());
    setState(() => _isRenaming = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedGestureProvider, (prev, next) {
      if (prev != next && _isRenaming) setState(() => _isRenaming = false);
    });

    if (_isRenaming) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FTextField(
                control: FTextFieldControl.managed(controller: _controller),
                focusNode: _focusNode,
                hint: 'Name',
                onSubmit: (_) => _doConfirm(),
              ),
            ),
            const SizedBox(width: 8),
            FButton.icon(
              onPress: _doConfirm,
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
            onTap: _startRename,
            child: MouseRegion(
              cursor: SystemMouseCursors.text,
              child: Text(
                widget.name,
                style: widget.titleStyle,
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
          onPress: _startRename,
          child: const Icon(FLucideIcons.pencil),
        ),
      ],
    );
  }
}
