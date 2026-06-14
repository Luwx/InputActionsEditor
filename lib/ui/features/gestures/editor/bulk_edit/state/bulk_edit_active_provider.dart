import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the detail pane shows the bulk-edit page (vs. the multi-select
/// options panel) while a multi-selection is active. Reset to false when the
/// selection clears or the user backs out of the page.
class BulkEditActiveController extends Notifier<bool> {
  @override
  bool build() => false;

  void open() => state = true;

  void close() => state = false;
}

final bulkEditActiveProvider = NotifierProvider<BulkEditActiveController, bool>(
  BulkEditActiveController.new,
);
