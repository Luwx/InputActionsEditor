import 'dart:convert';

class RecognitionPoint {
  const RecognitionPoint(this.x, this.y);
  final double x;
  final double y;
}

class RecognitionCandidate {
  const RecognitionCandidate({
    required this.identifier,
    required this.triggerType,
    this.score,
  });

  final String identifier;
  final String triggerType;
  final double? score;

  static RecognitionCandidate? _fromMap(Map<dynamic, dynamic> map) {
    final id = (map['identifier'] ?? map['id'] ?? map['trigger_id'])
        ?.toString();
    final type = (map['trigger_type'] ?? map['type'])?.toString();
    if (id == null || type == null) return null;
    return RecognitionCandidate(
      identifier: id,
      triggerType: type,
      score: (map['score'] as num?)?.toDouble(),
    );
  }
}

class RecognitionEvent {
  const RecognitionEvent({
    required this.timestamp,
    required this.matched,
    this.matchedIdentifier,
    this.triggerType,
    this.triggerId,
    this.actionIds = const [],
    this.mouseButtons = const [],
    this.configuredDirection,
    this.angle,
    this.averageAngle,
    this.configuredMinAngle,
    this.configuredMaxAngle,
    this.rawPathPoints = const [],
    this.bestScore,
    this.candidates = const [],
  });

  final DateTime timestamp;
  final bool matched;
  final String? matchedIdentifier;
  final String? triggerType;
  final String? triggerId;
  final List<String> actionIds;
  final List<String> mouseButtons;
  final String? configuredDirection;
  final double? angle;
  final double? averageAngle;
  final double? configuredMinAngle;
  final double? configuredMaxAngle;
  final List<RecognitionPoint> rawPathPoints;
  final double? bestScore;
  final List<RecognitionCandidate> candidates;

  static RecognitionEvent? fromJsonString(String jsonStr) {
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;

      final points = <RecognitionPoint>[];
      for (final p in (map['raw_path_points'] as List? ?? [])) {
        if (p is Map) {
          final x = (p['x'] as num?)?.toDouble();
          final y = (p['y'] as num?)?.toDouble();
          if (x != null && y != null) points.add(RecognitionPoint(x, y));
        }
      }

      final candidates = <RecognitionCandidate>[];
      for (final c in (map['candidates'] as List? ?? [])) {
        if (c is Map) {
          final cand = RecognitionCandidate._fromMap(c);
          if (cand != null) candidates.add(cand);
        }
      }

      return RecognitionEvent(
        timestamp: DateTime.now(),
        matched: map['matched'] as bool? ?? false,
        matchedIdentifier: (map['matched_identifier'] ?? map['best_trigger_id'])
            ?.toString(),
        triggerType: (map['trigger_type'] ?? map['best_trigger_type'])
            ?.toString(),
        triggerId: (map['trigger_id'] ?? map['best_trigger_id'])?.toString(),
        actionIds: (map['action_ids'] as List? ?? [])
            .map((e) => e.toString())
            .toList(),
        mouseButtons: (map['mouse_buttons'] as List? ?? [])
            .map((e) => e.toString())
            .toList(),
        configuredDirection: map['configured_direction']?.toString(),
        angle: (map['angle'] as num?)?.toDouble(),
        averageAngle: (map['average_angle'] as num?)?.toDouble(),
        configuredMinAngle: (map['configured_min_angle'] as num?)?.toDouble(),
        configuredMaxAngle: (map['configured_max_angle'] as num?)?.toDouble(),
        rawPathPoints: points,
        bestScore: (map['best_score'] as num?)?.toDouble(),
        candidates: candidates,
      );
    } on Object {
      return null;
    }
  }
}
