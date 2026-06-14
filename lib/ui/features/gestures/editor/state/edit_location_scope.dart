import 'package:edit_schema_generator/edit_schema_generator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema_extra.dart'
    show actionAt, branchCaseAt, gestureAt;
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/ui/helpers/editable_field.dart';

/// Addresses a single editable [TriggerAction], whether a top-level action or a
/// case inside a `one:` ([OneAction]) branch. Lets one row widget and the
/// scoped-field editors serve both contexts.
sealed class ActionAddress {
  const ActionAddress();

  /// The owning gesture, used as the edit scope for both kinds.
  GestureLocation get gesture;

  /// Resolves the addressed action against [config].
  TriggerAction? read(Config? config);

  /// A stable, value-equal identity for this address (the underlying location),
  /// suitable for hero tags and widget keys.
  Object get heroTag;
}

final class GestureActionAddress extends ActionAddress {
  const GestureActionAddress(this.location);
  final ActionLocation location;
  @override
  GestureLocation get gesture => location.gesture;
  @override
  TriggerAction? read(Config? config) => actionAt(config, location);
  @override
  Object get heroTag => location;
}

final class BranchCaseActionAddress extends ActionAddress {
  const BranchCaseActionAddress(this.location);
  final BranchCaseLocation location;
  @override
  GestureLocation get gesture => location.action;
  @override
  TriggerAction? read(Config? config) => branchCaseAt(config, location);
  @override
  Object get heroTag => location;
}

class EditLocationScope extends InheritedWidget {
  const EditLocationScope({
    required super.child,
    this.gesture,
    this.action,
    this.branchCase,
    this.bulk,
    super.key,
  }) : assert(
         gesture != null ||
             action != null ||
             branchCase != null ||
             bulk != null,
         'EditLocationScope requires a gesture, action, case, or bulk target.',
       );

  final GestureLocation? gesture;
  final ActionLocation? action;
  final BranchCaseLocation? branchCase;

  /// When set, scoped field reads/writes apply across this whole selection (the
  /// bulk-edit page). Resolved before the single-location targets.
  final Set<GestureLocation>? bulk;

  static EditLocationScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EditLocationScope>();

  static GestureLocation gestureOf(BuildContext context) {
    final scope = maybeOf(context);
    final location =
        scope?.gesture ?? scope?.action?.gesture ?? scope?.branchCase?.action;
    if (location == null) {
      throw FlutterError(
        'No GestureLocation found. Wrap this subtree in EditLocationScope.',
      );
    }
    return location;
  }

  static ActionLocation actionOf(BuildContext context) {
    final location = maybeOf(context)?.action;
    if (location == null) {
      throw FlutterError(
        'No ActionLocation found. Wrap this subtree in EditLocationScope.',
      );
    }
    return location;
  }

  static ActionAddress actionAddressOf(BuildContext context) {
    final scope = maybeOf(context);
    final branchCase = scope?.branchCase;
    if (branchCase != null) return BranchCaseActionAddress(branchCase);
    final action = scope?.action;
    if (action != null) return GestureActionAddress(action);
    throw FlutterError(
      'No action address found. Wrap this subtree in EditLocationScope with an '
      'action or branchCase target.',
    );
  }

  @override
  bool updateShouldNotify(EditLocationScope oldWidget) =>
      gesture != oldWidget.gesture ||
      action != oldWidget.action ||
      branchCase != oldWidget.branchCase ||
      !setEquals(bulk, oldWidget.bulk);
}

extension EditLocationContext on BuildContext {
  GestureLocation get gestureLocation => EditLocationScope.gestureOf(this);
  ActionLocation get actionLocation => EditLocationScope.actionOf(this);
  ActionAddress get actionAddress => EditLocationScope.actionAddressOf(this);
}

// Identity registries mapping a top-level action field/lens to its branch-case
// counterpart. Both are generated from the same schema leaf (e.g. the `command`
// case), so the leaf editors keep passing the `action*` variant unchanged and
// [actionField]/[actionSchemaField] swap in the `branchCase*` variant when the
// scope is a branch case — mirroring how the bulk path routes through
// [EditLocationScope.bulk]. Register every action field/lens a leaf editor may
// use; the assert fires if one is missing.
final Map<Object, Object> _branchCaseActionField = {
  // Action-kind fields.
  actionCommandField: branchCaseCommandField,
  actionWaitField: branchCaseWaitField,
  actionComponentField: branchCaseComponentField,
  actionShortcutField: branchCaseShortcutField,
  actionWindowIdField: branchCaseWindowIdField,
  actionExpressionField: branchCaseExpressionField,
  actionRawField: branchCaseRawField,
  actionDurationField: branchCaseDurationField,
  actionRulesField: branchCaseRulesField,
  actionInputEntriesField: branchCaseInputEntriesField,
  // Trigger-option fields (ActionTriggerFields).
  actionIntervalField: branchCaseIntervalField,
  actionThresholdField: branchCaseThresholdField,
  actionLimitField: branchCaseLimitField,
};

final Map<Object, Object> _branchCaseActionLens = {
  // Action-kind lenses.
  actionWaitLens: branchCaseWaitLens,
  actionDurationLens: branchCaseDurationLens,
  actionInputEntriesLens: branchCaseInputEntriesLens,
  actionRulesLens: branchCaseRulesLens,
  actionCommandLens: branchCaseCommandLens,
  // Trigger-option + condition lenses (ActionTriggerFields, condition editor).
  actionTriggerOnLens: branchCaseTriggerOnLens,
  actionConflictingLens: branchCaseConflictingLens,
  actionConditionsLens: branchCaseConditionsLens,
  actionEnabledLens: branchCaseEnabledLens,
};

extension ScopedFieldAccess on WidgetRef {
  EditableField<T> gestureField<T>(
    BuildContext context,
    Lens<T> Function(GestureLocation location) lensFor, {
    DirtyMarkState? dirty,
    T Function()? fallbackValue,
  }) {
    final bulk = EditLocationScope.maybeOf(context)?.bulk;
    if (bulk != null) {
      return bulkField<T>(bulk, lensFor, fallbackValue: fallbackValue);
    }
    final location = context.gestureLocation;
    return this.field<T>(
      lensFor(location),
      dirty: dirty,
      fallbackValue: fallbackValue,
      scope: location,
      canRead: (config) => gestureAt(config, location) != null,
    );
  }

  EditableField<T> actionField<T>(
    BuildContext context,
    Lens<T> Function(ActionLocation location) lensFor, {
    DirtyMarkState? dirty,
    T Function()? fallbackValue,
  }) {
    final addr = EditLocationScope.actionAddressOf(context);
    switch (addr) {
      case GestureActionAddress(:final location):
        return this.field<T>(
          lensFor(location),
          dirty: dirty,
          fallbackValue: fallbackValue,
          scope: location.gesture,
          canRead: (config) => actionAt(config, location) != null,
        );
      case BranchCaseActionAddress(:final location):
        final branchLensFor = _branchCaseActionLens[lensFor];
        assert(
          branchLensFor != null,
          'No branch-case lens registered for this action lens; add it to '
          '_branchCaseActionLens.',
        );
        final lens = (branchLensFor! as Lens<T> Function(BranchCaseLocation))(
          location,
        );
        return this.field<T>(
          lens,
          dirty: dirty,
          fallbackValue: fallbackValue,
          scope: location.action,
          canRead: (config) => branchCaseAt(config, location) != null,
        );
    }
  }

  SchemaEditableField<T> gestureSchemaField<TRoot, T>(
    BuildContext context,
    GeneratedEditField<TRoot, GestureLocation, T, Lens<T>> field, {
    DirtyMarkState? dirty,
  }) {
    final bulk = EditLocationScope.maybeOf(context)?.bulk;
    if (bulk != null) {
      return bulkSchemaField<TRoot, T>(bulk, field);
    }
    final location = context.gestureLocation;
    return schemaField(
      field,
      location: location,
      dirty: dirty,
      scope: location,
      canRead: (config) => gestureAt(config, location) != null,
    );
  }

  SchemaEditableField<T> actionSchemaField<TRoot, T>(
    BuildContext context,
    GeneratedEditField<TRoot, ActionLocation, T, Lens<T>> field, {
    DirtyMarkState? dirty,
  }) {
    final addr = EditLocationScope.actionAddressOf(context);
    switch (addr) {
      case GestureActionAddress(:final location):
        return schemaField(
          field,
          location: location,
          dirty: dirty,
          scope: location.gesture,
          canRead: (config) => actionAt(config, location) != null,
        );
      case BranchCaseActionAddress(:final location):
        final branchField = _branchCaseActionField[field];
        assert(
          branchField != null,
          'No branch-case field registered for this action field; add it to '
          '_branchCaseActionField.',
        );
        return schemaField(
          branchField!
              as GeneratedEditField<TRoot, BranchCaseLocation, T, Lens<T>>,
          location: location,
          dirty: dirty,
          scope: location.action,
          canRead: (config) => branchCaseAt(config, location) != null,
        );
    }
  }
}
