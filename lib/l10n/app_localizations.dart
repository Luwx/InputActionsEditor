import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Input Actions'**
  String get appName;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get appSubtitle;

  /// No description provided for @actionLoad.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get actionLoad;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionDiscardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get actionDiscardChanges;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get actionDuplicate;

  /// No description provided for @actionEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get actionEnable;

  /// No description provided for @actionDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get actionDisable;

  /// No description provided for @actionReset.
  ///
  /// In en, this message translates to:
  /// **'reset'**
  String get actionReset;

  /// No description provided for @actionAddRule.
  ///
  /// In en, this message translates to:
  /// **'Add Rule'**
  String get actionAddRule;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @actionRecord.
  ///
  /// In en, this message translates to:
  /// **'Record stroke...'**
  String get actionRecord;

  /// No description provided for @actionRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get actionRecording;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @sidebarDeviceGesturesGroup.
  ///
  /// In en, this message translates to:
  /// **'Device Gestures'**
  String get sidebarDeviceGesturesGroup;

  /// No description provided for @sidebarAllDevices.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get sidebarAllDevices;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsDeviceSettings.
  ///
  /// In en, this message translates to:
  /// **'Device Settings'**
  String get settingsDeviceSettings;

  /// No description provided for @settingsEffect.
  ///
  /// In en, this message translates to:
  /// **'Effect'**
  String get settingsEffect;

  /// No description provided for @settingsInterface.
  ///
  /// In en, this message translates to:
  /// **'Interface'**
  String get settingsInterface;

  /// No description provided for @settingsDeviceRules.
  ///
  /// In en, this message translates to:
  /// **'Device Rules'**
  String get settingsDeviceRules;

  /// No description provided for @deviceTypeMouse.
  ///
  /// In en, this message translates to:
  /// **'Mouse'**
  String get deviceTypeMouse;

  /// No description provided for @deviceTypePointer.
  ///
  /// In en, this message translates to:
  /// **'Pointer'**
  String get deviceTypePointer;

  /// No description provided for @deviceTypeKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Keyboard'**
  String get deviceTypeKeyboard;

  /// No description provided for @deviceTypeTouchpad.
  ///
  /// In en, this message translates to:
  /// **'Touchpad'**
  String get deviceTypeTouchpad;

  /// No description provided for @deviceTypeTouchscreen.
  ///
  /// In en, this message translates to:
  /// **'Touchscreen'**
  String get deviceTypeTouchscreen;

  /// No description provided for @deviceNounMouse.
  ///
  /// In en, this message translates to:
  /// **'mouse'**
  String get deviceNounMouse;

  /// No description provided for @deviceNounPointer.
  ///
  /// In en, this message translates to:
  /// **'pointer'**
  String get deviceNounPointer;

  /// No description provided for @deviceNounKeyboard.
  ///
  /// In en, this message translates to:
  /// **'keyboard'**
  String get deviceNounKeyboard;

  /// No description provided for @deviceNounTouchpad.
  ///
  /// In en, this message translates to:
  /// **'touchpad'**
  String get deviceNounTouchpad;

  /// No description provided for @deviceNounTouchscreen.
  ///
  /// In en, this message translates to:
  /// **'touchscreen'**
  String get deviceNounTouchscreen;

  /// No description provided for @gestureTypeStroke.
  ///
  /// In en, this message translates to:
  /// **'Stroke'**
  String get gestureTypeStroke;

  /// No description provided for @gestureTypeSwipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe'**
  String get gestureTypeSwipe;

  /// No description provided for @gestureTypeCircle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get gestureTypeCircle;

  /// No description provided for @gestureTypePress.
  ///
  /// In en, this message translates to:
  /// **'Press'**
  String get gestureTypePress;

  /// No description provided for @gestureTypeWheel.
  ///
  /// In en, this message translates to:
  /// **'Wheel'**
  String get gestureTypeWheel;

  /// No description provided for @gestureTypeShortcut.
  ///
  /// In en, this message translates to:
  /// **'Shortcut'**
  String get gestureTypeShortcut;

  /// No description provided for @gestureTypeHover.
  ///
  /// In en, this message translates to:
  /// **'Hover'**
  String get gestureTypeHover;

  /// No description provided for @gestureTypePinch.
  ///
  /// In en, this message translates to:
  /// **'Pinch'**
  String get gestureTypePinch;

  /// No description provided for @gestureTypeRotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get gestureTypeRotate;

  /// No description provided for @gestureTypeTap.
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get gestureTypeTap;

  /// No description provided for @gestureTypeClick.
  ///
  /// In en, this message translates to:
  /// **'Click'**
  String get gestureTypeClick;

  /// No description provided for @gestureTypeHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get gestureTypeHold;

  /// No description provided for @gestureTypeGeneric.
  ///
  /// In en, this message translates to:
  /// **'Gesture'**
  String get gestureTypeGeneric;

  /// No description provided for @swipeDirectionLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get swipeDirectionLeft;

  /// No description provided for @swipeDirectionRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get swipeDirectionRight;

  /// No description provided for @swipeDirectionUp.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get swipeDirectionUp;

  /// No description provided for @swipeDirectionDown.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get swipeDirectionDown;

  /// No description provided for @swipeDirectionLeftUp.
  ///
  /// In en, this message translates to:
  /// **'Left-Up'**
  String get swipeDirectionLeftUp;

  /// No description provided for @swipeDirectionLeftDown.
  ///
  /// In en, this message translates to:
  /// **'Left-Down'**
  String get swipeDirectionLeftDown;

  /// No description provided for @swipeDirectionRightUp.
  ///
  /// In en, this message translates to:
  /// **'Right-Up'**
  String get swipeDirectionRightUp;

  /// No description provided for @swipeDirectionRightDown.
  ///
  /// In en, this message translates to:
  /// **'Right-Down'**
  String get swipeDirectionRightDown;

  /// No description provided for @swipeDirectionLeftRight.
  ///
  /// In en, this message translates to:
  /// **'Left / Right'**
  String get swipeDirectionLeftRight;

  /// No description provided for @swipeDirectionUpDown.
  ///
  /// In en, this message translates to:
  /// **'Up / Down'**
  String get swipeDirectionUpDown;

  /// No description provided for @swipeDirectionLeftUpRightDown.
  ///
  /// In en, this message translates to:
  /// **'Left-Up / Right-Down'**
  String get swipeDirectionLeftUpRightDown;

  /// No description provided for @swipeDirectionLeftDownRightUp.
  ///
  /// In en, this message translates to:
  /// **'Left-Down / Right-Up'**
  String get swipeDirectionLeftDownRightUp;

  /// No description provided for @swipeDirectionAny.
  ///
  /// In en, this message translates to:
  /// **'Any direction'**
  String get swipeDirectionAny;

  /// No description provided for @wheelDirectionAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get wheelDirectionAny;

  /// No description provided for @wheelDirectionUp.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get wheelDirectionUp;

  /// No description provided for @wheelDirectionDown.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get wheelDirectionDown;

  /// No description provided for @wheelDirectionLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get wheelDirectionLeft;

  /// No description provided for @wheelDirectionRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get wheelDirectionRight;

  /// No description provided for @wheelDirectionUpDown.
  ///
  /// In en, this message translates to:
  /// **'Up/Down'**
  String get wheelDirectionUpDown;

  /// No description provided for @wheelDirectionLeftRight.
  ///
  /// In en, this message translates to:
  /// **'Left/Right'**
  String get wheelDirectionLeftRight;

  /// No description provided for @directionAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get directionAny;

  /// No description provided for @directionClockwise.
  ///
  /// In en, this message translates to:
  /// **'Clockwise'**
  String get directionClockwise;

  /// No description provided for @directionCounterclockwise.
  ///
  /// In en, this message translates to:
  /// **'Counterclockwise'**
  String get directionCounterclockwise;

  /// No description provided for @pinchDirectionAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get pinchDirectionAny;

  /// No description provided for @pinchDirectionIn.
  ///
  /// In en, this message translates to:
  /// **'In (pinch)'**
  String get pinchDirectionIn;

  /// No description provided for @pinchDirectionOut.
  ///
  /// In en, this message translates to:
  /// **'Out (spread)'**
  String get pinchDirectionOut;

  /// No description provided for @mouseButtonLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get mouseButtonLeft;

  /// No description provided for @mouseButtonMiddle.
  ///
  /// In en, this message translates to:
  /// **'Middle'**
  String get mouseButtonMiddle;

  /// No description provided for @mouseButtonRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get mouseButtonRight;

  /// No description provided for @mouseButtonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get mouseButtonBack;

  /// No description provided for @mouseButtonForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get mouseButtonForward;

  /// No description provided for @mouseButtonTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get mouseButtonTask;

  /// No description provided for @mouseButtonSide.
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get mouseButtonSide;

  /// No description provided for @mouseButtonExtra.
  ///
  /// In en, this message translates to:
  /// **'Extra'**
  String get mouseButtonExtra;

  /// No description provided for @operatorIs.
  ///
  /// In en, this message translates to:
  /// **'is'**
  String get operatorIs;

  /// No description provided for @operatorIsNot.
  ///
  /// In en, this message translates to:
  /// **'is not'**
  String get operatorIsNot;

  /// No description provided for @operatorGreaterThan.
  ///
  /// In en, this message translates to:
  /// **'greater than'**
  String get operatorGreaterThan;

  /// No description provided for @operatorGreaterOrEqual.
  ///
  /// In en, this message translates to:
  /// **'greater or equal'**
  String get operatorGreaterOrEqual;

  /// No description provided for @operatorLessThan.
  ///
  /// In en, this message translates to:
  /// **'less than'**
  String get operatorLessThan;

  /// No description provided for @operatorLessOrEqual.
  ///
  /// In en, this message translates to:
  /// **'less or equal'**
  String get operatorLessOrEqual;

  /// No description provided for @operatorBetween.
  ///
  /// In en, this message translates to:
  /// **'between'**
  String get operatorBetween;

  /// No description provided for @operatorContains.
  ///
  /// In en, this message translates to:
  /// **'contains'**
  String get operatorContains;

  /// No description provided for @operatorMatches.
  ///
  /// In en, this message translates to:
  /// **'matches'**
  String get operatorMatches;

  /// No description provided for @operatorIsOneOf.
  ///
  /// In en, this message translates to:
  /// **'is one of'**
  String get operatorIsOneOf;

  /// No description provided for @varTypeBadgeString.
  ///
  /// In en, this message translates to:
  /// **'STR'**
  String get varTypeBadgeString;

  /// No description provided for @varTypeBadgeNumber.
  ///
  /// In en, this message translates to:
  /// **'NUM'**
  String get varTypeBadgeNumber;

  /// No description provided for @varTypeBadgeBool.
  ///
  /// In en, this message translates to:
  /// **'BOOL'**
  String get varTypeBadgeBool;

  /// No description provided for @varTypeBadgeFlags.
  ///
  /// In en, this message translates to:
  /// **'FLAGS'**
  String get varTypeBadgeFlags;

  /// No description provided for @varTypeBadgePoint.
  ///
  /// In en, this message translates to:
  /// **'POINT'**
  String get varTypeBadgePoint;

  /// No description provided for @varTypeBadgeEnum.
  ///
  /// In en, this message translates to:
  /// **'ENUM'**
  String get varTypeBadgeEnum;

  /// No description provided for @varTypeBadgeTime.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get varTypeBadgeTime;

  /// No description provided for @varTypeNameString.
  ///
  /// In en, this message translates to:
  /// **'string'**
  String get varTypeNameString;

  /// No description provided for @varTypeNameNumber.
  ///
  /// In en, this message translates to:
  /// **'number'**
  String get varTypeNameNumber;

  /// No description provided for @varTypeNameBool.
  ///
  /// In en, this message translates to:
  /// **'boolean'**
  String get varTypeNameBool;

  /// No description provided for @varTypeNameFlags.
  ///
  /// In en, this message translates to:
  /// **'flags'**
  String get varTypeNameFlags;

  /// No description provided for @varTypeNamePoint.
  ///
  /// In en, this message translates to:
  /// **'point'**
  String get varTypeNamePoint;

  /// No description provided for @varTypeNameEnum.
  ///
  /// In en, this message translates to:
  /// **'enum'**
  String get varTypeNameEnum;

  /// No description provided for @varTypeNameTime.
  ///
  /// In en, this message translates to:
  /// **'time (ms)'**
  String get varTypeNameTime;

  /// No description provided for @inputModeKeySequence.
  ///
  /// In en, this message translates to:
  /// **'Key sequence'**
  String get inputModeKeySequence;

  /// No description provided for @inputModeTextInput.
  ///
  /// In en, this message translates to:
  /// **'Text input'**
  String get inputModeTextInput;

  /// No description provided for @inputModeButtonSequence.
  ///
  /// In en, this message translates to:
  /// **'Button sequence'**
  String get inputModeButtonSequence;

  /// No description provided for @inputModeMoveBy.
  ///
  /// In en, this message translates to:
  /// **'Move by'**
  String get inputModeMoveBy;

  /// No description provided for @inputModeMoveByDelta.
  ///
  /// In en, this message translates to:
  /// **'Move by delta'**
  String get inputModeMoveByDelta;

  /// No description provided for @inputModeMoveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to'**
  String get inputModeMoveTo;

  /// No description provided for @inputModeScrollWheel.
  ///
  /// In en, this message translates to:
  /// **'Scroll wheel'**
  String get inputModeScrollWheel;

  /// No description provided for @inputModeGeneric.
  ///
  /// In en, this message translates to:
  /// **'Input'**
  String get inputModeGeneric;

  /// No description provided for @tokenLabelText.
  ///
  /// In en, this message translates to:
  /// **'Text: {val}'**
  String tokenLabelText(String val);

  /// No description provided for @tokenLabelMoveBy.
  ///
  /// In en, this message translates to:
  /// **'Move by {v1}, {v2}'**
  String tokenLabelMoveBy(String v1, String v2);

  /// No description provided for @tokenLabelMoveByDelta.
  ///
  /// In en, this message translates to:
  /// **'Move by delta'**
  String get tokenLabelMoveByDelta;

  /// No description provided for @tokenLabelMoveByDeltaParam.
  ///
  /// In en, this message translates to:
  /// **'Move by delta {v1}'**
  String tokenLabelMoveByDeltaParam(String v1);

  /// No description provided for @tokenLabelMoveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to {v1}, {v2}'**
  String tokenLabelMoveTo(String v1, String v2);

  /// No description provided for @tokenLabelWheel.
  ///
  /// In en, this message translates to:
  /// **'Wheel {v1}, {v2}'**
  String tokenLabelWheel(String v1, String v2);

  /// No description provided for @gestureSelectPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a gesture to edit'**
  String get gestureSelectPrompt;

  /// No description provided for @gestureCopyYamlSuccess.
  ///
  /// In en, this message translates to:
  /// **'Gesture YAML copied.'**
  String get gestureCopyYamlSuccess;

  /// No description provided for @gestureMenuEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get gestureMenuEnable;

  /// No description provided for @gestureMenuDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get gestureMenuDisable;

  /// No description provided for @gestureMenuResetToDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset To Defaults'**
  String get gestureMenuResetToDefaults;

  /// No description provided for @gestureMenuDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get gestureMenuDuplicate;

  /// No description provided for @gestureMenuCopyYaml.
  ///
  /// In en, this message translates to:
  /// **'Copy YAML'**
  String get gestureMenuCopyYaml;

  /// No description provided for @gestureMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get gestureMenuDelete;

  /// No description provided for @multiSelectCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 gesture selected} other{{count} gestures selected}}'**
  String multiSelectCount(int count);

  /// No description provided for @conflictsTitle.
  ///
  /// In en, this message translates to:
  /// **'Conflicts'**
  String get conflictsTitle;

  /// No description provided for @conflictCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 conflict} other{{count} conflicts}}'**
  String conflictCount(int count);

  /// No description provided for @triggerConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Trigger Config'**
  String get triggerConfigTitle;

  /// No description provided for @triggerOtherOptions.
  ///
  /// In en, this message translates to:
  /// **'Other Options'**
  String get triggerOtherOptions;

  /// No description provided for @triggerConditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trigger Conditions'**
  String get triggerConditionsTitle;

  /// No description provided for @triggerConditionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Conditions that must ALL be true for this gesture to activate.\n\nExamples:\n  \$window_class == firefox\n      → only fires inside Firefox\n  \$window_class == konsole\n      → only fires inside the terminal\n  \$window_id == \$window_under_id\n      → cursor is over the focused window\n  \$pointer_position_screen_percentage_x >= 0.95\n      → cursor is at the right screen edge\n  \$fingers == 3\n      → exactly 3 fingers on touchpad\n\nMultiple rows are ANDed together.\nUse an \"any\" group inside for OR logic.'**
  String get triggerConditionsTooltip;

  /// No description provided for @triggerEndConditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'End conditions'**
  String get triggerEndConditionsTitle;

  /// No description provided for @triggerEndConditionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Checked at the moment the gesture ends.\n\n  • Met → gesture ends normally; on:end actions fire.\n  • Not met → gesture is cancelled; on:cancel actions fire instead.\n\nUse this to require a minimum movement before the gesture \"counts\".\nExample: \$distance >= 100 cancels the gesture if the finger did not travel at least 100 px, so a short accidental movement is ignored.'**
  String get triggerEndConditionsTooltip;

  /// No description provided for @triggerConditionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No conditions set. Add a condition or group to specify when this gesture should trigger.'**
  String get triggerConditionsEmpty;

  /// No description provided for @triggerFieldIdLabel.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get triggerFieldIdLabel;

  /// No description provided for @triggerFieldIdTooltip.
  ///
  /// In en, this message translates to:
  /// **'Unique name for this trigger.\n\nWhen set, the daemon exposes variables:\n  \$<id>_active  - true while running\n  \$last_trigger - equals this id after it fires\n\nUse these in other gestures\' conditions to chain or block behaviors.\nExample: id: swipe_right, then another gesture can check \$last_trigger == swipe_right.'**
  String get triggerFieldIdTooltip;

  /// No description provided for @triggerFieldIdHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. my_trigger'**
  String get triggerFieldIdHint;

  /// No description provided for @triggerFieldThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Threshold'**
  String get triggerFieldThresholdLabel;

  /// No description provided for @triggerFieldThresholdTooltip.
  ///
  /// In en, this message translates to:
  /// **'Minimum accumulated input before the gesture is recognized as started.\n\n\"Progress\" units by gesture type:\n  Swipe / stroke  - pixels of movement\n  Wheel           - scroll ticks\n  Pinch           - scale factor (e.g. 0.1 = 10%)\n  Rotate / circle - degrees\n  Press           - not applicable (press has no movement phase)\n\nBelow the threshold the input is passed through to the application normally.\nUse a range like 50-200 to require at least 50 and cancel if it exceeds 200.\n\nNote: this is distinct from the per-action Threshold, which gates a specific action after recognition.'**
  String get triggerFieldThresholdTooltip;

  /// No description provided for @triggerFieldThresholdHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 100 or 50-200'**
  String get triggerFieldThresholdHint;

  /// No description provided for @triggerFieldResumeTimeoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Resume timeout'**
  String get triggerFieldResumeTimeoutLabel;

  /// No description provided for @triggerFieldResumeTimeoutTooltip.
  ///
  /// In en, this message translates to:
  /// **'If another identical gesture starts within this many milliseconds after this one ends, it resumes as a continuation rather than starting fresh.\n\nUseful for:\n  • Multi-tap sequences where a brief pause between taps should not reset state\n  • Repeated wheel scrolls that accumulate delta across short gaps\n\n0 = disabled (every gesture starts from scratch).'**
  String get triggerFieldResumeTimeoutTooltip;

  /// No description provided for @triggerFieldResumeTimeoutHint.
  ///
  /// In en, this message translates to:
  /// **'0 = disabled'**
  String get triggerFieldResumeTimeoutHint;

  /// No description provided for @triggerFieldAcceleratedLabel.
  ///
  /// In en, this message translates to:
  /// **'Accelerated'**
  String get triggerFieldAcceleratedLabel;

  /// No description provided for @triggerFieldAcceleratedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Scale delta values by pointer acceleration, matching how fast the cursor moves on screen.\n\nEnable for actions that should feel proportional to movement speed (e.g. move_by_delta input actions).\nDisable for uniform responses regardless of speed (e.g. a fixed key press per scroll tick).'**
  String get triggerFieldAcceleratedTooltip;

  /// No description provided for @triggerFieldBlockEventsLabel.
  ///
  /// In en, this message translates to:
  /// **'Block events'**
  String get triggerFieldBlockEventsLabel;

  /// No description provided for @triggerFieldBlockEventsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Suppress the raw input events used by this gesture so they do not reach other applications.\n\nExample: holding right-click to draw a stroke gesture prevents the context menu from opening.\n\nDisable if the application should also receive those events while the gesture is active.'**
  String get triggerFieldBlockEventsTooltip;

  /// No description provided for @triggerFieldClearModifiersLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear modifiers'**
  String get triggerFieldClearModifiersLabel;

  /// No description provided for @triggerFieldClearModifiersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Release all held modifier keys (Ctrl, Shift, Alt, Super) when this gesture begins.\n\nAutomatically enabled when an input: action is present, to prevent those modifiers from leaking into the replayed key events.\nDisable only if you intentionally need the modifiers to remain held during the action.'**
  String get triggerFieldClearModifiersTooltip;

  /// No description provided for @triggerFieldSetLastTriggerLabel.
  ///
  /// In en, this message translates to:
  /// **'Set last trigger'**
  String get triggerFieldSetLastTriggerLabel;

  /// No description provided for @triggerFieldSetLastTriggerTooltip.
  ///
  /// In en, this message translates to:
  /// **'Update \$last_trigger to this trigger\'s ID when it executes.\n\nUse \$last_trigger in other gestures\' conditions to build sequences - e.g. a second gesture that only fires if a specific gesture ran first.\n\nDisable for utility triggers you do not want to pollute the \$last_trigger state.'**
  String get triggerFieldSetLastTriggerTooltip;

  /// No description provided for @sectionPress.
  ///
  /// In en, this message translates to:
  /// **'Press'**
  String get sectionPress;

  /// No description provided for @pressInstantLabel.
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get pressInstantLabel;

  /// No description provided for @pressInstantTooltip.
  ///
  /// In en, this message translates to:
  /// **'Start the trigger immediately when the button is pressed. By default there is a short delay to allow swipe gestures and normal clicks to work. Enabling this prevents normal clicks on that button.'**
  String get pressInstantTooltip;

  /// No description provided for @sectionCircleDirectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Circle Direction'**
  String get sectionCircleDirectionLabel;

  /// No description provided for @sectionCircleDirectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Direction fingers must move in a circle. \"Any\" matches both clockwise and counterclockwise.'**
  String get sectionCircleDirectionTooltip;

  /// No description provided for @sectionPinchDirectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Pinch Direction'**
  String get sectionPinchDirectionLabel;

  /// No description provided for @sectionPinchDirectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'\"In\" brings fingers together, \"Out\" spreads them apart. \"Any\" matches both. Note: libinput may sometimes misidentify pinch gestures as swipes.'**
  String get sectionPinchDirectionTooltip;

  /// No description provided for @sectionRotateDirectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Rotate Direction'**
  String get sectionRotateDirectionLabel;

  /// No description provided for @sectionRotateDirectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Direction of the two-finger rotation. \"Any\" matches both clockwise and counterclockwise.'**
  String get sectionRotateDirectionTooltip;

  /// No description provided for @sectionWheelDirectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Wheel Direction'**
  String get sectionWheelDirectionLabel;

  /// No description provided for @sectionWheelDirectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Scroll wheel direction to match. \"Up/Down\" and \"Left/Right\" handle bidirectional scrolling.'**
  String get sectionWheelDirectionTooltip;

  /// No description provided for @sectionModifierLabel.
  ///
  /// In en, this message translates to:
  /// **'Modifier'**
  String get sectionModifierLabel;

  /// No description provided for @sectionModifierTooltip.
  ///
  /// In en, this message translates to:
  /// **'Keyboard modifier keys that must be held. Click to cycle: (none) → Left → Right → (none).'**
  String get sectionModifierTooltip;

  /// No description provided for @sectionKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get sectionKeyLabel;

  /// No description provided for @sectionKeyTooltip.
  ///
  /// In en, this message translates to:
  /// **'The main key of the shortcut. Combined with any selected modifier keys above.'**
  String get sectionKeyTooltip;

  /// No description provided for @sectionFingersLabel.
  ///
  /// In en, this message translates to:
  /// **'Fingers'**
  String get sectionFingersLabel;

  /// No description provided for @sectionFingersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Number of fingers required on the input device. \"Any\" matches regardless of how many fingers are used.'**
  String get sectionFingersTooltip;

  /// No description provided for @sectionFingersAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get sectionFingersAny;

  /// No description provided for @sectionMouseButtonsLabel.
  ///
  /// In en, this message translates to:
  /// **'Buttons'**
  String get sectionMouseButtonsLabel;

  /// No description provided for @sectionMouseButtonsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mouse button(s) that must be held during the gesture.'**
  String get sectionMouseButtonsTooltip;

  /// No description provided for @strokesLabel.
  ///
  /// In en, this message translates to:
  /// **'Strokes'**
  String get strokesLabel;

  /// No description provided for @strokesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pre-recorded shapes to match against. Draw a shape and the gesture activates when you repeat it with at least 70% similarity. Multiple strokes can all match the same gesture.'**
  String get strokesTooltip;

  /// No description provided for @strokesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No strokes recorded. Tap Record to add one.'**
  String get strokesEmpty;

  /// No description provided for @strokesRecord.
  ///
  /// In en, this message translates to:
  /// **'Record stroke...'**
  String get strokesRecord;

  /// No description provided for @strokesRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get strokesRecording;

  /// No description provided for @strokesRecordingFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recording failed'**
  String get strokesRecordingFailedTitle;

  /// No description provided for @strokesRecordingDaemonError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the Input Actions daemon.'**
  String get strokesRecordingDaemonError;

  /// No description provided for @resetGestureDefaultsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clears optional overrides and advanced settings while keeping the gesture type and its core identifying fields, such as direction, shortcut, fingers, or stroke pattern.'**
  String get resetGestureDefaultsTooltip;

  /// No description provided for @actionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actionsTitle;

  /// No description provided for @actionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No actions configured yet.'**
  String get actionsEmpty;

  /// No description provided for @actionTriggerOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Trigger on'**
  String get actionTriggerOnLabel;

  /// No description provided for @actionTriggerOnTooltip.
  ///
  /// In en, this message translates to:
  /// **'When during the gesture lifecycle this action fires.'**
  String get actionTriggerOnTooltip;

  /// No description provided for @actionIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get actionIntervalLabel;

  /// No description provided for @actionIntervalTooltip.
  ///
  /// In en, this message translates to:
  /// **'Controls how often the action repeats for continuous gestures (wheel, swipe update, etc).'**
  String get actionIntervalTooltip;

  /// No description provided for @actionThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Threshold'**
  String get actionThresholdLabel;

  /// No description provided for @actionThresholdTooltip.
  ///
  /// In en, this message translates to:
  /// **'Accumulated movement since the gesture began before this action fires. Same units as the trigger threshold.'**
  String get actionThresholdTooltip;

  /// No description provided for @actionLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get actionLimitLabel;

  /// No description provided for @actionLimitTooltip.
  ///
  /// In en, this message translates to:
  /// **'Maximum times this action can fire during a single gesture.'**
  String get actionLimitTooltip;

  /// No description provided for @actionConflictingLabel.
  ///
  /// In en, this message translates to:
  /// **'Conflicting'**
  String get actionConflictingLabel;

  /// No description provided for @actionConflictingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Whether this action participates in conflict resolution.'**
  String get actionConflictingTooltip;

  /// No description provided for @actionConditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Action Conditions'**
  String get actionConditionsTitle;

  /// No description provided for @actionConditionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Conditions checked just before this action executes. The gesture fires regardless; only this action is skipped if unmet.'**
  String get actionConditionsTooltip;

  /// No description provided for @actionChipOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get actionChipOn;

  /// No description provided for @actionChipInterval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get actionChipInterval;

  /// No description provided for @actionChipThreshold.
  ///
  /// In en, this message translates to:
  /// **'Threshold'**
  String get actionChipThreshold;

  /// No description provided for @actionChipLimit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get actionChipLimit;

  /// No description provided for @actionChipConflicting.
  ///
  /// In en, this message translates to:
  /// **'Conflicting'**
  String get actionChipConflicting;

  /// No description provided for @actionMetaCommandLabel.
  ///
  /// In en, this message translates to:
  /// **'Command'**
  String get actionMetaCommandLabel;

  /// No description provided for @actionMetaCommandSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Run a shell command'**
  String get actionMetaCommandSubtitle;

  /// No description provided for @actionMetaInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Input'**
  String get actionMetaInputLabel;

  /// No description provided for @actionMetaInputSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Simulate keyboard or mouse events'**
  String get actionMetaInputSubtitle;

  /// No description provided for @actionMetaPlasmaLabel.
  ///
  /// In en, this message translates to:
  /// **'Plasma shortcut'**
  String get actionMetaPlasmaLabel;

  /// No description provided for @actionMetaPlasmaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trigger a KDE global shortcut'**
  String get actionMetaPlasmaSubtitle;

  /// No description provided for @actionMetaSleepLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get actionMetaSleepLabel;

  /// No description provided for @actionMetaSleepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pause before continuing'**
  String get actionMetaSleepSubtitle;

  /// No description provided for @actionMetaRawLabel.
  ///
  /// In en, this message translates to:
  /// **'Raw YAML'**
  String get actionMetaRawLabel;

  /// No description provided for @actionMetaRawSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hand-authored unsupported action config'**
  String get actionMetaRawSubtitle;

  /// No description provided for @actionSummaryNoCommand.
  ///
  /// In en, this message translates to:
  /// **'No command'**
  String get actionSummaryNoCommand;

  /// No description provided for @actionSummaryNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get actionSummaryNotConfigured;

  /// No description provided for @actionSummaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get actionSummaryEmpty;

  /// No description provided for @actionSummaryNoInput.
  ///
  /// In en, this message translates to:
  /// **'No input'**
  String get actionSummaryNoInput;

  /// No description provided for @actionSummaryNoKeys.
  ///
  /// In en, this message translates to:
  /// **'No keys'**
  String get actionSummaryNoKeys;

  /// No description provided for @actionSummaryNoButtons.
  ///
  /// In en, this message translates to:
  /// **'No buttons'**
  String get actionSummaryNoButtons;

  /// No description provided for @actionCommandLabel.
  ///
  /// In en, this message translates to:
  /// **'Command'**
  String get actionCommandLabel;

  /// No description provided for @actionCommandHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. xdg-open ~'**
  String get actionCommandHint;

  /// No description provided for @actionCommandTooltip.
  ///
  /// In en, this message translates to:
  /// **'Shell command to run. Variables like \$window_class, \$window_pid are passed as environment variables.'**
  String get actionCommandTooltip;

  /// No description provided for @actionWaitForCompletionLabel.
  ///
  /// In en, this message translates to:
  /// **'Wait for completion'**
  String get actionWaitForCompletionLabel;

  /// No description provided for @actionWaitForCompletionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Wait up to 30 seconds for the command to exit before executing the next action in the sequence.'**
  String get actionWaitForCompletionTooltip;

  /// No description provided for @addGestureTitle.
  ///
  /// In en, this message translates to:
  /// **'Add gesture'**
  String get addGestureTitle;

  /// No description provided for @addGestureChooseDevice.
  ///
  /// In en, this message translates to:
  /// **'Choose the device you want to add a gesture for.'**
  String get addGestureChooseDevice;

  /// No description provided for @addGestureForDevice.
  ///
  /// In en, this message translates to:
  /// **'Add {device} gesture'**
  String addGestureForDevice(String device);

  /// No description provided for @addGestureSelectTemplate.
  ///
  /// In en, this message translates to:
  /// **'Select a gesture template for {device} input.'**
  String addGestureSelectTemplate(String device);

  /// No description provided for @templateStrokeLabel.
  ///
  /// In en, this message translates to:
  /// **'Stroke'**
  String get templateStrokeLabel;

  /// No description provided for @templateStrokeDescription.
  ///
  /// In en, this message translates to:
  /// **'Draw a freeform path with the mouse.'**
  String get templateStrokeDescription;

  /// No description provided for @templateSwipeMouseDescription.
  ///
  /// In en, this message translates to:
  /// **'Recognize directional mouse movement.'**
  String get templateSwipeMouseDescription;

  /// No description provided for @templateCircleMouseDescription.
  ///
  /// In en, this message translates to:
  /// **'Match circular movement in either direction.'**
  String get templateCircleMouseDescription;

  /// No description provided for @templatePressDescription.
  ///
  /// In en, this message translates to:
  /// **'Trigger from a button press or hold.'**
  String get templatePressDescription;

  /// No description provided for @templateWheelDescription.
  ///
  /// In en, this message translates to:
  /// **'Use scroll wheel direction as the trigger.'**
  String get templateWheelDescription;

  /// No description provided for @templateShortcutDescription.
  ///
  /// In en, this message translates to:
  /// **'Match a keyboard shortcut or key chord.'**
  String get templateShortcutDescription;

  /// No description provided for @templateHoverDescription.
  ///
  /// In en, this message translates to:
  /// **'Trigger while the pointer hovers over a region.'**
  String get templateHoverDescription;

  /// No description provided for @templateSwipeTouchpadDescription.
  ///
  /// In en, this message translates to:
  /// **'Track directional touchpad swipes.'**
  String get templateSwipeTouchpadDescription;

  /// No description provided for @templatePinchDescription.
  ///
  /// In en, this message translates to:
  /// **'Detect pinch-in and pinch-out gestures.'**
  String get templatePinchDescription;

  /// No description provided for @templateRotateDescription.
  ///
  /// In en, this message translates to:
  /// **'Recognize two-finger rotation.'**
  String get templateRotateDescription;

  /// No description provided for @templateCircleTouchpadDescription.
  ///
  /// In en, this message translates to:
  /// **'Track circular movement on the pad.'**
  String get templateCircleTouchpadDescription;

  /// No description provided for @templateTapDescription.
  ///
  /// In en, this message translates to:
  /// **'Trigger on a touchpad tap.'**
  String get templateTapDescription;

  /// No description provided for @templateClickDescription.
  ///
  /// In en, this message translates to:
  /// **'Use a physical or integrated click.'**
  String get templateClickDescription;

  /// No description provided for @templateHoldDescription.
  ///
  /// In en, this message translates to:
  /// **'Trigger after holding fingers still.'**
  String get templateHoldDescription;

  /// No description provided for @templateStrokeTouchpadDescription.
  ///
  /// In en, this message translates to:
  /// **'Draw a freeform path on the touchpad.'**
  String get templateStrokeTouchpadDescription;

  /// No description provided for @templateSwipeTouchscreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Track directional touchscreen swipes.'**
  String get templateSwipeTouchscreenDescription;

  /// No description provided for @templateCircleTouchscreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Match circular movement on the screen.'**
  String get templateCircleTouchscreenDescription;

  /// No description provided for @templateStrokeTouchscreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Draw a freeform path on the touchscreen.'**
  String get templateStrokeTouchscreenDescription;

  /// No description provided for @renameDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename gesture'**
  String get renameDialogTitle;

  /// No description provided for @renameDialogLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get renameDialogLabel;

  /// No description provided for @renameDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Gesture name'**
  String get renameDialogHint;

  /// No description provided for @fieldResetButton.
  ///
  /// In en, this message translates to:
  /// **'reset'**
  String get fieldResetButton;

  /// No description provided for @fieldDefaultHint.
  ///
  /// In en, this message translates to:
  /// **'default'**
  String get fieldDefaultHint;

  /// No description provided for @devicePropertiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Properties'**
  String get devicePropertiesTitle;

  /// No description provided for @devicePropertiesDescriptionBefore.
  ///
  /// In en, this message translates to:
  /// **'Applies to all devices of this type. Use '**
  String get devicePropertiesDescriptionBefore;

  /// No description provided for @devicePropertiesDescriptionAfter.
  ///
  /// In en, this message translates to:
  /// **' to override per device.'**
  String get devicePropertiesDescriptionAfter;

  /// No description provided for @deviceRulesLinkText.
  ///
  /// In en, this message translates to:
  /// **'Device Rules'**
  String get deviceRulesLinkText;

  /// No description provided for @devicePropertiesNoPointer.
  ///
  /// In en, this message translates to:
  /// **'No configurable properties for Pointer devices.'**
  String get devicePropertiesNoPointer;

  /// No description provided for @devicePropertiesIgnoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get devicePropertiesIgnoreLabel;

  /// No description provided for @devicePropertiesIgnoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ignore all events from this device type.'**
  String get devicePropertiesIgnoreSubtitle;

  /// No description provided for @devicePropertiesGrabLabel.
  ///
  /// In en, this message translates to:
  /// **'Grab'**
  String get devicePropertiesGrabLabel;

  /// No description provided for @devicePropertiesGrabSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Grab the evdev device (standalone only).'**
  String get devicePropertiesGrabSubtitle;

  /// No description provided for @devicePropertiesMotionTimeoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Motion Timeout'**
  String get devicePropertiesMotionTimeoutLabel;

  /// No description provided for @devicePropertiesMotionTimeoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Time (ms) during which a motion trigger must be performed.'**
  String get devicePropertiesMotionTimeoutSubtitle;

  /// No description provided for @devicePropertiesMotionThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Motion Threshold'**
  String get devicePropertiesMotionThresholdLabel;

  /// No description provided for @devicePropertiesMotionThresholdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For accurately determining the direction of swipe triggers.'**
  String get devicePropertiesMotionThresholdSubtitle;

  /// No description provided for @devicePropertiesPressTimeoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Press Timeout'**
  String get devicePropertiesPressTimeoutLabel;

  /// No description provided for @devicePropertiesPressTimeoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Time (ms) before press triggers are started.'**
  String get devicePropertiesPressTimeoutSubtitle;

  /// No description provided for @devicePropertiesSwipeAngleToleranceLabel.
  ///
  /// In en, this message translates to:
  /// **'Swipe Angle Tolerance'**
  String get devicePropertiesSwipeAngleToleranceLabel;

  /// No description provided for @devicePropertiesSwipeAngleToleranceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Angle tolerance (0–45) for cardinal swipe directions.'**
  String get devicePropertiesSwipeAngleToleranceSubtitle;

  /// No description provided for @devicePropertiesUnblockButtonsOnTimeoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Unblock Buttons On Timeout'**
  String get devicePropertiesUnblockButtonsOnTimeoutLabel;

  /// No description provided for @devicePropertiesUnblockButtonsOnTimeoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Press blocked buttons immediately on motion timeout.'**
  String get devicePropertiesUnblockButtonsOnTimeoutSubtitle;

  /// No description provided for @devicePropertiesButtonpadLabel.
  ///
  /// In en, this message translates to:
  /// **'Buttonpad'**
  String get devicePropertiesButtonpadLabel;

  /// No description provided for @devicePropertiesButtonpadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Whether the touchpad is a buttonpad (detected automatically).'**
  String get devicePropertiesButtonpadSubtitle;

  /// No description provided for @devicePropertiesClickTimeoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Click Timeout'**
  String get devicePropertiesClickTimeoutLabel;

  /// No description provided for @devicePropertiesClickTimeoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Time (ms) during which a click trigger must be performed.'**
  String get devicePropertiesClickTimeoutSubtitle;

  /// No description provided for @devicePropertiesHandleEvdevEventsLabel.
  ///
  /// In en, this message translates to:
  /// **'Handle Evdev Events'**
  String get devicePropertiesHandleEvdevEventsLabel;

  /// No description provided for @devicePropertiesHandleEvdevEventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Disable if there are issues with evdev event processing.'**
  String get devicePropertiesHandleEvdevEventsSubtitle;

  /// No description provided for @devicePropertiesMotionThreshold1FingerLabel.
  ///
  /// In en, this message translates to:
  /// **'Motion Threshold (1-finger)'**
  String get devicePropertiesMotionThreshold1FingerLabel;

  /// No description provided for @devicePropertiesMotionThreshold1FingerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For accurately determining 1-finger swipe direction.'**
  String get devicePropertiesMotionThreshold1FingerSubtitle;

  /// No description provided for @devicePropertiesMotionThreshold2FingerLabel.
  ///
  /// In en, this message translates to:
  /// **'Motion Threshold (2-finger)'**
  String get devicePropertiesMotionThreshold2FingerLabel;

  /// No description provided for @devicePropertiesMotionThreshold2FingerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For accurately determining 2-finger swipe direction.'**
  String get devicePropertiesMotionThreshold2FingerSubtitle;

  /// No description provided for @devicePropertiesMotionThreshold3FingerLabel.
  ///
  /// In en, this message translates to:
  /// **'Motion Threshold (3+ finger)'**
  String get devicePropertiesMotionThreshold3FingerLabel;

  /// No description provided for @devicePropertiesMotionThreshold3FingerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For accurately determining 3- and 4-finger swipe direction.'**
  String get devicePropertiesMotionThreshold3FingerSubtitle;

  /// No description provided for @devicePropertiesPressureFingerLabel.
  ///
  /// In en, this message translates to:
  /// **'Pressure: Finger'**
  String get devicePropertiesPressureFingerLabel;

  /// No description provided for @devicePropertiesPressureFingerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Minimum pressure to consider a touch point as a finger.'**
  String get devicePropertiesPressureFingerSubtitle;

  /// No description provided for @devicePropertiesPressureThumbLabel.
  ///
  /// In en, this message translates to:
  /// **'Pressure: Thumb'**
  String get devicePropertiesPressureThumbLabel;

  /// No description provided for @devicePropertiesPressureThumbSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Minimum pressure to consider a touch point as a thumb.'**
  String get devicePropertiesPressureThumbSubtitle;

  /// No description provided for @devicePropertiesPressurePalmLabel.
  ///
  /// In en, this message translates to:
  /// **'Pressure: Palm'**
  String get devicePropertiesPressurePalmLabel;

  /// No description provided for @devicePropertiesPressurePalmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Maximum pressure before a touch point is ignored as palm.'**
  String get devicePropertiesPressurePalmSubtitle;

  /// No description provided for @devicePropertiesMotionThresholdTouchscreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For accurately determining swipe direction (mm).'**
  String get devicePropertiesMotionThresholdTouchscreenSubtitle;

  /// No description provided for @speedSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Speed Settings'**
  String get speedSettingsTitle;

  /// No description provided for @speedSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Controls how motion trigger speed is determined.'**
  String get speedSettingsDescription;

  /// No description provided for @speedEventsLabel.
  ///
  /// In en, this message translates to:
  /// **'Input Events to Sample'**
  String get speedEventsLabel;

  /// No description provided for @speedEventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How many input events to sample to determine speed. No triggers start until all events are sampled.'**
  String get speedEventsSubtitle;

  /// No description provided for @speedSwipeThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Swipe Threshold'**
  String get speedSwipeThresholdLabel;

  /// No description provided for @speedSwipeThresholdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delta threshold to consider a swipe as \"fast\".'**
  String get speedSwipeThresholdSubtitle;

  /// No description provided for @speedPinchInThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Pinch-In Threshold'**
  String get speedPinchInThresholdLabel;

  /// No description provided for @speedPinchInThresholdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delta threshold to consider a pinch-in as \"fast\".'**
  String get speedPinchInThresholdSubtitle;

  /// No description provided for @speedPinchOutThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Pinch-Out Threshold'**
  String get speedPinchOutThresholdLabel;

  /// No description provided for @speedPinchOutThresholdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delta threshold to consider a pinch-out as \"fast\".'**
  String get speedPinchOutThresholdSubtitle;

  /// No description provided for @speedRotateThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Rotate Threshold'**
  String get speedRotateThresholdLabel;

  /// No description provided for @speedRotateThresholdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delta threshold to consider a rotation as \"fast\".'**
  String get speedRotateThresholdSubtitle;

  /// No description provided for @deviceRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Rules'**
  String get deviceRulesTitle;

  /// No description provided for @deviceRulesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rule · evaluated bottom to top} other{{count} rules · evaluated bottom to top}}'**
  String deviceRulesSubtitle(int count);

  /// No description provided for @deviceRulesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No device rules.'**
  String get deviceRulesEmpty;

  /// No description provided for @deviceRulesEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Rules apply device properties to matching devices.\nEvaluated from bottom to top.'**
  String get deviceRulesEmptyDescription;

  /// No description provided for @deviceRuleHeader.
  ///
  /// In en, this message translates to:
  /// **'Rule {number}'**
  String deviceRuleHeader(int number);

  /// No description provided for @deviceConditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Conditions'**
  String get deviceConditionsTitle;

  /// No description provided for @deviceRulePropertiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get deviceRulePropertiesTitle;

  /// No description provided for @deviceRulePropertiesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No properties set. Add conditions and properties to configure device behavior.'**
  String get deviceRulePropertiesEmpty;

  /// No description provided for @deviceRuleNoConditions.
  ///
  /// In en, this message translates to:
  /// **'No conditions (applies to all devices)'**
  String get deviceRuleNoConditions;

  /// No description provided for @deviceRuleConditionsSet.
  ///
  /// In en, this message translates to:
  /// **'Conditions set'**
  String get deviceRuleConditionsSet;

  /// No description provided for @effectSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Effect Settings'**
  String get effectSettingsTitle;

  /// No description provided for @effectSettingsGeneralTitle.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get effectSettingsGeneralTitle;

  /// No description provided for @effectSettingsAutoReloadLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto Reload'**
  String get effectSettingsAutoReloadLabel;

  /// No description provided for @effectSettingsAutoReloadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically reload the configuration when the file changes.'**
  String get effectSettingsAutoReloadSubtitle;

  /// No description provided for @effectSettingsExternalVarAccessLabel.
  ///
  /// In en, this message translates to:
  /// **'External Variable Access'**
  String get effectSettingsExternalVarAccessLabel;

  /// No description provided for @effectSettingsExternalVarAccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow dumping variables by running \"inputactions variables list\".'**
  String get effectSettingsExternalVarAccessSubtitle;

  /// No description provided for @effectSettingsNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get effectSettingsNotificationsTitle;

  /// No description provided for @effectSettingsConfigErrorLabel.
  ///
  /// In en, this message translates to:
  /// **'Config Error Notification'**
  String get effectSettingsConfigErrorLabel;

  /// No description provided for @effectSettingsConfigErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send a desktop notification when the configuration fails to load.'**
  String get effectSettingsConfigErrorSubtitle;

  /// No description provided for @effectSettingsEmergencyComboTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Combination'**
  String get effectSettingsEmergencyComboTitle;

  /// No description provided for @effectSettingsEmergencyComboKeysLabel.
  ///
  /// In en, this message translates to:
  /// **'Keys (comma-separated scancodes)'**
  String get effectSettingsEmergencyComboKeysLabel;

  /// No description provided for @effectSettingsEmergencyComboKeysHint.
  ///
  /// In en, this message translates to:
  /// **'backspace, enter, space'**
  String get effectSettingsEmergencyComboKeysHint;

  /// No description provided for @effectSettingsEmergencyComboDescription.
  ///
  /// In en, this message translates to:
  /// **'Keyboard keys that can be pressed in any order and held for 2 seconds to suspend InputActions until the next config reload. Set to empty to disable.'**
  String get effectSettingsEmergencyComboDescription;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @appearanceMinimizeToTrayLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimize to tray'**
  String get appearanceMinimizeToTrayLabel;

  /// No description provided for @appearanceMinimizeToTraySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep running in background when closed'**
  String get appearanceMinimizeToTraySubtitle;

  /// No description provided for @appearanceTransparentSidebarLabel.
  ///
  /// In en, this message translates to:
  /// **'Transparent sidebar'**
  String get appearanceTransparentSidebarLabel;

  /// No description provided for @appearanceThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get appearanceThemeLabel;

  /// No description provided for @appearanceColorThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Color theme'**
  String get appearanceColorThemeLabel;

  /// No description provided for @appearanceThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceThemeDark;

  /// No description provided for @appearanceThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceThemeLight;

  /// No description provided for @appearanceThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get appearanceThemeSystem;

  /// No description provided for @appearanceColorThemeKde.
  ///
  /// In en, this message translates to:
  /// **'KDE System'**
  String get appearanceColorThemeKde;

  /// No description provided for @appearanceColorThemeNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get appearanceColorThemeNeutral;

  /// No description provided for @appearanceColorThemeZinc.
  ///
  /// In en, this message translates to:
  /// **'Zinc'**
  String get appearanceColorThemeZinc;

  /// No description provided for @appearanceColorThemeSlate.
  ///
  /// In en, this message translates to:
  /// **'Slate'**
  String get appearanceColorThemeSlate;

  /// No description provided for @appearanceColorThemeBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get appearanceColorThemeBlue;

  /// No description provided for @appearanceColorThemeGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get appearanceColorThemeGreen;

  /// No description provided for @appearanceColorThemeOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get appearanceColorThemeOrange;

  /// No description provided for @appearanceColorThemeRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get appearanceColorThemeRed;

  /// No description provided for @appearanceColorThemeRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get appearanceColorThemeRose;

  /// No description provided for @appearanceColorThemeViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get appearanceColorThemeViolet;

  /// No description provided for @appearanceColorThemeYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get appearanceColorThemeYellow;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Recognition History'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recognition events yet.'**
  String get historyEmpty;

  /// No description provided for @historyEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Perform a gesture while the daemon is running.'**
  String get historyEmptyHint;

  /// No description provided for @historyPathPreview.
  ///
  /// In en, this message translates to:
  /// **'Path preview'**
  String get historyPathPreview;

  /// No description provided for @historyClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get historyClose;

  /// No description provided for @deviceDescriptionMouse.
  ///
  /// In en, this message translates to:
  /// **'Buttons, wheel movement, strokes, and pointer motion.'**
  String get deviceDescriptionMouse;

  /// No description provided for @deviceDescriptionKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts and key combinations.'**
  String get deviceDescriptionKeyboard;

  /// No description provided for @deviceDescriptionPointer.
  ///
  /// In en, this message translates to:
  /// **'Pointer hover gestures.'**
  String get deviceDescriptionPointer;

  /// No description provided for @deviceDescriptionTouchpad.
  ///
  /// In en, this message translates to:
  /// **'Multi-finger gestures on a trackpad surface.'**
  String get deviceDescriptionTouchpad;

  /// No description provided for @deviceDescriptionTouchscreen.
  ///
  /// In en, this message translates to:
  /// **'Direct touch gestures on a screen.'**
  String get deviceDescriptionTouchscreen;

  /// No description provided for @templateMouseStrokeDescription.
  ///
  /// In en, this message translates to:
  /// **'Draw a freeform path with the mouse.'**
  String get templateMouseStrokeDescription;

  /// No description provided for @templateMouseSwipeDescription.
  ///
  /// In en, this message translates to:
  /// **'Recognize directional mouse movement.'**
  String get templateMouseSwipeDescription;

  /// No description provided for @templateMouseCircleDescription.
  ///
  /// In en, this message translates to:
  /// **'Match circular movement in either direction.'**
  String get templateMouseCircleDescription;

  /// No description provided for @templateMousePressDescription.
  ///
  /// In en, this message translates to:
  /// **'Trigger from a button press or hold.'**
  String get templateMousePressDescription;

  /// No description provided for @templateMouseWheelDescription.
  ///
  /// In en, this message translates to:
  /// **'Use scroll wheel direction as the trigger.'**
  String get templateMouseWheelDescription;

  /// No description provided for @templateKeyboardShortcutDescription.
  ///
  /// In en, this message translates to:
  /// **'Match a keyboard shortcut or key chord.'**
  String get templateKeyboardShortcutDescription;

  /// No description provided for @templatePointerHoverDescription.
  ///
  /// In en, this message translates to:
  /// **'Trigger while the pointer hovers over a region.'**
  String get templatePointerHoverDescription;

  /// No description provided for @templateTouchpadSwipeDescription.
  ///
  /// In en, this message translates to:
  /// **'Track directional touchpad swipes.'**
  String get templateTouchpadSwipeDescription;

  /// No description provided for @templateTouchpadPinchDescription.
  ///
  /// In en, this message translates to:
  /// **'Detect pinch-in and pinch-out gestures.'**
  String get templateTouchpadPinchDescription;

  /// No description provided for @templateTouchpadRotateDescription.
  ///
  /// In en, this message translates to:
  /// **'Recognize two-finger rotation.'**
  String get templateTouchpadRotateDescription;

  /// No description provided for @templateTouchpadCircleDescription.
  ///
  /// In en, this message translates to:
  /// **'Track circular movement on the pad.'**
  String get templateTouchpadCircleDescription;

  /// No description provided for @templateTouchpadTapDescription.
  ///
  /// In en, this message translates to:
  /// **'Trigger on a touchpad tap.'**
  String get templateTouchpadTapDescription;

  /// No description provided for @templateTouchpadClickDescription.
  ///
  /// In en, this message translates to:
  /// **'Use a physical or integrated click.'**
  String get templateTouchpadClickDescription;

  /// No description provided for @templateTouchpadHoldDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep fingers down for a press-and-hold trigger.'**
  String get templateTouchpadHoldDescription;

  /// No description provided for @templateTouchpadStrokeDescription.
  ///
  /// In en, this message translates to:
  /// **'Draw a freeform path on the touchpad surface.'**
  String get templateTouchpadStrokeDescription;

  /// No description provided for @templateTouchscreenSwipeDescription.
  ///
  /// In en, this message translates to:
  /// **'Recognize directional finger swipes.'**
  String get templateTouchscreenSwipeDescription;

  /// No description provided for @templateTouchscreenPinchDescription.
  ///
  /// In en, this message translates to:
  /// **'Detect zoom-style pinch gestures.'**
  String get templateTouchscreenPinchDescription;

  /// No description provided for @templateTouchscreenRotateDescription.
  ///
  /// In en, this message translates to:
  /// **'Track multi-finger rotation on the screen.'**
  String get templateTouchscreenRotateDescription;

  /// No description provided for @templateTouchscreenCircleDescription.
  ///
  /// In en, this message translates to:
  /// **'Match a circular finger motion.'**
  String get templateTouchscreenCircleDescription;

  /// No description provided for @templateTouchscreenTapDescription.
  ///
  /// In en, this message translates to:
  /// **'Trigger on a screen tap.'**
  String get templateTouchscreenTapDescription;

  /// No description provided for @templateTouchscreenHoldDescription.
  ///
  /// In en, this message translates to:
  /// **'Use a long press gesture.'**
  String get templateTouchscreenHoldDescription;

  /// No description provided for @templateTouchscreenStrokeDescription.
  ///
  /// In en, this message translates to:
  /// **'Draw a freeform path on the screen.'**
  String get templateTouchscreenStrokeDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
