import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/data/yaml_io.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_group.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/edit/config_edit.dart';
import 'package:input_actions_editor/state/edit/lens.dart';
import 'package:input_actions_editor/state/gesture_undo_controller.dart';

class ConfigController extends AsyncNotifier<Config> {
  String _originalText = '';
  Config? _savedConfig;
  final Map<Object?, _EditStack> _editStacks = {};

  /// True while applying an undo/redo restore, so the restore itself is not
  /// recorded as a new history step.
  bool _restoring = false;

  /// Dirty is derived: the draft differs from the last saved snapshot. This
  /// means undoing back to the saved state automatically clears the indicator.
  /// (editId is excluded from equality, so identity churn never marks dirty.)
  bool get isDirty {
    final config = state.value;
    if (config == null) return false;
    final saved = savedConfig;
    if (saved == null) return true;
    return config != saved;
  }

  Config? get savedConfig => _savedConfig;

  @override
  Future<Config> build() async {
    final (config, text) = await loadConfig();
    final normalized = assignEditIds(config);
    _originalText = text;
    _savedConfig = normalized;
    return normalized;
  }

  // ---------------------------------------------------------------------------
  // Generic helpers
  // ---------------------------------------------------------------------------

  void _modifyList<T>(
    List<T> Function(Config) getList,
    Config Function(Config, List<T>) setList,
    void Function(List<T>) action,
  ) {
    final current = state.value;
    if (current == null) return;
    final list = List<T>.of(getList(current));
    action(list);
    _applyConfig(setList(current, list));
  }

  void _applyConfig(Config config) {
    state = AsyncData(assignEditIds(config));
  }

  void dispatch(ConfigEdit edit, {Object? scope}) {
    final before = state.value;
    if (before == null) return;
    final applied = edit.apply(before);
    final inverse = edit.inverse(before);
    _applyConfig(applied);
    _editStacks.putIfAbsent(scope, _EditStack.new).push(edit, inverse);
  }

  void undoEdit({Object? scope}) {
    final before = state.value;
    if (before == null) return;
    final edit = _editStacks[scope]?.popUndo();
    if (edit == null) return;
    _applyConfig(edit.apply(before));
  }

  void redoEdit({Object? scope}) {
    final before = state.value;
    if (before == null) return;
    final edit = _editStacks[scope]?.popRedo();
    if (edit == null) return;
    _applyConfig(edit.apply(before));
  }

  void revert<T>(Lens<T> lens, {Object? scope}) {
    final saved = savedConfig;
    if (saved == null) return;
    dispatch(SetLens<T>(lens, lens.get(saved)), scope: scope);
  }

  bool canUndoEdit({Object? scope}) => _editStacks[scope]?.canUndo ?? false;

  bool canRedoEdit({Object? scope}) => _editStacks[scope]?.canRedo ?? false;

  /// Edits the gesture at [i], recording its pre-edit snapshot to the
  /// per-gesture undo history (unless we're currently restoring one).
  void _updateGesture<T extends Object>(
    List<T> Function(Config) getList,
    Config Function(Config, List<T>) setList,
    int i,
    T Function(T) m,
  ) => _modifyList(getList, setList, (l) {
    if (i < 0 || i >= l.length) return;
    final before = l[i];
    if (!_restoring) {
      final editId = _commonOf(before)?.editId;
      if (editId != null) {
        ref.read(gestureUndoProvider.notifier).record(editId, before);
      }
    }
    l[i] = m(l[i]);
  });

  static TriggerCommon? _commonOf(Object gesture) => switch (gesture) {
    MouseGesture(:final common) => common,
    KeyboardGesture(:final common) => common,
    PointerGesture(:final common) => common,
    TouchpadGesture(:final common) => common,
    TouchscreenGesture(:final common) => common,
    _ => null,
  };

  // ---------------------------------------------------------------------------
  // Mouse
  // ---------------------------------------------------------------------------

  void addMouseGesture(MouseGesture g) => _modifyList(
    (c) => c.mouseGestures,
    (c, l) => c.copyWith(mouseGestures: l),
    (l) => l.add(g),
  );

  void updateMouseGesture(int i, MouseGesture Function(MouseGesture) m) =>
      _updateGesture<MouseGesture>(
        (c) => c.mouseGestures,
        (c, l) => c.copyWith(mouseGestures: l),
        i,
        m,
      );

  void duplicateMouseGesture(int i) => _modifyList(
    (c) => c.mouseGestures,
    (c, l) => c.copyWith(mouseGestures: l),
    (l) {
      if (i >= 0 && i < l.length) l.insert(i + 1, l[i]);
    },
  );

  void removeMouseGesture(int i) => _modifyList(
    (c) => c.mouseGestures,
    (c, l) => c.copyWith(mouseGestures: l),
    (l) {
      if (i >= 0 && i < l.length) l.removeAt(i);
    },
  );

  void reorderMouseGesture(int oldIndex, int newIndex) => _modifyList(
    (c) => c.mouseGestures,
    (c, l) => c.copyWith(mouseGestures: l),
    (l) => _reorder(l, oldIndex, newIndex),
  );

  // Backward-compat aliases used by existing gesture_list_section / gesture_editor
  void addGesture(MouseGesture g) => addMouseGesture(g);
  void updateGesture(int i, MouseGesture Function(MouseGesture) m) =>
      updateMouseGesture(i, m);
  void duplicateGesture(int i) => duplicateMouseGesture(i);
  void removeGesture(int i) => removeMouseGesture(i);
  void reorderGesture(int o, int n) => reorderMouseGesture(o, n);

  // ---------------------------------------------------------------------------
  // Keyboard
  // ---------------------------------------------------------------------------

  void addKeyboardGesture(KeyboardGesture g) => _modifyList(
    (c) => c.keyboardGestures,
    (c, l) => c.copyWith(keyboardGestures: l),
    (l) => l.add(g),
  );

  void updateKeyboardGesture(
    int i,
    KeyboardGesture Function(KeyboardGesture) m,
  ) => _updateGesture<KeyboardGesture>(
    (c) => c.keyboardGestures,
    (c, l) => c.copyWith(keyboardGestures: l),
    i,
    m,
  );

  void duplicateKeyboardGesture(int i) => _modifyList(
    (c) => c.keyboardGestures,
    (c, l) => c.copyWith(keyboardGestures: l),
    (l) {
      if (i >= 0 && i < l.length) l.insert(i + 1, l[i]);
    },
  );

  void removeKeyboardGesture(int i) => _modifyList(
    (c) => c.keyboardGestures,
    (c, l) => c.copyWith(keyboardGestures: l),
    (l) {
      if (i >= 0 && i < l.length) l.removeAt(i);
    },
  );

  void reorderKeyboardGesture(int o, int n) => _modifyList(
    (c) => c.keyboardGestures,
    (c, l) => c.copyWith(keyboardGestures: l),
    (l) => _reorder(l, o, n),
  );

  // ---------------------------------------------------------------------------
  // Pointer
  // ---------------------------------------------------------------------------

  void addPointerGesture(PointerGesture g) => _modifyList(
    (c) => c.pointerGestures,
    (c, l) => c.copyWith(pointerGestures: l),
    (l) => l.add(g),
  );

  void updatePointerGesture(int i, PointerGesture Function(PointerGesture) m) =>
      _updateGesture<PointerGesture>(
        (c) => c.pointerGestures,
        (c, l) => c.copyWith(pointerGestures: l),
        i,
        m,
      );

  void duplicatePointerGesture(int i) => _modifyList(
    (c) => c.pointerGestures,
    (c, l) => c.copyWith(pointerGestures: l),
    (l) {
      if (i >= 0 && i < l.length) l.insert(i + 1, l[i]);
    },
  );

  void removePointerGesture(int i) => _modifyList(
    (c) => c.pointerGestures,
    (c, l) => c.copyWith(pointerGestures: l),
    (l) {
      if (i >= 0 && i < l.length) l.removeAt(i);
    },
  );

  void reorderPointerGesture(int o, int n) => _modifyList(
    (c) => c.pointerGestures,
    (c, l) => c.copyWith(pointerGestures: l),
    (l) => _reorder(l, o, n),
  );

  // ---------------------------------------------------------------------------
  // Touchpad
  // ---------------------------------------------------------------------------

  void addTouchpadGesture(TouchpadGesture g) => _modifyList(
    (c) => c.touchpadGestures,
    (c, l) => c.copyWith(touchpadGestures: l),
    (l) => l.add(g),
  );

  void updateTouchpadGesture(
    int i,
    TouchpadGesture Function(TouchpadGesture) m,
  ) => _updateGesture<TouchpadGesture>(
    (c) => c.touchpadGestures,
    (c, l) => c.copyWith(touchpadGestures: l),
    i,
    m,
  );

  void duplicateTouchpadGesture(int i) => _modifyList(
    (c) => c.touchpadGestures,
    (c, l) => c.copyWith(touchpadGestures: l),
    (l) {
      if (i >= 0 && i < l.length) l.insert(i + 1, l[i]);
    },
  );

  void removeTouchpadGesture(int i) => _modifyList(
    (c) => c.touchpadGestures,
    (c, l) => c.copyWith(touchpadGestures: l),
    (l) {
      if (i >= 0 && i < l.length) l.removeAt(i);
    },
  );

  void reorderTouchpadGesture(int o, int n) => _modifyList(
    (c) => c.touchpadGestures,
    (c, l) => c.copyWith(touchpadGestures: l),
    (l) => _reorder(l, o, n),
  );

  // ---------------------------------------------------------------------------
  // Touchscreen
  // ---------------------------------------------------------------------------

  void addTouchscreenGesture(TouchscreenGesture g) => _modifyList(
    (c) => c.touchscreenGestures,
    (c, l) => c.copyWith(touchscreenGestures: l),
    (l) => l.add(g),
  );

  void updateTouchscreenGesture(
    int i,
    TouchscreenGesture Function(TouchscreenGesture) m,
  ) => _updateGesture<TouchscreenGesture>(
    (c) => c.touchscreenGestures,
    (c, l) => c.copyWith(touchscreenGestures: l),
    i,
    m,
  );

  void duplicateTouchscreenGesture(int i) => _modifyList(
    (c) => c.touchscreenGestures,
    (c, l) => c.copyWith(touchscreenGestures: l),
    (l) {
      if (i >= 0 && i < l.length) l.insert(i + 1, l[i]);
    },
  );

  void removeTouchscreenGesture(int i) => _modifyList(
    (c) => c.touchscreenGestures,
    (c, l) => c.copyWith(touchscreenGestures: l),
    (l) {
      if (i >= 0 && i < l.length) l.removeAt(i);
    },
  );

  void reorderTouchscreenGesture(int o, int n) => _modifyList(
    (c) => c.touchscreenGestures,
    (c, l) => c.copyWith(touchscreenGestures: l),
    (l) => _reorder(l, o, n),
  );

  // ---------------------------------------------------------------------------
  // Device-dispatched helpers used by the generic list UI
  // ---------------------------------------------------------------------------

  void addGestureForDevice(DeviceType device, dynamic gesture) {
    switch (device) {
      case DeviceType.mouse:
        addMouseGesture(gesture as MouseGesture);
      case DeviceType.keyboard:
        addKeyboardGesture(gesture as KeyboardGesture);
      case DeviceType.pointer:
        addPointerGesture(gesture as PointerGesture);
      case DeviceType.touchpad:
        addTouchpadGesture(gesture as TouchpadGesture);
      case DeviceType.touchscreen:
        addTouchscreenGesture(gesture as TouchscreenGesture);
    }
  }

  void duplicateGestureForDevice(DeviceType device, int i) {
    switch (device) {
      case DeviceType.mouse:
        duplicateMouseGesture(i);
      case DeviceType.keyboard:
        duplicateKeyboardGesture(i);
      case DeviceType.pointer:
        duplicatePointerGesture(i);
      case DeviceType.touchpad:
        duplicateTouchpadGesture(i);
      case DeviceType.touchscreen:
        duplicateTouchscreenGesture(i);
    }
  }

  void removeGestureForDevice(DeviceType device, int i) {
    switch (device) {
      case DeviceType.mouse:
        removeMouseGesture(i);
      case DeviceType.keyboard:
        removeKeyboardGesture(i);
      case DeviceType.pointer:
        removePointerGesture(i);
      case DeviceType.touchpad:
        removeTouchpadGesture(i);
      case DeviceType.touchscreen:
        removeTouchscreenGesture(i);
    }
  }

  void updateGestureCommonForDevice(
    DeviceType device,
    int i,
    TriggerCommon Function(TriggerCommon) m,
  ) {
    switch (device) {
      case DeviceType.mouse:
        updateMouseGesture(i, (g) => g.withCommon(m(g.common)));
      case DeviceType.keyboard:
        updateKeyboardGesture(i, (g) => g.withCommon(m(g.common)));
      case DeviceType.pointer:
        updatePointerGesture(i, (g) => g.withCommon(m(g.common)));
      case DeviceType.touchpad:
        updateTouchpadGesture(i, (g) => g.withCommon(m(g.common)));
      case DeviceType.touchscreen:
        updateTouchscreenGesture(i, (g) => g.withCommon(m(g.common)));
    }
  }

  void reorderGestureForDevice(DeviceType device, int o, int n) {
    switch (device) {
      case DeviceType.mouse:
        reorderMouseGesture(o, n);
      case DeviceType.keyboard:
        reorderKeyboardGesture(o, n);
      case DeviceType.pointer:
        reorderPointerGesture(o, n);
      case DeviceType.touchpad:
        reorderTouchpadGesture(o, n);
      case DeviceType.touchscreen:
        reorderTouchscreenGesture(o, n);
    }
  }

  // ---------------------------------------------------------------------------
  // Gesture groups
  // ---------------------------------------------------------------------------

  void addGestureGroup(GestureGroup group) => _modifyList(
    (c) => c.gestureGroups,
    (c, l) => c.copyWith(gestureGroups: l),
    (l) => l.add(group),
  );

  void updateGestureGroup(String id, GestureGroup Function(GestureGroup) m) =>
      _modifyList(
        (c) => c.gestureGroups,
        (c, l) => c.copyWith(gestureGroups: l),
        (l) {
          final i = l.indexWhere((g) => g.id == id);
          if (i >= 0) l[i] = m(l[i]);
        },
      );

  void reorderGestureGroupForDevice(
    DeviceType device,
    int oldIndex,
    int newIndex,
  ) => _modifyList(
    (c) => c.gestureGroups,
    (c, l) => c.copyWith(gestureGroups: l),
    (l) {
      final deviceGroups = l.where((g) => g.device == device).toList();
      if (oldIndex < 0 || oldIndex >= deviceGroups.length) return;

      _reorder(deviceGroups, oldIndex, newIndex);

      var deviceGroupIndex = 0;
      for (var i = 0; i < l.length; i++) {
        if (l[i].device == device) {
          l[i] = deviceGroups[deviceGroupIndex++];
        }
      }
    },
  );

  void removeGestureGroupAndUngroup(String id) {
    final current = state.value;
    if (current == null) return;

    void clearGroupId<T>(
      List<T> Function(Config) getList,
      Config Function(Config, List<T>) setList,
      T Function(T) clearGroup,
    ) {
      _modifyList(getList, setList, (l) {
        for (var i = 0; i < l.length; i++) {
          l[i] = clearGroup(l[i]);
        }
      });
    }

    clearGroupId<MouseGesture>(
      (c) => c.mouseGestures,
      (c, l) => c.copyWith(mouseGestures: l),
      (g) => g.common.groupId == id
          ? g.withCommon(g.common.copyWith(groupId: null))
          : g,
    );
    clearGroupId<KeyboardGesture>(
      (c) => c.keyboardGestures,
      (c, l) => c.copyWith(keyboardGestures: l),
      (g) => g.common.groupId == id
          ? g.withCommon(g.common.copyWith(groupId: null))
          : g,
    );
    clearGroupId<PointerGesture>(
      (c) => c.pointerGestures,
      (c, l) => c.copyWith(pointerGestures: l),
      (g) => g.common.groupId == id
          ? g.withCommon(g.common.copyWith(groupId: null))
          : g,
    );
    clearGroupId<TouchpadGesture>(
      (c) => c.touchpadGestures,
      (c, l) => c.copyWith(touchpadGestures: l),
      (g) => g.common.groupId == id
          ? g.withCommon(g.common.copyWith(groupId: null))
          : g,
    );
    clearGroupId<TouchscreenGesture>(
      (c) => c.touchscreenGestures,
      (c, l) => c.copyWith(touchscreenGestures: l),
      (g) => g.common.groupId == id
          ? g.withCommon(g.common.copyWith(groupId: null))
          : g,
    );
    _modifyList(
      (c) => c.gestureGroups,
      (c, l) => c.copyWith(gestureGroups: l),
      (l) => l.removeWhere((g) => g.id == id),
    );
  }

  void deleteGestureGroupWithGestures(String id, DeviceType device) {
    _modifyList(
      (c) => c.mouseGestures,
      (c, l) => c.copyWith(mouseGestures: l),
      (l) => l.removeWhere((g) => g.common.groupId == id),
    );
    _modifyList(
      (c) => c.keyboardGestures,
      (c, l) => c.copyWith(keyboardGestures: l),
      (l) => l.removeWhere((g) => g.common.groupId == id),
    );
    _modifyList(
      (c) => c.pointerGestures,
      (c, l) => c.copyWith(pointerGestures: l),
      (l) => l.removeWhere((g) => g.common.groupId == id),
    );
    _modifyList(
      (c) => c.touchpadGestures,
      (c, l) => c.copyWith(touchpadGestures: l),
      (l) => l.removeWhere((g) => g.common.groupId == id),
    );
    _modifyList(
      (c) => c.touchscreenGestures,
      (c, l) => c.copyWith(touchscreenGestures: l),
      (l) => l.removeWhere((g) => g.common.groupId == id),
    );
    _modifyList(
      (c) => c.gestureGroups,
      (c, l) => c.copyWith(gestureGroups: l),
      (l) => l.removeWhere((g) => g.id == id),
    );
  }

  /// Reorders gestures for [device] according to [newOrder] (list of old config
  /// indices in the desired new order), and updates the groupId of the gesture
  /// at [changedOldConfigIdx] to [newGroupId].
  void reorderAndUpdateGroupForDevice(
    DeviceType device,
    List<int> newOrder,
    int changedOldConfigIdx,
    String? newGroupId,
  ) {
    switch (device) {
      case DeviceType.mouse:
        _reorderAndUpdateGroup<MouseGesture>(
          (c) => c.mouseGestures,
          (c, l) => c.copyWith(mouseGestures: l),
          (g, gid) => g.withCommon(g.common.copyWith(groupId: gid)),
          newOrder,
          changedOldConfigIdx,
          newGroupId,
        );
      case DeviceType.keyboard:
        _reorderAndUpdateGroup<KeyboardGesture>(
          (c) => c.keyboardGestures,
          (c, l) => c.copyWith(keyboardGestures: l),
          (g, gid) => g.withCommon(g.common.copyWith(groupId: gid)),
          newOrder,
          changedOldConfigIdx,
          newGroupId,
        );
      case DeviceType.pointer:
        _reorderAndUpdateGroup<PointerGesture>(
          (c) => c.pointerGestures,
          (c, l) => c.copyWith(pointerGestures: l),
          (g, gid) => g.withCommon(g.common.copyWith(groupId: gid)),
          newOrder,
          changedOldConfigIdx,
          newGroupId,
        );
      case DeviceType.touchpad:
        _reorderAndUpdateGroup<TouchpadGesture>(
          (c) => c.touchpadGestures,
          (c, l) => c.copyWith(touchpadGestures: l),
          (g, gid) => g.withCommon(g.common.copyWith(groupId: gid)),
          newOrder,
          changedOldConfigIdx,
          newGroupId,
        );
      case DeviceType.touchscreen:
        _reorderAndUpdateGroup<TouchscreenGesture>(
          (c) => c.touchscreenGestures,
          (c, l) => c.copyWith(touchscreenGestures: l),
          (g, gid) => g.withCommon(g.common.copyWith(groupId: gid)),
          newOrder,
          changedOldConfigIdx,
          newGroupId,
        );
    }
  }

  /// Reorders gestures for [device] and updates group ids for every moved
  /// gesture keyed by its old config index.
  void reorderAndUpdateGroupsForDevice(
    DeviceType device,
    List<int> newOrder,
    Map<int, String?> changedGroupIdsByOldConfigIdx,
  ) {
    switch (device) {
      case DeviceType.mouse:
        _reorderAndUpdateGroups<MouseGesture>(
          (c) => c.mouseGestures,
          (c, l) => c.copyWith(mouseGestures: l),
          (g, gid) => g.withCommon(g.common.copyWith(groupId: gid)),
          newOrder,
          changedGroupIdsByOldConfigIdx,
        );
      case DeviceType.keyboard:
        _reorderAndUpdateGroups<KeyboardGesture>(
          (c) => c.keyboardGestures,
          (c, l) => c.copyWith(keyboardGestures: l),
          (g, gid) => g.withCommon(g.common.copyWith(groupId: gid)),
          newOrder,
          changedGroupIdsByOldConfigIdx,
        );
      case DeviceType.pointer:
        _reorderAndUpdateGroups<PointerGesture>(
          (c) => c.pointerGestures,
          (c, l) => c.copyWith(pointerGestures: l),
          (g, gid) => g.withCommon(g.common.copyWith(groupId: gid)),
          newOrder,
          changedGroupIdsByOldConfigIdx,
        );
      case DeviceType.touchpad:
        _reorderAndUpdateGroups<TouchpadGesture>(
          (c) => c.touchpadGestures,
          (c, l) => c.copyWith(touchpadGestures: l),
          (g, gid) => g.withCommon(g.common.copyWith(groupId: gid)),
          newOrder,
          changedGroupIdsByOldConfigIdx,
        );
      case DeviceType.touchscreen:
        _reorderAndUpdateGroups<TouchscreenGesture>(
          (c) => c.touchscreenGestures,
          (c, l) => c.copyWith(touchscreenGestures: l),
          (g, gid) => g.withCommon(g.common.copyWith(groupId: gid)),
          newOrder,
          changedGroupIdsByOldConfigIdx,
        );
    }
  }

  void _reorderAndUpdateGroup<T>(
    List<T> Function(Config) getList,
    Config Function(Config, List<T>) setList,
    T Function(T, String?) updateGroupId,
    List<int> newOrder,
    int changedOldIdx,
    String? newGroupId,
  ) {
    _modifyList(getList, setList, (l) {
      final original = List<T>.of(l);
      l.clear();
      for (final oldIdx in newOrder) {
        final item = original[oldIdx];
        l.add(
          oldIdx == changedOldIdx ? updateGroupId(item, newGroupId) : item,
        );
      }
    });
  }

  void _reorderAndUpdateGroups<T>(
    List<T> Function(Config) getList,
    Config Function(Config, List<T>) setList,
    T Function(T, String?) updateGroupId,
    List<int> newOrder,
    Map<int, String?> changedGroupIdsByOldConfigIdx,
  ) {
    _modifyList(getList, setList, (l) {
      final original = List<T>.of(l);
      l.clear();
      for (final oldIdx in newOrder) {
        var item = original[oldIdx];
        if (changedGroupIdsByOldConfigIdx.containsKey(oldIdx)) {
          item = updateGroupId(item, changedGroupIdsByOldConfigIdx[oldIdx]);
        }
        l.add(item);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Device rules
  // ---------------------------------------------------------------------------

  void addDeviceRule(DeviceRule rule) => _modifyList(
    (c) => c.deviceRules,
    (c, l) => c.copyWith(deviceRules: l),
    (l) => l.add(rule),
  );

  void updateDeviceRule(int i, DeviceRule Function(DeviceRule) m) =>
      _modifyList(
        (c) => c.deviceRules,
        (c, l) => c.copyWith(deviceRules: l),
        (l) {
          if (i >= 0 && i < l.length) l[i] = m(l[i]);
        },
      );

  void removeDeviceRule(int i) => _modifyList(
    (c) => c.deviceRules,
    (c, l) => c.copyWith(deviceRules: l),
    (l) {
      if (i >= 0 && i < l.length) l.removeAt(i);
    },
  );

  void reorderDeviceRule(int oldIndex, int newIndex) => _modifyList(
    (c) => c.deviceRules,
    (c, l) => c.copyWith(deviceRules: l),
    (l) => _reorder(l, oldIndex, newIndex),
  );

  void replaceDeviceRules(List<DeviceRule> rules) {
    final current = state.value;
    if (current == null) return;
    _applyConfig(
      current.copyWith(deviceRules: List<DeviceRule>.of(rules)),
    );
  }

  // ---------------------------------------------------------------------------
  // Speed settings
  // ---------------------------------------------------------------------------

  void updateMouseSpeed(SpeedSettings? speed) {
    final current = state.value;
    if (current == null) return;
    _applyConfig(current.copyWith(mouseSpeed: speed));
  }

  void updateTouchpadSpeed(SpeedSettings? speed) {
    final current = state.value;
    if (current == null) return;
    _applyConfig(current.copyWith(touchpadSpeed: speed));
  }

  void updateTouchscreenSpeed(SpeedSettings? speed) {
    final current = state.value;
    if (current == null) return;
    _applyConfig(current.copyWith(touchscreenSpeed: speed));
  }

  // ---------------------------------------------------------------------------
  // Global settings
  // ---------------------------------------------------------------------------

  void updateGlobalSettings(GlobalSettings Function(GlobalSettings) m) {
    final current = state.value;
    if (current == null) return;
    _applyConfig(
      current.copyWith(globalSettings: m(current.globalSettings)),
    );
  }

  // ---------------------------------------------------------------------------
  // Persist
  // ---------------------------------------------------------------------------

  void discardChanges() {
    final saved = _savedConfig;
    if (saved == null || !isDirty) return;
    state = AsyncData(saved);
  }

  Future<void> save() async {
    try {
      final config = state.value;
      if (config == null || !isDirty) return;
      state = const AsyncLoading();
      await saveConfig(config, _originalText);
      final (reloaded, text) = await loadConfig();
      // Reload reconstructs gestures with fresh editIds; carry the pre-save
      // ids over by position (save never reorders) so the undo history keyed
      // by editId stays valid across a save.
      final remapped = preserveEditIds(from: config, to: reloaded);
      _originalText = text;
      _savedConfig = remapped;
      state = AsyncData(remapped);
    } on Exception catch (_) {
      // print('Failed to save config: $e');
    }
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    final (config, text) = await loadConfig();
    final normalized = assignEditIds(config);
    _originalText = text;
    _savedConfig = normalized;
    state = AsyncData(normalized);
  }

  Future<void> loadFromPicker() async {
    final path = await pickConfigFilePath();

    if (path != null && path.isNotEmpty) {
      await loadFromFile(path);
    }
  }

  Future<void> loadFromFile(String path) async {
    state = const AsyncLoading();
    final (config, text) = await loadConfigFromPath(path);
    final normalized = assignEditIds(config);
    _originalText = text;
    _savedConfig = null;
    state = AsyncData(normalized);
  }

  // ---------------------------------------------------------------------------
  // Per-gesture undo / redo
  // ---------------------------------------------------------------------------

  /// Restores the previous snapshot of the gesture at [device]/[index] from its
  /// undo history. The gesture is resolved by its editId, so a stale [index]
  /// from concurrent reordering still targets the right history.
  void undoActiveGesture(DeviceType device, int index) =>
      _stepGesture(device, index, undo: true);

  void redoActiveGesture(DeviceType device, int index) =>
      _stepGesture(device, index, undo: false);

  void _stepGesture(DeviceType device, int index, {required bool undo}) {
    final config = state.value;
    if (config == null) return;
    final gestures = config.gesturesForDevice(device);
    if (index < 0 || index >= gestures.length) return;
    final current = gestures[index] as Object;
    final editId = _commonOf(current)?.editId;
    if (editId == null) return;
    final undoController = ref.read(gestureUndoProvider.notifier);
    final target = undo
        ? undoController.undo(editId, current)
        : undoController.redo(editId, current);
    if (target == null) return;
    _setGestureAt(device, index, target);
  }

  void _setGestureAt(DeviceType device, int index, Object gesture) {
    _restoring = true;
    try {
      switch (device) {
        case DeviceType.mouse:
          updateMouseGesture(index, (_) => gesture as MouseGesture);
        case DeviceType.keyboard:
          updateKeyboardGesture(index, (_) => gesture as KeyboardGesture);
        case DeviceType.pointer:
          updatePointerGesture(index, (_) => gesture as PointerGesture);
        case DeviceType.touchpad:
          updateTouchpadGesture(index, (_) => gesture as TouchpadGesture);
        case DeviceType.touchscreen:
          updateTouchscreenGesture(
            index,
            (_) => gesture as TouchscreenGesture,
          );
      }
    } finally {
      _restoring = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  static void _reorder<T>(List<T> l, int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= l.length) return;
    final item = l.removeAt(oldIndex);
    final insertAt = newIndex > oldIndex ? newIndex - 1 : newIndex;
    l.insert(insertAt.clamp(0, l.length), item);
  }
}

final configControllerProvider =
    AsyncNotifierProvider<ConfigController, Config>(ConfigController.new);

class _EditStack {
  final List<_EditEntry> _undo = [];
  final List<_EditEntry> _redo = [];

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  void push(ConfigEdit edit, ConfigEdit inverse) {
    _undo.add(_EditEntry(edit: edit, inverse: inverse));
    _redo.clear();
  }

  ConfigEdit? popUndo() {
    if (_undo.isEmpty) return null;
    final entry = _undo.removeLast();
    _redo.add(entry);
    return entry.inverse;
  }

  ConfigEdit? popRedo() {
    if (_redo.isEmpty) return null;
    final entry = _redo.removeLast();
    _undo.add(entry);
    return entry.edit;
  }
}

class _EditEntry {
  const _EditEntry({required this.edit, required this.inverse});

  final ConfigEdit edit;
  final ConfigEdit inverse;
}

int _editIdSequence = 0;
int _nextEditId() => ++_editIdSequence;

/// Ensures every gesture carries a unique, non-null [TriggerCommon.editId].
/// Fills nulls (freshly parsed or added gestures) and de-duplicates collisions
/// (a duplicated gesture initially shares its source's id). Returns the same
/// [config] instance unchanged when no assignment was needed, so normal edits
/// don't churn object identity. editId is excluded from equality, so this never
/// affects dirty state.
Config assignEditIds(Config config) {
  final seen = <int>{};
  var changed = false;

  List<T> fix<T>(
    List<T> list,
    TriggerCommon Function(T) commonOf,
    T Function(T, TriggerCommon) withCommon,
  ) {
    var listChanged = false;
    final out = <T>[];
    for (final gesture in list) {
      final common = commonOf(gesture);
      final id = common.editId;
      if (id == null || !seen.add(id)) {
        final newId = _nextEditId();
        seen.add(newId);
        out.add(withCommon(gesture, common.copyWith(editId: newId)));
        listChanged = true;
      } else {
        out.add(gesture);
      }
    }
    if (listChanged) changed = true;
    return listChanged ? out : list;
  }

  final mouse = fix<MouseGesture>(
    config.mouseGestures,
    (g) => g.common,
    (g, c) => g.withCommon(c),
  );
  final keyboard = fix<KeyboardGesture>(
    config.keyboardGestures,
    (g) => g.common,
    (g, c) => g.withCommon(c),
  );
  final pointer = fix<PointerGesture>(
    config.pointerGestures,
    (g) => g.common,
    (g, c) => g.withCommon(c),
  );
  final touchpad = fix<TouchpadGesture>(
    config.touchpadGestures,
    (g) => g.common,
    (g, c) => g.withCommon(c),
  );
  final touchscreen = fix<TouchscreenGesture>(
    config.touchscreenGestures,
    (g) => g.common,
    (g, c) => g.withCommon(c),
  );

  if (!changed) return config;
  return config.copyWith(
    mouseGestures: mouse,
    keyboardGestures: keyboard,
    pointerGestures: pointer,
    touchpadGestures: touchpad,
    touchscreenGestures: touchscreen,
  );
}

/// Carries the editIds from [from] onto [to] by gesture position. Used after a
/// save round-trip (write + reload), which reconstructs gestures with fresh
/// ids: since save never reorders, position-matching keeps the undo history
/// keyed by editId valid. Any unmatched positions get fresh ids.
Config preserveEditIds({required Config from, required Config to}) {
  List<T> remap<T>(
    List<T> source,
    List<T> target,
    TriggerCommon Function(T) commonOf,
    T Function(T, TriggerCommon) withCommon,
  ) {
    final out = <T>[];
    for (var i = 0; i < target.length; i++) {
      if (i < source.length) {
        out.add(
          withCommon(
            target[i],
            commonOf(target[i]).copyWith(editId: commonOf(source[i]).editId),
          ),
        );
      } else {
        out.add(target[i]);
      }
    }
    return out;
  }

  final remapped = to.copyWith(
    mouseGestures: remap<MouseGesture>(
      from.mouseGestures,
      to.mouseGestures,
      (g) => g.common,
      (g, c) => g.withCommon(c),
    ),
    keyboardGestures: remap<KeyboardGesture>(
      from.keyboardGestures,
      to.keyboardGestures,
      (g) => g.common,
      (g, c) => g.withCommon(c),
    ),
    pointerGestures: remap<PointerGesture>(
      from.pointerGestures,
      to.pointerGestures,
      (g) => g.common,
      (g, c) => g.withCommon(c),
    ),
    touchpadGestures: remap<TouchpadGesture>(
      from.touchpadGestures,
      to.touchpadGestures,
      (g) => g.common,
      (g, c) => g.withCommon(c),
    ),
    touchscreenGestures: remap<TouchscreenGesture>(
      from.touchscreenGestures,
      to.touchscreenGestures,
      (g) => g.common,
      (g, c) => g.withCommon(c),
    ),
  );
  return assignEditIds(remapped);
}
