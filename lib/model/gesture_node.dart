import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:meta_generator/meta_generator.dart';

part 'gesture_node.freezed.dart';
part 'gesture_node.g.dart';

/// One entry of a device's gesture tree: a gesture, or a group containing a
/// subtree. Membership is containment, groups have no serialized identity.
@freezed
@withMeta
sealed class GestureNode with _$GestureNode {
  const factory GestureNode.leaf(Gesture gesture) = GestureLeaf;

  const factory GestureNode.group({
    @Default('') String name,
    @Default(true) bool enabled,

    /// Conditions the daemon applies to every gesture in this group. Unlike
    /// the shared properties below, conditions genuinely compose: the daemon
    /// AND-merges a group's conditions into each descendant's own.
    Condition? conditions,

    /// Shared trigger properties. The daemon copies each of these onto every
    /// gesture in the subtree that does not set the key itself, see
    /// [GestureGroupNode] docs on why a descendant setting the same key is an
    /// unresolvable conflict rather than an override.
    String? id,
    String? threshold,
    int? resumeTimeout,
    bool? accelerated,
    bool? blockEvents,
    bool? clearModifiers,
    bool? setLastTrigger,
    Condition? endConditions,

    /// Unmodelled properties of the group node, preserved for round-trip.
    @Default(<String, dynamic>{}) Map<String, dynamic> extra,
    @Default(<GestureNode>[]) List<GestureNode> children,

    /// In-memory identity for UI state and edit targeting, assigned by
    /// `assignEditIds` like gesture editIds; never serialized.
    int? editId,
  }) = GestureGroupNode;

  const GestureNode._();

  /// Gestures in this subtree, depth-first.
  Iterable<Gesture> get gestures sync* {
    switch (this) {
      case GestureLeaf(:final gesture):
        yield gesture;
      case GestureGroupNode(:final children):
        for (final child in children) {
          yield* child.gestures;
        }
    }
  }
}
