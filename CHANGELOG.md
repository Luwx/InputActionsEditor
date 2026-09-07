# Changelog

## [0.9.0] - 2026-08-30

### Actions

- Action groups: nest actions under a "First match" group that runs the first nested action whose conditions match
- Copy, paste, and rename actions, including pasting from the empty area of the action list
- Input delay: milliseconds to wait between each item in an input sequence
- Command mode in text input: run a shell command and type its standard output
- Function editor rewritten for multi-line editing, and multi-line functions now parse correctly
- Toggle an action on and off with a switch

### Triggers and conditions

- Lock pointer: freeze the on-screen cursor while a motion gesture runs
- Speed settings for mouse gestures
- Point condition editor with a draggable preview, pixel readout, and the matching area shaded
- Numeric validation across trigger fields and device property chips

### Groups

- First-class native trigger groups, with nested groups in the gesture list
- Gestures inherit trigger fields and conditions from enclosing groups, each shown with the group it came from

### Files

- Rolling backups of the config on every save
- Gestures are more spaced out in the saved YAML, and comment handling is more robust

### Interface

- Collapse the sidebar by dragging the divider
- More keyboard shortcuts for the menu commands, and for walking through the interface
- Color scheme preview in the picker field and new colors
- Undone and redone actions are highlighted

### Fixes

- A half-typed key sequence is no longer wiped
- The text field is cleared when switching between key sequence and text input
- Clicks outside a popup no longer reach the widget underneath
- The grabbing cursor is used while a row is dragged

## [0.6.0] - 2026-07-26

- Add a KDE Wayland application menu with file, gesture, and appearance actions
- Add menu icons, shortcuts, checkboxes, radio options, and section headings
- Add an About dialog with project links

## [0.5.2] - 2026-06-22

- Marquee selection: drag in the gesture list to rubber-band select multiple gestures
- Bulk edit: apply changes to several selected gestures at once
- Fix: crash when a window is closed while editing gestures
- Fix: background blur is applied again
- Fix: condition popover no longer stays open after window detection finishes
- Fix: text fields now refresh when reverting a field to its saved value

## [0.5.0] - 2026-06-10

- New action types: replace text, activate window
- Import/Export YAML from and to the clipboard
- Gesture selection is now persisted across app restarts
- Better UX for group gesture handling
- Various bugfixes
