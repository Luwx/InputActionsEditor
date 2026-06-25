// Build-order tracing used during render profiling. Flip [_printBuilds] to true
// to log each widget build, indented to match its depth in the tree.
const bool _printBuilds = false;

/// Logs a build-trace line for [name] at [indent] depth (two spaces per level).
/// No-op unless [_printBuilds] is enabled.
void printBuild(int indent, String name) {
  if (!_printBuilds) return;
  // Diagnostic-only tracer; print is the intended sink here.
  // ignore: avoid_print
  print('${'  ' * indent}$name');
}
