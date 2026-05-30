import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/state/device_settings_section_provider.dart';
import 'package:input_actions_editor/state/navigation/app_destination.dart';
import 'package:input_actions_editor/state/navigation/app_router_delegate.dart';
import 'package:input_actions_editor/state/navigation/nav_controller.dart';
import 'package:input_actions_editor/state/navigation/nav_state.dart';
import 'package:input_actions_editor/state/navigation/nav_transition.dart';

NavController _controller(ProviderContainer container) =>
    container.read(navProvider.notifier);

NavState _state(ProviderContainer container) => container.read(navProvider);

// ProviderContainer _fresh() => ProviderContainer();

void main() {
  group('NavController initial state', () {
    test('starts at GesturesDestination with cursor 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(_state(container).current, const GesturesDestination());
      expect(_state(container).cursor, 0);
      expect(_state(container).history.length, 1);
    });

    test('cannot go back or forward initially', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(_state(container).canBack, false);
      expect(_state(container).canForward, false);
    });
  });

  group('NavController.go', () {
    test('appends a new entry and moves cursor', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      _controller(container).go(const HistoryDestination());

      expect(_state(container).cursor, 1);
      expect(_state(container).current, const HistoryDestination());
      expect(_state(container).history.length, 2);
    });

    test('no-op when navigating to the current destination', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      _controller(container).go(const GesturesDestination());

      expect(_state(container).history.length, 1);
      expect(_state(container).cursor, 0);
    });

    test('drops forward entries on new navigation', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      _controller(container)
        ..go(const HistoryDestination())
        ..back()
        ..go(const SettingsDestination(SettingsSection.deviceSettings));

      expect(_state(container).history.length, 2);
      expect(
        _state(container).current,
        const SettingsDestination(SettingsSection.deviceSettings),
      );
      expect(_state(container).canForward, false);
    });
  });

  group('NavController.go replace:true', () {
    test('replaces current entry without adding a history stop', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      _controller(container).go(
        const SettingsDestination(SettingsSection.deviceSettings),
      );
      _controller(container).go(
        const SettingsDestination(
          SettingsSection.deviceSettings,
          device: DeviceSettingsSection.keyboard,
        ),
        replace: true,
      );

      expect(_state(container).history.length, 2);
      expect(_state(container).cursor, 1);
      expect(
        _state(container).current,
        const SettingsDestination(
          SettingsSection.deviceSettings,
          device: DeviceSettingsSection.keyboard,
        ),
      );
    });

    test('replace at cursor 0 keeps history length at 1', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      _controller(container).go(const HistoryDestination(), replace: true);

      expect(_state(container).history.length, 1);
      expect(_state(container).current, const HistoryDestination());
    });
  });

  group('NavController back/forward', () {
    test('back moves cursor left', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      _controller(container)
        ..go(const HistoryDestination())
        ..back();

      expect(_state(container).cursor, 0);
      expect(_state(container).current, const GesturesDestination());
    });

    test('back at start is a no-op', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      _controller(container).back();

      expect(_state(container).cursor, 0);
    });

    test('forward moves cursor right', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      _controller(container)
        ..go(const HistoryDestination())
        ..back()
        ..forward();

      expect(_state(container).cursor, 1);
      expect(_state(container).current, const HistoryDestination());
    });

    test('forward at end is a no-op', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      _controller(container).forward();

      expect(_state(container).cursor, 0);
    });

    test('canBack and canForward track cursor correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final ctrl = _controller(container)..go(const HistoryDestination());

      expect(_state(container).canBack, true);
      expect(_state(container).canForward, false);

      ctrl.back();

      expect(_state(container).canBack, false);
      expect(_state(container).canForward, true);
    });
  });

  group('NavController.closeSettings', () {
    test('goes back to non-settings destination when previous exists', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      _controller(container)
        ..go(const HistoryDestination())
        ..go(const SettingsDestination(SettingsSection.deviceSettings))
        ..closeSettings();

      expect(_state(container).current, const HistoryDestination());
    });

    test(
      'falls back to GesturesDestination when no non-settings predecessor',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        _controller(container)
          ..go(const SettingsDestination(SettingsSection.deviceSettings))
          ..back()
          ..go(const SettingsDestination(SettingsSection.appearance))
          ..closeSettings();

        expect(_state(container).current, const GesturesDestination());
      },
    );

    test('falls back to gestures when no previous entry at all', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      _controller(container).go(
        const SettingsDestination(SettingsSection.deviceSettings),
        replace: true,
      );
      _controller(container).closeSettings();

      expect(_state(container).current, const GesturesDestination());
    });
  });

  group('NavState computed getters', () {
    test('current returns history[cursor]', () {
      const state = NavState(
        history: [
          GesturesDestination(),
          HistoryDestination(),
        ],
        cursor: 1,
      );
      expect(state.current, const HistoryDestination());
    });
  });

  group('Re-expressed providers', () {
    test('currentViewProvider reflects GesturesDestination', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(currentViewProvider), AppView.gestures);
    });

    test('currentViewProvider reflects HistoryDestination', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(navProvider.notifier).go(const HistoryDestination());
      expect(container.read(currentViewProvider), AppView.history);
    });

    test('currentViewProvider reflects SettingsDestination', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(navProvider.notifier)
          .go(
            const SettingsDestination(SettingsSection.deviceSettings),
          );
      expect(container.read(currentViewProvider), AppView.settings);
    });

    test('currentSettingsSectionProvider returns section', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(navProvider.notifier)
          .go(
            const SettingsDestination(SettingsSection.appearance),
          );
      expect(
        container.read(currentSettingsSectionProvider),
        SettingsSection.appearance,
      );
    });

    test('deviceSettingsSectionProvider returns device from destination', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(navProvider.notifier)
          .go(
            const SettingsDestination(
              SettingsSection.deviceSettings,
              device: DeviceSettingsSection.touchpad,
            ),
          );
      expect(
        container.read(deviceSettingsSectionProvider),
        DeviceSettingsSection.touchpad,
      );
    });
  });

  group('Nav Spec', () {
    // Convenience helpers
    const gestures = GesturesDestination();
    const history = HistoryDestination();
    const settings = SettingsDestination(SettingsSection.deviceSettings);
    const settingsEffect = SettingsDestination(SettingsSection.effectSettings);
    const settingsKeyboard = SettingsDestination(
      SettingsSection.deviceSettings,
      device: DeviceSettingsSection.keyboard,
    );

    group('navTransition axis', () {
      test('within main shell (gestures ↔ history) is vertical', () {
        expect(navTransition(gestures, history).axis, NavAxis.vertical);
        expect(navTransition(history, gestures).axis, NavAxis.vertical);
      });

      test('crossing into settings shell is horizontal', () {
        expect(navTransition(gestures, settings).axis, NavAxis.horizontal);
        expect(navTransition(history, settings).axis, NavAxis.horizontal);
      });

      test('crossing out of settings shell is horizontal', () {
        expect(navTransition(settings, gestures).axis, NavAxis.horizontal);
        expect(navTransition(settings, history).axis, NavAxis.horizontal);
      });

      test('within settings shell (section switches) is vertical', () {
        expect(navTransition(settings, settingsEffect).axis, NavAxis.vertical);
        expect(navTransition(settingsEffect, settings).axis, NavAxis.vertical);
      });
    });

    group('navTransition sign symmetry', () {
      void assertSymmetric(AppDestination a, AppDestination b) {
        final ab = navTransition(a, b);
        final ba = navTransition(b, a);
        expect(
          ab.sign,
          -ba.sign,
          reason:
              'navTransition($a,$b).sign should equal '
              '-navTransition($b,$a).sign',
        );
      }

      test(
        'gestures → history is symmetric',
        () => assertSymmetric(gestures, history),
      );
      test(
        'gestures → settings is symmetric',
        () => assertSymmetric(gestures, settings),
      );
      test(
        'history → settings is symmetric',
        () => assertSymmetric(history, settings),
      );
      test(
        'settings(mouse) → settings(effect) is symmetric',
        () => assertSymmetric(settings, settingsEffect),
      );
      test(
        'settings(mouse) → settings(keyboard) is symmetric',
        () => assertSymmetric(settings, settingsKeyboard),
      );
    });

    group('navTransition direction within main shell', () {
      test('gestures→history has positive sign (lower in sidebar)', () {
        expect(navTransition(gestures, history).sign, 1.0);
      });

      test('history→gestures has negative sign (higher in sidebar)', () {
        expect(navTransition(history, gestures).sign, -1.0);
      });

      test('gestures→settings crosses shell → horizontal positive', () {
        expect(navTransition(gestures, settings).sign, 1.0);
      });

      test('settings→gestures crosses shell → horizontal negative', () {
        expect(navTransition(settings, gestures).sign, -1.0);
      });
    });

    group('navTransition within settings', () {
      test('mouse→keyboard has positive sign (keyboard is later in order)', () {
        expect(navTransition(settings, settingsKeyboard).sign, 1.0);
      });

      test('keyboard→mouse has negative sign', () {
        expect(navTransition(settingsKeyboard, settings).sign, -1.0);
      });

      test('settings sub-section amount is 0.15', () {
        expect(navTransition(settings, settingsKeyboard).amount, 0.15);
      });
    });

    group('navTransition null handling', () {
      test('from=null returns default spec', () {
        final spec = navTransition(null, gestures);
        expect(spec.axis, NavAxis.vertical);
        expect(spec.sign, 1.0);
      });

      test('to=null returns default spec', () {
        final spec = navTransition(gestures, null);
        expect(spec.axis, NavAxis.vertical);
        expect(spec.sign, 1.0);
      });
    });
  });

  group('Gesture selection history', () {
    const mouse = DeviceType.mouse;

    test('selecting a gesture adds a history entry', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      _controller(container)
        ..go(const GesturesDestination(open: (device: mouse, index: 0)))
        ..go(const GesturesDestination(open: (device: mouse, index: 1)));

      expect(_state(container).history.length, 3);
      expect(
        _state(container).current,
        const GesturesDestination(open: (device: mouse, index: 1)),
      );
    });

    test('back returns to the previously selected gesture', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      _controller(container)
        ..go(const GesturesDestination(open: (device: mouse, index: 0)))
        ..go(const GesturesDestination(open: (device: mouse, index: 1)))
        ..back();

      expect(
        _state(container).current,
        const GesturesDestination(open: (device: mouse, index: 0)),
      );
    });

    test('forward re-selects the gesture after going back', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      _controller(container)
        ..go(const GesturesDestination(open: (device: mouse, index: 0)))
        ..go(const GesturesDestination(open: (device: mouse, index: 1)))
        ..back()
        ..forward();

      expect(
        _state(container).current,
        const GesturesDestination(open: (device: mouse, index: 1)),
      );
    });

    test('selecting the same gesture twice is a no-op', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      _controller(container)
        ..go(const GesturesDestination(open: (device: mouse, index: 0)))
        ..go(const GesturesDestination(open: (device: mouse, index: 0)));

      expect(_state(container).history.length, 2);
    });

    test(
      'clearGestureSelection via replace:true does not add a history entry',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        _controller(container)
          ..go(const GesturesDestination(open: (device: mouse, index: 0)))
          ..go(const GesturesDestination(), replace: true);

        expect(_state(container).history.length, 2);
        expect(_state(container).cursor, 1);
        expect(_state(container).current, const GesturesDestination());
      },
    );
  });

  group('NavController.onGestureDeleted', () {
    const mouse = DeviceType.mouse;
    const keyboard = DeviceType.keyboard;

    test('clears open when pointing at the deleted index', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      _controller(container).go(
        const GesturesDestination(
          open: (device: mouse, index: 2),
          filter: mouse,
        ),
      );
      _controller(container).onGestureDeleted(mouse, 2);

      expect(
        _state(container).current,
        const GesturesDestination(filter: mouse),
      );
    });

    test('decrements open.index when it was above the deleted index', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      _controller(
        container,
      ).go(const GesturesDestination(open: (device: mouse, index: 5)));
      _controller(container).onGestureDeleted(mouse, 2);

      expect(
        _state(container).current,
        const GesturesDestination(open: (device: mouse, index: 4)),
      );
    });

    test('leaves open.index unchanged when it was below the deleted index', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      _controller(
        container,
      ).go(const GesturesDestination(open: (device: mouse, index: 1)));
      _controller(container).onGestureDeleted(mouse, 3);

      expect(
        _state(container).current,
        const GesturesDestination(open: (device: mouse, index: 1)),
      );
    });

    test('does not affect a different device', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      _controller(
        container,
      ).go(const GesturesDestination(open: (device: keyboard, index: 2)));
      _controller(container).onGestureDeleted(mouse, 2);

      expect(
        _state(container).current,
        const GesturesDestination(open: (device: keyboard, index: 2)),
      );
    });

    test('patches all matching entries across the full history', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      _controller(container)
        ..go(const GesturesDestination(open: (device: mouse, index: 0)))
        ..go(const GesturesDestination(open: (device: mouse, index: 3)))
        ..go(const GesturesDestination(open: (device: mouse, index: 5)));

      _controller(container).onGestureDeleted(mouse, 2);

      final history = _state(container).history;
      // index 0 is below deleted — unchanged
      expect(
        history[1],
        const GesturesDestination(open: (device: mouse, index: 0)),
      );
      // index 3 is above deleted — decremented
      expect(
        history[2],
        const GesturesDestination(open: (device: mouse, index: 2)),
      );
      // index 5 is above deleted — decremented
      expect(
        history[3],
        const GesturesDestination(open: (device: mouse, index: 4)),
      );
    });

    test('cursor stays at the same position after the patch', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      _controller(container)
        ..go(const GesturesDestination(open: (device: mouse, index: 3)))
        ..go(const GesturesDestination(open: (device: mouse, index: 5)))
        ..back(); // cursor now at 1

      _controller(container).onGestureDeleted(mouse, 2);

      expect(_state(container).cursor, 1);
      expect(
        _state(container).current,
        const GesturesDestination(open: (device: mouse, index: 2)), // 3→2
      );
    });

    test(
      'leaves HistoryDestination and SettingsDestination entries untouched',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        _controller(container)
          ..go(const HistoryDestination())
          ..go(
            const SettingsDestination(SettingsSection.deviceSettings),
          );

        _controller(container).onGestureDeleted(mouse, 0);

        expect(_state(container).history[1], const HistoryDestination());
        expect(
          _state(container).history[2],
          const SettingsDestination(SettingsSection.deviceSettings),
        );
      },
    );

    test('is a no-op when no history entry references that device+index', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      _controller(
        container,
      ).go(const GesturesDestination(open: (device: mouse, index: 1)));
      final before = _state(container).history.toList();

      _controller(container).onGestureDeleted(keyboard, 1);

      expect(_state(container).history, before);
    });
  });
}
