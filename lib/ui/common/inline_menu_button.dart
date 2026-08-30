import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';

class InlineMenuItem<T> {
  const InlineMenuItem({required this.label, required this.value, this.icon});

  final String label;
  final T value;
  final IconData? icon;
}

/// Text that reads as text until hovered, and opens a menu when clicked.
class InlineMenuButton<T> extends HookWidget {
  const InlineMenuButton({
    required this.items,
    required this.value,
    required this.onChanged,
    required this.child,
    this.isOpen,
    this.maxHeight = 260,
    super.key,
  });

  final List<InlineMenuItem<T>> items;
  final T value;
  final ValueChanged<T> onChanged;

  /// The trigger's own content, styled by the caller so it matches whatever
  /// it sits in.
  final Widget child;

  /// Lifted open state, for a host that has to stay up while the menu is.
  final ValueNotifier<bool>? isOpen;

  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final isHovered = useState(false);
    final localOpen = useState(false);
    final open = isOpen ?? localOpen;

    return FPopoverMenu(
      control: FPopoverControl.lifted(
        shown: open.value,
        onChange: (shown) => open.value = shown,
      ),
      autofocus: true,
      menuAnchor: Alignment.bottomLeft,
      childAnchor: Alignment.topLeft,
      maxHeight: maxHeight,
      menuBuilder: (context, controller, _) => [
        FItemGroup(
          children: [
            for (final item in items)
              FItem(
                prefix: item.icon == null ? null : Icon(item.icon),
                title: Text(item.label),
                suffix: item.value == value
                    ? const Icon(FLucideIcons.check)
                    : null,
                onPress: () async {
                  await controller.hide();
                  onChanged(item.value);
                },
              ),
          ],
        ),
      ],
      builder: (context, controller, _) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => isHovered.value = true,
        onExit: (_) => isHovered.value = false,
        child: GestureDetector(
          onTap: controller.toggle,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isHovered.value
                  ? colors.secondary.withValues(alpha: 0.78)
                  : null,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                child,
                const SizedBox(width: 2),
                Icon(
                  FLucideIcons.chevronDown,
                  size: 11,
                  color: colors.mutedForeground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
