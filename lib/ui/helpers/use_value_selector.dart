import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Watches one slice of [source] and rebuilds only when that slice changes.
S useValueSelector<T, S>(
  ValueListenable<T> source,
  S Function(T value) select,
) {
  final selectRef = useRef(select)..value = select;
  final selected = useState(select(source.value));

  useEffect(() {
    void listener() {
      final next = selectRef.value(source.value);
      if (selected.value != next) selected.value = next;
    }

    source.addListener(listener);
    // The value may have moved between the build above and this subscription.
    listener();
    return () => source.removeListener(listener);
  }, [source]);

  return selected.value;
}
