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

  /// No description provided for @actionNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get actionNew;

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

  /// No description provided for @actionSaveAs.
  ///
  /// In en, this message translates to:
  /// **'Save As'**
  String get actionSaveAs;

  /// No description provided for @actionDiscardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get actionDiscardChanges;

  /// No description provided for @actionLoadFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Load from clipboard'**
  String get actionLoadFromClipboard;

  /// No description provided for @actionCopyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get actionCopyToClipboard;

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

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @actionRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get actionRedo;

  /// No description provided for @actionExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get actionExit;

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

  /// Button that opens the bulk editor for the multi-selected gestures.
  ///
  /// In en, this message translates to:
  /// **'Bulk edit'**
  String get bulkEdit;

  /// Title of the bulk-edit page header.
  ///
  /// In en, this message translates to:
  /// **'Bulk edit'**
  String get bulkEditTitle;

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

  /// No description provided for @menuFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get menuFile;

  /// No description provided for @menuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get menuEdit;

  /// No description provided for @menuGesture.
  ///
  /// In en, this message translates to:
  /// **'Gesture'**
  String get menuGesture;

  /// No description provided for @menuOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get menuOpenSettings;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get menuAbout;

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

  /// No description provided for @configSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Config saved.'**
  String get configSaveSuccess;

  /// No description provided for @configCopyToClipboardSuccess.
  ///
  /// In en, this message translates to:
  /// **'Config copied to clipboard.'**
  String get configCopyToClipboardSuccess;

  /// No description provided for @configLoadClipboardError.
  ///
  /// In en, this message translates to:
  /// **'Could not parse clipboard YAML.'**
  String get configLoadClipboardError;

  /// No description provided for @configLoadClipboardDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get configLoadClipboardDetailsButton;

  /// No description provided for @configLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your configuration'**
  String get configLoadFailedTitle;

  /// No description provided for @configIssuesTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 condition couldn\'t be read} other{{count} conditions couldn\'t be read}}'**
  String configIssuesTitle(int count);

  /// No description provided for @configIssuesDescription.
  ///
  /// In en, this message translates to:
  /// **'They\'re shown read-only. Saving will overwrite them.'**
  String get configIssuesDescription;

  /// No description provided for @configIssuesDialogBody.
  ///
  /// In en, this message translates to:
  /// **'The editor couldn\'t understand these conditions and shows them read-only. If you save, they\'ll be written back in the form below, losing whatever the file originally said. Fix them in a text editor first.'**
  String get configIssuesDialogBody;

  /// No description provided for @configIssuesUnnamedGesture.
  ///
  /// In en, this message translates to:
  /// **'Unnamed gesture'**
  String get configIssuesUnnamedGesture;

  /// No description provided for @gestureGroupUnnamed.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get gestureGroupUnnamed;

  /// Muted note under a trigger field whose value comes from an ancestor group.
  ///
  /// In en, this message translates to:
  /// **'Inherited from {group}: {value}'**
  String inheritedFieldFrom(String group, String value);

  /// Warning under a trigger field that both the gesture and an ancestor group set.
  ///
  /// In en, this message translates to:
  /// **'Also set by {group}. The daemon does not resolve this: it merges the group\'s value in without checking, and which one wins is undefined.'**
  String inheritedFieldConflict(String group);

  /// Title of the panel editing properties every gesture in a group inherits.
  ///
  /// In en, this message translates to:
  /// **'Shared properties'**
  String get groupSettingsTitle;

  /// No description provided for @groupSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Applies to 1 gesture} other{Applies to {count} gestures}}'**
  String groupSettingsSubtitle(int count);

  /// Explains group property inheritance and the daemon's lack of override support.
  ///
  /// In en, this message translates to:
  /// **'Every gesture in this group inherits these. A gesture that sets the same property does not override it, the result is undefined.'**
  String get groupSettingsDescription;

  /// No description provided for @configIssuesDeviceRule.
  ///
  /// In en, this message translates to:
  /// **'Device rules'**
  String get configIssuesDeviceRule;

  /// No description provided for @configIssuesLine.
  ///
  /// In en, this message translates to:
  /// **'line {number}'**
  String configIssuesLine(int number);

  /// No description provided for @configIssuesSourceConditions.
  ///
  /// In en, this message translates to:
  /// **'conditions'**
  String get configIssuesSourceConditions;

  /// No description provided for @configIssuesSourceEndConditions.
  ///
  /// In en, this message translates to:
  /// **'end conditions'**
  String get configIssuesSourceEndConditions;

  /// No description provided for @configIssuesSourceActionConditions.
  ///
  /// In en, this message translates to:
  /// **'action conditions'**
  String get configIssuesSourceActionConditions;

  /// No description provided for @configIssuesSourceDeviceRule.
  ///
  /// In en, this message translates to:
  /// **'device rule'**
  String get configIssuesSourceDeviceRule;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get actionDetails;

  /// No description provided for @dialogClipboardLoadTitle.
  ///
  /// In en, this message translates to:
  /// **'Load from Clipboard'**
  String get dialogClipboardLoadTitle;

  /// No description provided for @dialogClipboardLoadBody.
  ///
  /// In en, this message translates to:
  /// **'How would you like to load the clipboard config?'**
  String get dialogClipboardLoadBody;

  /// No description provided for @dialogClipboardLoadActionNew.
  ///
  /// In en, this message translates to:
  /// **'New config'**
  String get dialogClipboardLoadActionNew;

  /// No description provided for @dialogClipboardLoadActionMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get dialogClipboardLoadActionMerge;

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

  /// No description provided for @triggerEndConditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'End conditions'**
  String get triggerEndConditionsTitle;

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

  /// No description provided for @triggerFieldBlockEventsLabel.
  ///
  /// In en, this message translates to:
  /// **'Block events'**
  String get triggerFieldBlockEventsLabel;

  /// No description provided for @triggerFieldClearModifiersLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear modifiers'**
  String get triggerFieldClearModifiersLabel;

  /// No description provided for @triggerFieldSetLastTriggerLabel.
  ///
  /// In en, this message translates to:
  /// **'Set last trigger'**
  String get triggerFieldSetLastTriggerLabel;

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

  /// No description provided for @strokesInstructionsHeader.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get strokesInstructionsHeader;

  /// No description provided for @strokesMouseStep1.
  ///
  /// In en, this message translates to:
  /// **'Press Record'**
  String get strokesMouseStep1;

  /// No description provided for @strokesMouseStep2.
  ///
  /// In en, this message translates to:
  /// **'Draw the stroke'**
  String get strokesMouseStep2;

  /// No description provided for @strokesMouseStep3WaitPart.
  ///
  /// In en, this message translates to:
  /// **'Wait'**
  String get strokesMouseStep3WaitPart;

  /// No description provided for @strokesMouseStep3Suffix.
  ///
  /// In en, this message translates to:
  /// **' a moment after stopping'**
  String get strokesMouseStep3Suffix;

  /// No description provided for @strokesTouchpadStep1.
  ///
  /// In en, this message translates to:
  /// **'Press Record'**
  String get strokesTouchpadStep1;

  /// No description provided for @strokesTouchpadStep2Prefix.
  ///
  /// In en, this message translates to:
  /// **'Draw a stroke on the touchpad, then '**
  String get strokesTouchpadStep2Prefix;

  /// No description provided for @strokesTouchpadStep2WaitPart.
  ///
  /// In en, this message translates to:
  /// **'wait'**
  String get strokesTouchpadStep2WaitPart;

  /// No description provided for @strokesTouchscreenStep1.
  ///
  /// In en, this message translates to:
  /// **'Press Record'**
  String get strokesTouchscreenStep1;

  /// No description provided for @strokesTouchscreenStep2Prefix.
  ///
  /// In en, this message translates to:
  /// **'Draw a stroke on the screen, then '**
  String get strokesTouchscreenStep2Prefix;

  /// No description provided for @strokesTouchscreenStep2WaitPart.
  ///
  /// In en, this message translates to:
  /// **'wait'**
  String get strokesTouchscreenStep2WaitPart;

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

  /// No description provided for @actionTriggerOnDefaultOption.
  ///
  /// In en, this message translates to:
  /// **'end (default)'**
  String get actionTriggerOnDefaultOption;

  /// No description provided for @actionIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get actionIntervalLabel;

  /// No description provided for @actionThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Threshold'**
  String get actionThresholdLabel;

  /// No description provided for @actionLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get actionLimitLabel;

  /// No description provided for @actionConflictingLabel.
  ///
  /// In en, this message translates to:
  /// **'Conflicting'**
  String get actionConflictingLabel;

  /// No description provided for @actionConditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Action Conditions'**
  String get actionConditionsTitle;

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

  /// No description provided for @actionMetaActivateWindowLabel.
  ///
  /// In en, this message translates to:
  /// **'Activate window'**
  String get actionMetaActivateWindowLabel;

  /// No description provided for @actionMetaActivateWindowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Focus a window by ID'**
  String get actionMetaActivateWindowSubtitle;

  /// No description provided for @actionMetaReplaceTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Replace text'**
  String get actionMetaReplaceTextLabel;

  /// No description provided for @actionMetaReplaceTextSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replace text near the cursor using regex rules'**
  String get actionMetaReplaceTextSubtitle;

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

  /// No description provided for @actionMetaFunctionLabel.
  ///
  /// In en, this message translates to:
  /// **'Function'**
  String get actionMetaFunctionLabel;

  /// No description provided for @actionMetaFunctionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Run a JavaScript function'**
  String get actionMetaFunctionSubtitle;

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

  /// No description provided for @actionActivateWindowLabel.
  ///
  /// In en, this message translates to:
  /// **'Window ID'**
  String get actionActivateWindowLabel;

  /// No description provided for @actionActivateWindowHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. \$initial_window_under_pointer_id'**
  String get actionActivateWindowHint;

  /// No description provided for @actionActivateWindowTooltip.
  ///
  /// In en, this message translates to:
  /// **'Window ID to activate. A plain value is treated as a literal window ID. An exact \$name value is resolved through Input Actions\' Value parser if the variable is registered when the config is loaded; the variable\'s value is read when the action runs. This is not string interpolation, so \$name text is treated as one literal string and will not combine a variable with text.'**
  String get actionActivateWindowTooltip;

  /// No description provided for @actionActivateWindowVariablePickerTooltip.
  ///
  /// In en, this message translates to:
  /// **'Choose a window ID variable'**
  String get actionActivateWindowVariablePickerTooltip;

  /// No description provided for @actionReplaceTextRulesLabel.
  ///
  /// In en, this message translates to:
  /// **'Replacement rules'**
  String get actionReplaceTextRulesLabel;

  /// No description provided for @actionReplaceTextRulesHelp.
  ///
  /// In en, this message translates to:
  /// **'Rules are checked in order. The first regex matching the surrounding text at the cursor is used.'**
  String get actionReplaceTextRulesHelp;

  /// No description provided for @actionReplaceTextAddRule.
  ///
  /// In en, this message translates to:
  /// **'Add rule'**
  String get actionReplaceTextAddRule;

  /// No description provided for @actionReplaceTextRuleLabel.
  ///
  /// In en, this message translates to:
  /// **'Rule {index}'**
  String actionReplaceTextRuleLabel(int index);

  /// No description provided for @actionReplaceTextRegexLabel.
  ///
  /// In en, this message translates to:
  /// **'Regex'**
  String get actionReplaceTextRegexLabel;

  /// No description provided for @actionReplaceTextRegexHint.
  ///
  /// In en, this message translates to:
  /// **':calc(.*)'**
  String get actionReplaceTextRegexHint;

  /// No description provided for @actionReplaceTextReplacementLabel.
  ///
  /// In en, this message translates to:
  /// **'Replacement'**
  String get actionReplaceTextReplacementLabel;

  /// No description provided for @actionReplaceTextTextMode.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get actionReplaceTextTextMode;

  /// No description provided for @actionReplaceTextCommandMode.
  ///
  /// In en, this message translates to:
  /// **'Command'**
  String get actionReplaceTextCommandMode;

  /// No description provided for @actionReplaceTextTextHint.
  ///
  /// In en, this message translates to:
  /// **'example@example.com'**
  String get actionReplaceTextTextHint;

  /// No description provided for @actionReplaceTextCommandHint.
  ///
  /// In en, this message translates to:
  /// **'printf \"\$(qalc -t \"\$match_1\")\"'**
  String get actionReplaceTextCommandHint;

  /// No description provided for @actionReplaceTextRuleSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rule: {regex}} other{{count} rules: {regex}}}'**
  String actionReplaceTextRuleSummary(int count, String regex);

  /// No description provided for @actionReplaceTextFallbackSummary.
  ///
  /// In en, this message translates to:
  /// **'replace text'**
  String get actionReplaceTextFallbackSummary;

  /// No description provided for @valueStringRuntimeVariableHelp.
  ///
  /// In en, this message translates to:
  /// **'Use a literal ID or exactly \$name. Unknown variables are not blocked, but they must exist in Input Actions when the config is loaded.'**
  String get valueStringRuntimeVariableHelp;

  /// No description provided for @tooltip_actionActivateWindow_bodyPrefix.
  ///
  /// In en, this message translates to:
  /// **'Use exactly '**
  String get tooltip_actionActivateWindow_bodyPrefix;

  /// No description provided for @tooltip_actionActivateWindow_bodySuffix.
  ///
  /// In en, this message translates to:
  /// **' to focus the window stored in the respective runtime variable.'**
  String get tooltip_actionActivateWindow_bodySuffix;

  /// No description provided for @tooltip_actionActivateWindow_sectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Variable'**
  String get tooltip_actionActivateWindow_sectionLabel;

  /// No description provided for @tooltip_actionActivateWindow_literalExLabel.
  ///
  /// In en, this message translates to:
  /// **'literal window ID'**
  String get tooltip_actionActivateWindow_literalExLabel;

  /// No description provided for @tooltip_actionActivateWindow_variableExLabel.
  ///
  /// In en, this message translates to:
  /// **'window under the pointer when the gesture started'**
  String get tooltip_actionActivateWindow_variableExLabel;

  /// No description provided for @tooltip_actionActivateWindow_unknownNote.
  ///
  /// In en, this message translates to:
  /// **'Unknown variables are allowed, but only registered variables resolve at config load.'**
  String get tooltip_actionActivateWindow_unknownNote;

  /// No description provided for @tooltip_actionActivateWindow_noInterpolationPrefix.
  ///
  /// In en, this message translates to:
  /// **'No interpolation: '**
  String get tooltip_actionActivateWindow_noInterpolationPrefix;

  /// No description provided for @tooltip_actionActivateWindow_noInterpolationSuffix.
  ///
  /// In en, this message translates to:
  /// **' is one literal string.'**
  String get tooltip_actionActivateWindow_noInterpolationSuffix;

  /// No description provided for @tooltip_actionReplaceText_body.
  ///
  /// In en, this message translates to:
  /// **'Matches the surrounding text reported by the focused application and replaces the matched text at the cursor.'**
  String get tooltip_actionReplaceText_body;

  /// No description provided for @tooltip_actionReplaceText_sectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Examples'**
  String get tooltip_actionReplaceText_sectionLabel;

  /// No description provided for @tooltip_actionReplaceText_literalExCode.
  ///
  /// In en, this message translates to:
  /// **':email  ->  example@example.com'**
  String get tooltip_actionReplaceText_literalExCode;

  /// No description provided for @tooltip_actionReplaceText_literalExLabel.
  ///
  /// In en, this message translates to:
  /// **'simple literal replacement'**
  String get tooltip_actionReplaceText_literalExLabel;

  /// No description provided for @tooltip_actionReplaceText_commandExCode.
  ///
  /// In en, this message translates to:
  /// **':calc 2+2  ->  command uses \$match_1'**
  String get tooltip_actionReplaceText_commandExCode;

  /// No description provided for @tooltip_actionReplaceText_commandExLabel.
  ///
  /// In en, this message translates to:
  /// **'compute replacement from the first capture'**
  String get tooltip_actionReplaceText_commandExLabel;

  /// No description provided for @tooltip_actionReplaceText_matchNote.
  ///
  /// In en, this message translates to:
  /// **'Capture groups are exposed to command values as \$match_0, \$match_1, and so on.'**
  String get tooltip_actionReplaceText_matchNote;

  /// No description provided for @tooltip_actionReplaceText_cursorNote.
  ///
  /// In en, this message translates to:
  /// **'A rule is eligible only when the regex match ends at the current cursor position.'**
  String get tooltip_actionReplaceText_cursorNote;

  /// No description provided for @tooltip_actionReplaceTextCommand_body.
  ///
  /// In en, this message translates to:
  /// **'Runs the command through /bin/sh -c and uses stdout as the replacement text.'**
  String get tooltip_actionReplaceTextCommand_body;

  /// No description provided for @tooltip_actionReplaceTextCommand_exampleLabel.
  ///
  /// In en, this message translates to:
  /// **'Example command'**
  String get tooltip_actionReplaceTextCommand_exampleLabel;

  /// No description provided for @tooltip_actionReplaceTextCommand_exampleCode.
  ///
  /// In en, this message translates to:
  /// **'printf \"\$(qalc -t \"\$match_1\")\"'**
  String get tooltip_actionReplaceTextCommand_exampleCode;

  /// No description provided for @tooltip_actionReplaceTextCommand_exampleDesc.
  ///
  /// In en, this message translates to:
  /// **'For a calculator rule, \$match_1 can be 2+2. qalc evaluates it and printf prints the result without adding its own newline.'**
  String get tooltip_actionReplaceTextCommand_exampleDesc;

  /// No description provided for @tooltip_actionReplaceTextCommand_variablesLabel.
  ///
  /// In en, this message translates to:
  /// **'Variables'**
  String get tooltip_actionReplaceTextCommand_variablesLabel;

  /// No description provided for @tooltip_actionReplaceTextCommand_match0.
  ///
  /// In en, this message translates to:
  /// **'\$match_0 is the whole regex match.'**
  String get tooltip_actionReplaceTextCommand_match0;

  /// No description provided for @tooltip_actionReplaceTextCommand_matchN.
  ///
  /// In en, this message translates to:
  /// **'\$match_1 through \$match_4 are capture groups. Missing captures are empty.'**
  String get tooltip_actionReplaceTextCommand_matchN;

  /// No description provided for @tooltip_actionReplaceTextCommand_envNote.
  ///
  /// In en, this message translates to:
  /// **'Referenced Input Actions variables are injected into the process environment, so shell syntax like \"\$match_1\" expands normally.'**
  String get tooltip_actionReplaceTextCommand_envNote;

  /// No description provided for @tooltip_actionReplaceTextCommand_stdoutNote.
  ///
  /// In en, this message translates to:
  /// **'Use tools like printf or command flags such as -n when you do not want a trailing newline.'**
  String get tooltip_actionReplaceTextCommand_stdoutNote;

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

  /// No description provided for @tooltip_actionConditions_body.
  ///
  /// In en, this message translates to:
  /// **'Evaluated just before this action runs. The gesture still fires; only this action is skipped when conditions fail.'**
  String get tooltip_actionConditions_body;

  /// No description provided for @tooltip_actionConditions_sectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Same gesture, different action per context'**
  String get tooltip_actionConditions_sectionLabel;

  /// No description provided for @tooltip_actionConditions_ex1Label.
  ///
  /// In en, this message translates to:
  /// **'Action 1 → Ctrl+T  (new tab)'**
  String get tooltip_actionConditions_ex1Label;

  /// No description provided for @tooltip_actionConditions_ex2Label.
  ///
  /// In en, this message translates to:
  /// **'Action 2 → Ctrl+N  (new file)'**
  String get tooltip_actionConditions_ex2Label;

  /// No description provided for @tooltip_actionTriggerOn_body.
  ///
  /// In en, this message translates to:
  /// **'When during the gesture lifecycle this action fires.'**
  String get tooltip_actionTriggerOn_body;

  /// No description provided for @tooltip_actionTriggerOn_lifecycleBegin.
  ///
  /// In en, this message translates to:
  /// **'immediately on recognition'**
  String get tooltip_actionTriggerOn_lifecycleBegin;

  /// No description provided for @tooltip_actionTriggerOn_lifecycleUpdate.
  ///
  /// In en, this message translates to:
  /// **'every input move while active'**
  String get tooltip_actionTriggerOn_lifecycleUpdate;

  /// No description provided for @tooltip_actionTriggerOn_lifecycleEnd.
  ///
  /// In en, this message translates to:
  /// **'gesture completes normally'**
  String get tooltip_actionTriggerOn_lifecycleEnd;

  /// No description provided for @tooltip_actionTriggerOn_lifecycleCancel.
  ///
  /// In en, this message translates to:
  /// **'gesture is aborted'**
  String get tooltip_actionTriggerOn_lifecycleCancel;

  /// No description provided for @tooltip_actionTriggerOn_lifecycleEndCancel.
  ///
  /// In en, this message translates to:
  /// **'on both end AND cancel'**
  String get tooltip_actionTriggerOn_lifecycleEndCancel;

  /// No description provided for @tooltip_actionTriggerOn_lifecycleTick.
  ///
  /// In en, this message translates to:
  /// **'at fixed time intervals while active'**
  String get tooltip_actionTriggerOn_lifecycleTick;

  /// No description provided for @tooltip_actionInterval_body.
  ///
  /// In en, this message translates to:
  /// **'How often the action repeats on update and tick events.'**
  String get tooltip_actionInterval_body;

  /// No description provided for @tooltip_actionInterval_unitEmptyKey.
  ///
  /// In en, this message translates to:
  /// **'(empty)'**
  String get tooltip_actionInterval_unitEmptyKey;

  /// No description provided for @tooltip_actionInterval_unitEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'every input event or tick'**
  String get tooltip_actionInterval_unitEmptyDesc;

  /// No description provided for @tooltip_actionInterval_unitPlusDesc.
  ///
  /// In en, this message translates to:
  /// **'only while delta is increasing'**
  String get tooltip_actionInterval_unitPlusDesc;

  /// No description provided for @tooltip_actionInterval_unitMinusDesc.
  ///
  /// In en, this message translates to:
  /// **'only while delta is decreasing'**
  String get tooltip_actionInterval_unitMinusDesc;

  /// No description provided for @tooltip_actionInterval_unitNDesc.
  ///
  /// In en, this message translates to:
  /// **'once per N units of accumulated delta'**
  String get tooltip_actionInterval_unitNDesc;

  /// No description provided for @tooltip_actionInterval_exLabel.
  ///
  /// In en, this message translates to:
  /// **'fires every 4 scroll ticks'**
  String get tooltip_actionInterval_exLabel;

  /// No description provided for @tooltip_actionThreshold_body.
  ///
  /// In en, this message translates to:
  /// **'Movement since gesture start before this action fires. Same units as the trigger threshold.'**
  String get tooltip_actionThreshold_body;

  /// No description provided for @tooltip_actionThreshold_sectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get tooltip_actionThreshold_sectionLabel;

  /// No description provided for @tooltip_actionThreshold_unitPinchScale.
  ///
  /// In en, this message translates to:
  /// **'scale factor  (0.1 = 10%)'**
  String get tooltip_actionThreshold_unitPinchScale;

  /// No description provided for @tooltip_actionThreshold_noteTrigger.
  ///
  /// In en, this message translates to:
  /// **'Unlike the trigger threshold, this gates only this action after the gesture is already active.'**
  String get tooltip_actionThreshold_noteTrigger;

  /// No description provided for @tooltip_actionThreshold_noteRange.
  ///
  /// In en, this message translates to:
  /// **'Use a range like 50-200 to fire only within that movement window.'**
  String get tooltip_actionThreshold_noteRange;

  /// No description provided for @tooltip_actionConflicting_body.
  ///
  /// In en, this message translates to:
  /// **'Whether this action holds back competing gestures.'**
  String get tooltip_actionConflicting_body;

  /// No description provided for @tooltip_actionConflicting_onLabel.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get tooltip_actionConflicting_onLabel;

  /// No description provided for @tooltip_actionConflicting_onDesc.
  ///
  /// In en, this message translates to:
  /// **'hold back competing gestures until one wins'**
  String get tooltip_actionConflicting_onDesc;

  /// No description provided for @tooltip_actionConflicting_offLabel.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get tooltip_actionConflicting_offLabel;

  /// No description provided for @tooltip_actionConflicting_offDesc.
  ///
  /// In en, this message translates to:
  /// **'fire immediately, no blocking'**
  String get tooltip_actionConflicting_offDesc;

  /// No description provided for @tooltip_actionConflicting_sectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get tooltip_actionConflicting_sectionLabel;

  /// No description provided for @tooltip_actionConflicting_exCode.
  ///
  /// In en, this message translates to:
  /// **'2-finger swipe  +  3-finger swipe'**
  String get tooltip_actionConflicting_exCode;

  /// No description provided for @tooltip_actionConflicting_exLabel.
  ///
  /// In en, this message translates to:
  /// **'daemon waits to see which one completes'**
  String get tooltip_actionConflicting_exLabel;

  /// No description provided for @tooltip_actionLimit_body.
  ///
  /// In en, this message translates to:
  /// **'Max times this action fires in a single gesture.'**
  String get tooltip_actionLimit_body;

  /// No description provided for @tooltip_actionLimit_bulletUnlimited.
  ///
  /// In en, this message translates to:
  /// **'0 = unlimited (default)'**
  String get tooltip_actionLimit_bulletUnlimited;

  /// No description provided for @tooltip_actionLimit_bulletN.
  ///
  /// In en, this message translates to:
  /// **'N = fires at most N times'**
  String get tooltip_actionLimit_bulletN;

  /// No description provided for @tooltip_actionLimit_exLabel.
  ///
  /// In en, this message translates to:
  /// **'fires once no matter how far the gesture travels'**
  String get tooltip_actionLimit_exLabel;

  /// No description provided for @tooltip_thresholdUnit_swipeStroke.
  ///
  /// In en, this message translates to:
  /// **'Swipe / stroke'**
  String get tooltip_thresholdUnit_swipeStroke;

  /// No description provided for @tooltip_thresholdUnit_pixels.
  ///
  /// In en, this message translates to:
  /// **'pixels'**
  String get tooltip_thresholdUnit_pixels;

  /// No description provided for @tooltip_thresholdUnit_wheel.
  ///
  /// In en, this message translates to:
  /// **'Wheel'**
  String get tooltip_thresholdUnit_wheel;

  /// No description provided for @tooltip_thresholdUnit_scrollTicks.
  ///
  /// In en, this message translates to:
  /// **'scroll ticks'**
  String get tooltip_thresholdUnit_scrollTicks;

  /// No description provided for @tooltip_thresholdUnit_pinch.
  ///
  /// In en, this message translates to:
  /// **'Pinch'**
  String get tooltip_thresholdUnit_pinch;

  /// No description provided for @tooltip_thresholdUnit_rotateCircle.
  ///
  /// In en, this message translates to:
  /// **'Rotate / circle'**
  String get tooltip_thresholdUnit_rotateCircle;

  /// No description provided for @tooltip_thresholdUnit_degrees.
  ///
  /// In en, this message translates to:
  /// **'degrees'**
  String get tooltip_thresholdUnit_degrees;

  /// No description provided for @tooltip_triggerConditions_body.
  ///
  /// In en, this message translates to:
  /// **'All conditions must be true for this gesture to activate.'**
  String get tooltip_triggerConditions_body;

  /// No description provided for @tooltip_triggerConditions_sectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Examples'**
  String get tooltip_triggerConditions_sectionLabel;

  /// No description provided for @tooltip_triggerConditions_ex1Label.
  ///
  /// In en, this message translates to:
  /// **'Firefox only'**
  String get tooltip_triggerConditions_ex1Label;

  /// No description provided for @tooltip_triggerConditions_ex2Label.
  ///
  /// In en, this message translates to:
  /// **'terminal only'**
  String get tooltip_triggerConditions_ex2Label;

  /// No description provided for @tooltip_triggerConditions_ex3Label.
  ///
  /// In en, this message translates to:
  /// **'cursor over focused window'**
  String get tooltip_triggerConditions_ex3Label;

  /// No description provided for @tooltip_triggerConditions_ex4Label.
  ///
  /// In en, this message translates to:
  /// **'cursor at right edge'**
  String get tooltip_triggerConditions_ex4Label;

  /// No description provided for @tooltip_triggerConditions_ex5Label.
  ///
  /// In en, this message translates to:
  /// **'exactly 3 fingers'**
  String get tooltip_triggerConditions_ex5Label;

  /// No description provided for @tooltip_triggerConditions_noteAnd.
  ///
  /// In en, this message translates to:
  /// **'Rows are AND-ed. Use an \"any\" group inside for OR logic.'**
  String get tooltip_triggerConditions_noteAnd;

  /// No description provided for @tooltip_pointPixels_body.
  ///
  /// In en, this message translates to:
  /// **'Previews the position or size of the selected fraction in pixels.'**
  String get tooltip_pointPixels_body;

  /// No description provided for @tooltip_pointPixels_sectionLabel.
  ///
  /// In en, this message translates to:
  /// **'On the chosen resolution'**
  String get tooltip_pointPixels_sectionLabel;

  /// No description provided for @tooltip_pointPixels_pointLabel.
  ///
  /// In en, this message translates to:
  /// **'a point: the pointer position'**
  String get tooltip_pointPixels_pointLabel;

  /// No description provided for @tooltip_pointPixels_rangeLabel.
  ///
  /// In en, this message translates to:
  /// **'a range: the size of the area'**
  String get tooltip_pointPixels_rangeLabel;

  /// No description provided for @tooltip_pointPixels_notePreview.
  ///
  /// In en, this message translates to:
  /// **'Only the preview changes. The value stays a fraction of the screen, so it works on any display.'**
  String get tooltip_pointPixels_notePreview;

  /// No description provided for @tooltip_triggerEndConditions_body.
  ///
  /// In en, this message translates to:
  /// **'Checked at the moment the gesture ends.'**
  String get tooltip_triggerEndConditions_body;

  /// No description provided for @tooltip_triggerEndConditions_metLabel.
  ///
  /// In en, this message translates to:
  /// **'Met'**
  String get tooltip_triggerEndConditions_metLabel;

  /// No description provided for @tooltip_triggerEndConditions_metDesc.
  ///
  /// In en, this message translates to:
  /// **'gesture ends normally · on:end actions fire'**
  String get tooltip_triggerEndConditions_metDesc;

  /// No description provided for @tooltip_triggerEndConditions_notMetLabel.
  ///
  /// In en, this message translates to:
  /// **'Not met'**
  String get tooltip_triggerEndConditions_notMetLabel;

  /// No description provided for @tooltip_triggerEndConditions_notMetDesc.
  ///
  /// In en, this message translates to:
  /// **'gesture cancelled · on:cancel fires instead'**
  String get tooltip_triggerEndConditions_notMetDesc;

  /// No description provided for @tooltip_triggerEndConditions_sectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get tooltip_triggerEndConditions_sectionLabel;

  /// No description provided for @tooltip_triggerEndConditions_exLabel.
  ///
  /// In en, this message translates to:
  /// **'cancel if finger travelled < 100 px'**
  String get tooltip_triggerEndConditions_exLabel;

  /// No description provided for @tooltip_triggerId_body.
  ///
  /// In en, this message translates to:
  /// **'Unique name for this trigger.'**
  String get tooltip_triggerId_body;

  /// No description provided for @tooltip_triggerId_sectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Variables exposed when set'**
  String get tooltip_triggerId_sectionLabel;

  /// No description provided for @tooltip_triggerId_ex1Label.
  ///
  /// In en, this message translates to:
  /// **'true while gesture is running'**
  String get tooltip_triggerId_ex1Label;

  /// No description provided for @tooltip_triggerId_ex2Label.
  ///
  /// In en, this message translates to:
  /// **'equals this id after it fires'**
  String get tooltip_triggerId_ex2Label;

  /// No description provided for @tooltip_triggerId_noteChain.
  ///
  /// In en, this message translates to:
  /// **'Use in other gestures\' conditions to chain or block behaviors.'**
  String get tooltip_triggerId_noteChain;

  /// No description provided for @tooltip_triggerThreshold_body.
  ///
  /// In en, this message translates to:
  /// **'Min accumulated input before gesture is recognized.'**
  String get tooltip_triggerThreshold_body;

  /// No description provided for @tooltip_triggerThreshold_sectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Units by gesture type'**
  String get tooltip_triggerThreshold_sectionLabel;

  /// No description provided for @tooltip_triggerThreshold_unitPinchScale.
  ///
  /// In en, this message translates to:
  /// **'scale factor  (e.g. 0.1 = 10%)'**
  String get tooltip_triggerThreshold_unitPinchScale;

  /// No description provided for @tooltip_triggerThreshold_unitPressKey.
  ///
  /// In en, this message translates to:
  /// **'Press'**
  String get tooltip_triggerThreshold_unitPressKey;

  /// No description provided for @tooltip_triggerThreshold_unitPressDesc.
  ///
  /// In en, this message translates to:
  /// **'n/a'**
  String get tooltip_triggerThreshold_unitPressDesc;

  /// No description provided for @tooltip_triggerThreshold_notePassthrough.
  ///
  /// In en, this message translates to:
  /// **'Below threshold, input passes through to the app normally.'**
  String get tooltip_triggerThreshold_notePassthrough;

  /// No description provided for @tooltip_triggerThreshold_noteRange.
  ///
  /// In en, this message translates to:
  /// **'Use a range like 50-200: require ≥ 50, cancel if > 200.'**
  String get tooltip_triggerThreshold_noteRange;

  /// No description provided for @tooltip_triggerResumeTimeout_body.
  ///
  /// In en, this message translates to:
  /// **'If the same gesture starts within N ms, it resumes instead of starting fresh.'**
  String get tooltip_triggerResumeTimeout_body;

  /// No description provided for @tooltip_triggerResumeTimeout_sectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Useful for'**
  String get tooltip_triggerResumeTimeout_sectionLabel;

  /// No description provided for @tooltip_triggerResumeTimeout_bulletMultiTap.
  ///
  /// In en, this message translates to:
  /// **'Multi-tap sequences; brief pause keeps state.'**
  String get tooltip_triggerResumeTimeout_bulletMultiTap;

  /// No description provided for @tooltip_triggerResumeTimeout_bulletWheel.
  ///
  /// In en, this message translates to:
  /// **'Repeated wheel scrolls accumulating delta across gaps.'**
  String get tooltip_triggerResumeTimeout_bulletWheel;

  /// No description provided for @tooltip_triggerResumeTimeout_noteDisabled.
  ///
  /// In en, this message translates to:
  /// **'0 = disabled (every gesture starts from scratch).'**
  String get tooltip_triggerResumeTimeout_noteDisabled;

  /// No description provided for @tooltip_triggerAccelerated_body.
  ///
  /// In en, this message translates to:
  /// **'Scale delta values by pointer acceleration.'**
  String get tooltip_triggerAccelerated_body;

  /// No description provided for @tooltip_triggerAccelerated_bulletOn.
  ///
  /// In en, this message translates to:
  /// **'Enable for proportional feel, e.g. move_by_delta actions.'**
  String get tooltip_triggerAccelerated_bulletOn;

  /// No description provided for @tooltip_triggerAccelerated_bulletOff.
  ///
  /// In en, this message translates to:
  /// **'Disable for uniform response, e.g. fixed key per tick.'**
  String get tooltip_triggerAccelerated_bulletOff;

  /// No description provided for @tooltip_triggerBlockEvents_body.
  ///
  /// In en, this message translates to:
  /// **'Suppress raw input from reaching other applications.'**
  String get tooltip_triggerBlockEvents_body;

  /// No description provided for @tooltip_triggerBlockEvents_sectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get tooltip_triggerBlockEvents_sectionLabel;

  /// No description provided for @tooltip_triggerBlockEvents_exCode.
  ///
  /// In en, this message translates to:
  /// **'right-click stroke gesture'**
  String get tooltip_triggerBlockEvents_exCode;

  /// No description provided for @tooltip_triggerBlockEvents_exLabel.
  ///
  /// In en, this message translates to:
  /// **'context menu blocked'**
  String get tooltip_triggerBlockEvents_exLabel;

  /// No description provided for @tooltip_triggerBlockEvents_noteDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable if the app should also receive those events while the gesture is active.'**
  String get tooltip_triggerBlockEvents_noteDisable;

  /// No description provided for @tooltip_triggerClearModifiers_prefix.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get tooltip_triggerClearModifiers_prefix;

  /// No description provided for @tooltip_triggerClearModifiers_suffix.
  ///
  /// In en, this message translates to:
  /// **'when the gesture begins.'**
  String get tooltip_triggerClearModifiers_suffix;

  /// No description provided for @tooltip_triggerClearModifiers_noteAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto-enabled when an input: action is present; prevents modifier keys from leaking into replayed events.'**
  String get tooltip_triggerClearModifiers_noteAuto;

  /// No description provided for @tooltip_triggerClearModifiers_noteDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable only if you intentionally need the modifiers held during the action.'**
  String get tooltip_triggerClearModifiers_noteDisable;

  /// No description provided for @tooltip_triggerSetLastTrigger_prefix.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get tooltip_triggerSetLastTrigger_prefix;

  /// No description provided for @tooltip_triggerSetLastTrigger_suffix.
  ///
  /// In en, this message translates to:
  /// **'to this trigger\'s ID when it fires.'**
  String get tooltip_triggerSetLastTrigger_suffix;

  /// No description provided for @tooltip_triggerSetLastTrigger_noteChain.
  ///
  /// In en, this message translates to:
  /// **'Use in other gestures\' conditions to build sequences.'**
  String get tooltip_triggerSetLastTrigger_noteChain;

  /// No description provided for @tooltip_triggerSetLastTrigger_noteDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable for utility triggers you don\'t want polluting state.'**
  String get tooltip_triggerSetLastTrigger_noteDisable;

  /// No description provided for @tooltip_keySequence_body.
  ///
  /// In en, this message translates to:
  /// **'Two formats available, pick whichever feels right.'**
  String get tooltip_keySequence_body;

  /// No description provided for @tooltip_keySequence_chordSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Chord format'**
  String get tooltip_keySequence_chordSectionLabel;

  /// No description provided for @tooltip_keySequence_chordDesc.
  ///
  /// In en, this message translates to:
  /// **'Press and release all keys as one chord.'**
  String get tooltip_keySequence_chordDesc;

  /// No description provided for @tooltip_keySequence_tokenSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Token format'**
  String get tooltip_keySequence_tokenSectionLabel;

  /// No description provided for @tooltip_keySequence_tokenDesc.
  ///
  /// In en, this message translates to:
  /// **'Full control over press / release timing.'**
  String get tooltip_keySequence_tokenDesc;

  /// No description provided for @tooltip_keySequence_pressLabel.
  ///
  /// In en, this message translates to:
  /// **'press'**
  String get tooltip_keySequence_pressLabel;

  /// No description provided for @tooltip_keySequence_releaseLabel.
  ///
  /// In en, this message translates to:
  /// **'release'**
  String get tooltip_keySequence_releaseLabel;

  /// No description provided for @tooltip_buttonSequence_body.
  ///
  /// In en, this message translates to:
  /// **'Mouse button press / release sequence.'**
  String get tooltip_buttonSequence_body;

  /// No description provided for @tooltip_buttonSequence_pressLabel.
  ///
  /// In en, this message translates to:
  /// **'press'**
  String get tooltip_buttonSequence_pressLabel;

  /// No description provided for @tooltip_buttonSequence_releaseLabel.
  ///
  /// In en, this message translates to:
  /// **'release'**
  String get tooltip_buttonSequence_releaseLabel;

  /// No description provided for @tooltip_buttonSequence_noteButtons.
  ///
  /// In en, this message translates to:
  /// **'Available buttons: left, right, middle, back, forward.'**
  String get tooltip_buttonSequence_noteButtons;

  /// No description provided for @tooltip_recordingConvertShortcut_body.
  ///
  /// In en, this message translates to:
  /// **'Rewrites the recording as named chord notation, e.g. ctrl+shift+t or a, s, d.'**
  String get tooltip_recordingConvertShortcut_body;

  /// No description provided for @tooltip_recordingConvertShortcut_enabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get tooltip_recordingConvertShortcut_enabledLabel;

  /// No description provided for @tooltip_recordingConvertShortcut_enabledDesc.
  ///
  /// In en, this message translates to:
  /// **'all keys in each group are pressed before any are released'**
  String get tooltip_recordingConvertShortcut_enabledDesc;

  /// No description provided for @tooltip_recordingConvertShortcut_disabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get tooltip_recordingConvertShortcut_disabledLabel;

  /// No description provided for @tooltip_recordingConvertShortcut_disabledDesc.
  ///
  /// In en, this message translates to:
  /// **'presses and releases interleave, use the token format instead'**
  String get tooltip_recordingConvertShortcut_disabledDesc;

  /// No description provided for @dialogUnsavedChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get dialogUnsavedChangesTitle;

  /// No description provided for @dialogUnsavedChangesBody.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Apply them or discard before leaving.'**
  String get dialogUnsavedChangesBody;

  /// No description provided for @actionApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get actionApply;

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add Action'**
  String get addAction;

  /// No description provided for @dialogAddActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add action'**
  String get dialogAddActionTitle;

  /// No description provided for @actionIntervalHint.
  ///
  /// In en, this message translates to:
  /// **'+, -, or number'**
  String get actionIntervalHint;

  /// No description provided for @actionLimitHint.
  ///
  /// In en, this message translates to:
  /// **'0 = unlimited'**
  String get actionLimitHint;

  /// No description provided for @actionPlasmaComponentLabel.
  ///
  /// In en, this message translates to:
  /// **'Component'**
  String get actionPlasmaComponentLabel;

  /// No description provided for @actionPlasmaComponentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Plasma shortcut component. Find in ~/.config/kglobalshortcutsrc, text inside brackets. Replace dots and dashes with underscores. Example: org_kde_dolphin_desktop'**
  String get actionPlasmaComponentTooltip;

  /// No description provided for @actionPlasmaComponentHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. org_kde_dolphin_desktop'**
  String get actionPlasmaComponentHint;

  /// No description provided for @actionPlasmaShortcutLabel.
  ///
  /// In en, this message translates to:
  /// **'Shortcut'**
  String get actionPlasmaShortcutLabel;

  /// No description provided for @actionPlasmaShortcutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Shortcut name within the component. In kglobalshortcutsrc, it is the text before \"=\" on each line.'**
  String get actionPlasmaShortcutTooltip;

  /// No description provided for @actionPlasmaShortcutHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Show Desktop'**
  String get actionPlasmaShortcutHint;

  /// No description provided for @plasmaShortcutPickerSearch.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get plasmaShortcutPickerSearch;

  /// No description provided for @plasmaShortcutPickerSelectComponent.
  ///
  /// In en, this message translates to:
  /// **'Select a component'**
  String get plasmaShortcutPickerSelectComponent;

  /// No description provided for @plasmaShortcutPickerNoResults.
  ///
  /// In en, this message translates to:
  /// **'No shortcuts found'**
  String get plasmaShortcutPickerNoResults;

  /// No description provided for @plasmaShortcutPickerApplications.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get plasmaShortcutPickerApplications;

  /// No description provided for @plasmaShortcutPickerSystemServices.
  ///
  /// In en, this message translates to:
  /// **'System Services'**
  String get plasmaShortcutPickerSystemServices;

  /// No description provided for @plasmaShortcutPickerSelectShortcut.
  ///
  /// In en, this message translates to:
  /// **'Select shortcut'**
  String get plasmaShortcutPickerSelectShortcut;

  /// No description provided for @plasmaShortcutPickerCombinedLabel.
  ///
  /// In en, this message translates to:
  /// **'Component & Shortcut'**
  String get plasmaShortcutPickerCombinedLabel;

  /// No description provided for @plasmaShortcutPickerCombinedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Choose a Plasma component and one of its registered shortcuts from the picker. Use Manual entry if your shortcut is not listed.'**
  String get plasmaShortcutPickerCombinedTooltip;

  /// No description provided for @plasmaShortcutPickerUsePicker.
  ///
  /// In en, this message translates to:
  /// **'Use picker'**
  String get plasmaShortcutPickerUsePicker;

  /// No description provided for @plasmaShortcutPickerManualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual entry'**
  String get plasmaShortcutPickerManualEntry;

  /// No description provided for @actionSleepDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration (ms)'**
  String get actionSleepDurationLabel;

  /// No description provided for @actionSleepDurationTooltip.
  ///
  /// In en, this message translates to:
  /// **'How long to pause before the next action runs. Useful for timing issues with input or window focus.'**
  String get actionSleepDurationTooltip;

  /// No description provided for @actionSleepDurationHint.
  ///
  /// In en, this message translates to:
  /// **'500'**
  String get actionSleepDurationHint;

  /// No description provided for @actionFunctionLabel.
  ///
  /// In en, this message translates to:
  /// **'Function'**
  String get actionFunctionLabel;

  /// No description provided for @actionFunctionHint.
  ///
  /// In en, this message translates to:
  /// **'() => initialDirection = \"l\"'**
  String get actionFunctionHint;

  /// No description provided for @groupMenuRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get groupMenuRename;

  /// No description provided for @groupMenuNewSubgroup.
  ///
  /// In en, this message translates to:
  /// **'New subgroup'**
  String get groupMenuNewSubgroup;

  /// No description provided for @groupMenuBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Ungroup'**
  String get groupMenuBreakdown;

  /// No description provided for @groupMenuDeleteWithGestures.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get groupMenuDeleteWithGestures;

  /// No description provided for @strokeRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Stroke {n}'**
  String strokeRowTitle(int n);

  /// No description provided for @strokeRowPoints.
  ///
  /// In en, this message translates to:
  /// **'{n} sample points'**
  String strokeRowPoints(int n);

  /// No description provided for @strokeRowInvalidData.
  ///
  /// In en, this message translates to:
  /// **'Invalid stroke data'**
  String get strokeRowInvalidData;

  /// No description provided for @strokePreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Stroke preview'**
  String get strokePreviewTitle;

  /// No description provided for @inputDevicesLabel.
  ///
  /// In en, this message translates to:
  /// **'Input devices'**
  String get inputDevicesLabel;

  /// No description provided for @inputAddDevice.
  ///
  /// In en, this message translates to:
  /// **'Add device'**
  String get inputAddDevice;

  /// No description provided for @inputKeySequenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Key Sequence'**
  String get inputKeySequenceLabel;

  /// No description provided for @inputKeySequenceRecordTip.
  ///
  /// In en, this message translates to:
  /// **'Record a sequence of keystrokes.'**
  String get inputKeySequenceRecordTip;

  /// No description provided for @inputKeySequenceRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Record keystrokes'**
  String get inputKeySequenceRecordTitle;

  /// No description provided for @inputKeySequenceRecordingTitle.
  ///
  /// In en, this message translates to:
  /// **'Recording keystrokes...'**
  String get inputKeySequenceRecordingTitle;

  /// No description provided for @inputKeySequenceRecordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Press any key to record.'**
  String get inputKeySequenceRecordPrompt;

  /// No description provided for @inputKeySequenceStopAdd.
  ///
  /// In en, this message translates to:
  /// **'Stop & Add'**
  String get inputKeySequenceStopAdd;

  /// No description provided for @inputKeySequenceRecordingConvertShortcut.
  ///
  /// In en, this message translates to:
  /// **'Chord format'**
  String get inputKeySequenceRecordingConvertShortcut;

  /// No description provided for @inputKeySequenceRecordingClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get inputKeySequenceRecordingClear;

  /// No description provided for @inputKeySequenceBrowseTip.
  ///
  /// In en, this message translates to:
  /// **'Browse available keys'**
  String get inputKeySequenceBrowseTip;

  /// No description provided for @inputKeyBrowseHint.
  ///
  /// In en, this message translates to:
  /// **'Search keys…'**
  String get inputKeyBrowseHint;

  /// No description provided for @inputKeyBrowseEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matching keys'**
  String get inputKeyBrowseEmpty;

  /// No description provided for @inputButtonSequenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Button Sequence'**
  String get inputButtonSequenceLabel;

  /// No description provided for @inputButtonSequenceRecordTip.
  ///
  /// In en, this message translates to:
  /// **'Record mouse button clicks.'**
  String get inputButtonSequenceRecordTip;

  /// No description provided for @inputButtonSequenceRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Record mouse buttons'**
  String get inputButtonSequenceRecordTitle;

  /// No description provided for @inputButtonSequenceRecordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Click any mouse button here'**
  String get inputButtonSequenceRecordPrompt;

  /// No description provided for @inputButtonSequenceAddToSeq.
  ///
  /// In en, this message translates to:
  /// **'Add to sequence'**
  String get inputButtonSequenceAddToSeq;

  /// No description provided for @inputTextToTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Text to type'**
  String get inputTextToTypeLabel;

  /// No description provided for @inputDeviceFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get inputDeviceFieldLabel;

  /// No description provided for @inputDeviceFieldTooltip.
  ///
  /// In en, this message translates to:
  /// **'Whether to simulate keyboard or mouse input.'**
  String get inputDeviceFieldTooltip;

  /// No description provided for @inputActionTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Action type'**
  String get inputActionTypeLabel;

  /// No description provided for @inputActionTypeTooltip.
  ///
  /// In en, this message translates to:
  /// **'The kind of simulated input: key combination, typed text, mouse movement, scroll wheel, etc.'**
  String get inputActionTypeTooltip;

  /// No description provided for @mouseDeltaMultiplierLabel.
  ///
  /// In en, this message translates to:
  /// **'Multiplier'**
  String get mouseDeltaMultiplierLabel;

  /// No description provided for @mouseDeltaMultiplierTooltip.
  ///
  /// In en, this message translates to:
  /// **'Scale factor applied to the gesture movement delta. 1 moves the pointer by the same distance as the gesture, 2 doubles it, 0.5 halves it.'**
  String get mouseDeltaMultiplierTooltip;

  /// No description provided for @motionSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Motion Speed'**
  String get motionSpeedLabel;

  /// No description provided for @motionSpeedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Required speed for this gesture. \"Fast\" requires quick movement, \"Slow\" requires deliberate movement. \"Any\" matches both.'**
  String get motionSpeedTooltip;

  /// No description provided for @motionLockPointerLabel.
  ///
  /// In en, this message translates to:
  /// **'Lock pointer'**
  String get motionLockPointerLabel;

  /// No description provided for @motionLockPointerTooltip.
  ///
  /// In en, this message translates to:
  /// **'Prevent the pointer from moving on screen while this gesture is active.'**
  String get motionLockPointerTooltip;

  /// No description provided for @pointRangeFromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get pointRangeFromLabel;

  /// No description provided for @pointRangeToLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get pointRangeToLabel;

  /// No description provided for @pointPixelReadoutPrefix.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get pointPixelReadoutPrefix;

  /// No description provided for @swipeMinAngleLabel.
  ///
  /// In en, this message translates to:
  /// **'Min angle °'**
  String get swipeMinAngleLabel;

  /// No description provided for @swipeMinAngleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Start of the angle range. 0° = right, 90° = up, 180° = left, 270° = down. Drag the handle on the wheel or type a value.'**
  String get swipeMinAngleTooltip;

  /// No description provided for @swipeMaxAngleLabel.
  ///
  /// In en, this message translates to:
  /// **'Max angle °'**
  String get swipeMaxAngleLabel;

  /// No description provided for @swipeMaxAngleTooltip.
  ///
  /// In en, this message translates to:
  /// **'End of the angle range. If min < max the range is between them. If min > max, the range wraps around (e.g. 330-30 covers rightward motion).'**
  String get swipeMaxAngleTooltip;

  /// No description provided for @swipeAngleBidirectionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Bidirectional'**
  String get swipeAngleBidirectionalLabel;

  /// No description provided for @swipeAngleBidirectionalTooltip.
  ///
  /// In en, this message translates to:
  /// **'Also match motion in the opposite angle range. That motion will have a negative delta value.\n\nWhen angle ranges overlap, the normal one takes priority over the opposite one.'**
  String get swipeAngleBidirectionalTooltip;

  /// No description provided for @swipeDirectionBidirectionalTooltip.
  ///
  /// In en, this message translates to:
  /// **'Also match motion in the opposite direction. Motion in the opposite direction will have a negative delta value.'**
  String get swipeDirectionBidirectionalTooltip;

  /// No description provided for @mouseButtonsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Mouse buttons'**
  String get mouseButtonsSectionTitle;

  /// No description provided for @mouseButtonsSectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mouse buttons that must be held while performing this gesture.'**
  String get mouseButtonsSectionTooltip;

  /// No description provided for @mouseButtonsExactOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Exact order'**
  String get mouseButtonsExactOrderLabel;

  /// No description provided for @mouseButtonsExactOrderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Require buttons to be pressed in exactly the order shown. When disabled, all selected buttons must be held but in any order.'**
  String get mouseButtonsExactOrderTooltip;

  /// No description provided for @conditionMenuAddConditionTitle.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get conditionMenuAddConditionTitle;

  /// No description provided for @conditionMenuAddConditionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A single condition'**
  String get conditionMenuAddConditionSubtitle;

  /// No description provided for @conditionMenuAddGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get conditionMenuAddGroupTitle;

  /// No description provided for @conditionMenuAddGroupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Collection of conditions.'**
  String get conditionMenuAddGroupSubtitle;

  /// No description provided for @conditionMenuAddFunctionTitle.
  ///
  /// In en, this message translates to:
  /// **'Function'**
  String get conditionMenuAddFunctionTitle;

  /// No description provided for @conditionMenuAddFunctionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'JavaScript expression evaluated at runtime.'**
  String get conditionMenuAddFunctionSubtitle;

  /// No description provided for @conditionFunctionLabel.
  ///
  /// In en, this message translates to:
  /// **'Function'**
  String get conditionFunctionLabel;

  /// No description provided for @conditionFunctionHint.
  ///
  /// In en, this message translates to:
  /// **'() => initialDirection == \"l\"'**
  String get conditionFunctionHint;

  /// No description provided for @tooltip_function_exampleLabel.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get tooltip_function_exampleLabel;

  /// No description provided for @tooltip_function_apisNote.
  ///
  /// In en, this message translates to:
  /// **'Call built-in APIs with require() \"(inputactions/core, inputactions/fs)\" and console.'**
  String get tooltip_function_apisNote;

  /// No description provided for @tooltip_function_callablePrefix.
  ///
  /// In en, this message translates to:
  /// **'Must be a callable arrow function: '**
  String get tooltip_function_callablePrefix;

  /// No description provided for @tooltip_conditionFunction_body.
  ///
  /// In en, this message translates to:
  /// **'A JavaScript function evaluated every time this condition is checked. It passes when the function returns a truthy value — use it for logic the built-in variable conditions can\'t express.'**
  String get tooltip_conditionFunction_body;

  /// No description provided for @tooltip_conditionFunction_exampleAnnotation.
  ///
  /// In en, this message translates to:
  /// **'Passes while the script variable equals \"l\"'**
  String get tooltip_conditionFunction_exampleAnnotation;

  /// No description provided for @tooltip_conditionFunction_variablesNote.
  ///
  /// In en, this message translates to:
  /// **'Read persistent script variables to track state across gestures.'**
  String get tooltip_conditionFunction_variablesNote;

  /// No description provided for @tooltip_actionFunction_body.
  ///
  /// In en, this message translates to:
  /// **'A JavaScript function run for its side effects when this action executes. Its return value is ignored.'**
  String get tooltip_actionFunction_body;

  /// No description provided for @tooltip_actionFunction_exampleAnnotation.
  ///
  /// In en, this message translates to:
  /// **'Sets a script variable other actions and conditions can read'**
  String get tooltip_actionFunction_exampleAnnotation;

  /// No description provided for @tooltip_actionFunction_variablesNote.
  ///
  /// In en, this message translates to:
  /// **'Commonly used to set or update persistent script variables.'**
  String get tooltip_actionFunction_variablesNote;

  /// No description provided for @tooltip_actionFunction_watchdogNote.
  ///
  /// In en, this message translates to:
  /// **'Long-running loops are interrupted by a watchdog.'**
  String get tooltip_actionFunction_watchdogNote;

  /// No description provided for @conditionVariableSelectorOpenHint.
  ///
  /// In en, this message translates to:
  /// **'Click to open selector.'**
  String get conditionVariableSelectorOpenHint;

  /// No description provided for @renameGroupHint.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get renameGroupHint;

  /// No description provided for @varGroupActiveWindow.
  ///
  /// In en, this message translates to:
  /// **'Active Window'**
  String get varGroupActiveWindow;

  /// No description provided for @varGroupWindowUnderPointer.
  ///
  /// In en, this message translates to:
  /// **'Window Under Pointer'**
  String get varGroupWindowUnderPointer;

  /// No description provided for @varGroupWindowUnderFingers.
  ///
  /// In en, this message translates to:
  /// **'Window Under Fingers'**
  String get varGroupWindowUnderFingers;

  /// No description provided for @varGroupPointer.
  ///
  /// In en, this message translates to:
  /// **'Pointer'**
  String get varGroupPointer;

  /// No description provided for @varGroupFingerPosition.
  ///
  /// In en, this message translates to:
  /// **'Finger Position'**
  String get varGroupFingerPosition;

  /// No description provided for @varGroupFingerInitialPosition.
  ///
  /// In en, this message translates to:
  /// **'Finger Initial Position'**
  String get varGroupFingerInitialPosition;

  /// No description provided for @varGroupFingerPressure.
  ///
  /// In en, this message translates to:
  /// **'Finger Pressure'**
  String get varGroupFingerPressure;

  /// No description provided for @varGroupThumb.
  ///
  /// In en, this message translates to:
  /// **'Thumb'**
  String get varGroupThumb;

  /// No description provided for @varGroupInput.
  ///
  /// In en, this message translates to:
  /// **'Input'**
  String get varGroupInput;

  /// No description provided for @varGroupState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get varGroupState;

  /// No description provided for @varGroupDeviceIdentity.
  ///
  /// In en, this message translates to:
  /// **'Device Identity'**
  String get varGroupDeviceIdentity;

  /// No description provided for @varGroupDeviceType.
  ///
  /// In en, this message translates to:
  /// **'Device Type'**
  String get varGroupDeviceType;

  /// No description provided for @varLabel_windowTitle.
  ///
  /// In en, this message translates to:
  /// **'Active window - title'**
  String get varLabel_windowTitle;

  /// No description provided for @varLabel_windowClass.
  ///
  /// In en, this message translates to:
  /// **'Active window - app class'**
  String get varLabel_windowClass;

  /// No description provided for @varLabel_windowName.
  ///
  /// In en, this message translates to:
  /// **'Active window - name'**
  String get varLabel_windowName;

  /// No description provided for @varLabel_windowId.
  ///
  /// In en, this message translates to:
  /// **'Active window - ID'**
  String get varLabel_windowId;

  /// No description provided for @varLabel_windowPid.
  ///
  /// In en, this message translates to:
  /// **'Active window - process ID'**
  String get varLabel_windowPid;

  /// No description provided for @varLabel_windowFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Active window is fullscreen'**
  String get varLabel_windowFullscreen;

  /// No description provided for @varLabel_windowMaximized.
  ///
  /// In en, this message translates to:
  /// **'Active window is maximized'**
  String get varLabel_windowMaximized;

  /// No description provided for @varLabel_windowUnderPointerTitle.
  ///
  /// In en, this message translates to:
  /// **'Pointer window - title'**
  String get varLabel_windowUnderPointerTitle;

  /// No description provided for @varLabel_windowUnderPointerClass.
  ///
  /// In en, this message translates to:
  /// **'Pointer window - app class'**
  String get varLabel_windowUnderPointerClass;

  /// No description provided for @varLabel_windowUnderPointerName.
  ///
  /// In en, this message translates to:
  /// **'Pointer window - name'**
  String get varLabel_windowUnderPointerName;

  /// No description provided for @varLabel_windowUnderPointerId.
  ///
  /// In en, this message translates to:
  /// **'Pointer window - ID'**
  String get varLabel_windowUnderPointerId;

  /// No description provided for @varLabel_windowUnderPointerPid.
  ///
  /// In en, this message translates to:
  /// **'Pointer window - process ID'**
  String get varLabel_windowUnderPointerPid;

  /// No description provided for @varLabel_windowUnderPointerFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Pointer window is fullscreen'**
  String get varLabel_windowUnderPointerFullscreen;

  /// No description provided for @varLabel_windowUnderPointerMaximized.
  ///
  /// In en, this message translates to:
  /// **'Pointer window is maximized'**
  String get varLabel_windowUnderPointerMaximized;

  /// No description provided for @varLabel_windowUnderFingersTitle.
  ///
  /// In en, this message translates to:
  /// **'Fingers window - title'**
  String get varLabel_windowUnderFingersTitle;

  /// No description provided for @varLabel_windowUnderFingersClass.
  ///
  /// In en, this message translates to:
  /// **'Fingers window - app class'**
  String get varLabel_windowUnderFingersClass;

  /// No description provided for @varLabel_windowUnderFingersName.
  ///
  /// In en, this message translates to:
  /// **'Fingers window - name'**
  String get varLabel_windowUnderFingersName;

  /// No description provided for @varLabel_windowUnderFingersId.
  ///
  /// In en, this message translates to:
  /// **'Fingers window - ID'**
  String get varLabel_windowUnderFingersId;

  /// No description provided for @varLabel_windowUnderFingersPid.
  ///
  /// In en, this message translates to:
  /// **'Fingers window - process ID'**
  String get varLabel_windowUnderFingersPid;

  /// No description provided for @varLabel_windowUnderFingersFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Fingers window is fullscreen'**
  String get varLabel_windowUnderFingersFullscreen;

  /// No description provided for @varLabel_windowUnderFingersMaximized.
  ///
  /// In en, this message translates to:
  /// **'Fingers window is maximized'**
  String get varLabel_windowUnderFingersMaximized;

  /// No description provided for @varLabel_pointerPositionScreen.
  ///
  /// In en, this message translates to:
  /// **'Pointer position (screen %)'**
  String get varLabel_pointerPositionScreen;

  /// No description provided for @varLabel_pointerPositionScreenX.
  ///
  /// In en, this message translates to:
  /// **'Pointer position X (screen %)'**
  String get varLabel_pointerPositionScreenX;

  /// No description provided for @varLabel_pointerPositionScreenY.
  ///
  /// In en, this message translates to:
  /// **'Pointer position Y (screen %)'**
  String get varLabel_pointerPositionScreenY;

  /// No description provided for @varLabel_pointerPositionWindow.
  ///
  /// In en, this message translates to:
  /// **'Pointer position (window %)'**
  String get varLabel_pointerPositionWindow;

  /// No description provided for @varLabel_pointerPositionWindowX.
  ///
  /// In en, this message translates to:
  /// **'Pointer position X (window %)'**
  String get varLabel_pointerPositionWindowX;

  /// No description provided for @varLabel_pointerPositionWindowY.
  ///
  /// In en, this message translates to:
  /// **'Pointer position Y (window %)'**
  String get varLabel_pointerPositionWindowY;

  /// No description provided for @varLabel_finger1Position.
  ///
  /// In en, this message translates to:
  /// **'Finger 1 position %'**
  String get varLabel_finger1Position;

  /// No description provided for @varLabel_finger1PositionX.
  ///
  /// In en, this message translates to:
  /// **'Finger 1 position X %'**
  String get varLabel_finger1PositionX;

  /// No description provided for @varLabel_finger1PositionY.
  ///
  /// In en, this message translates to:
  /// **'Finger 1 position Y %'**
  String get varLabel_finger1PositionY;

  /// No description provided for @varLabel_finger2Position.
  ///
  /// In en, this message translates to:
  /// **'Finger 2 position %'**
  String get varLabel_finger2Position;

  /// No description provided for @varLabel_finger2PositionX.
  ///
  /// In en, this message translates to:
  /// **'Finger 2 position X %'**
  String get varLabel_finger2PositionX;

  /// No description provided for @varLabel_finger2PositionY.
  ///
  /// In en, this message translates to:
  /// **'Finger 2 position Y %'**
  String get varLabel_finger2PositionY;

  /// No description provided for @varLabel_finger3Position.
  ///
  /// In en, this message translates to:
  /// **'Finger 3 position %'**
  String get varLabel_finger3Position;

  /// No description provided for @varLabel_finger3PositionX.
  ///
  /// In en, this message translates to:
  /// **'Finger 3 position X %'**
  String get varLabel_finger3PositionX;

  /// No description provided for @varLabel_finger3PositionY.
  ///
  /// In en, this message translates to:
  /// **'Finger 3 position Y %'**
  String get varLabel_finger3PositionY;

  /// No description provided for @varLabel_finger4Position.
  ///
  /// In en, this message translates to:
  /// **'Finger 4 position %'**
  String get varLabel_finger4Position;

  /// No description provided for @varLabel_finger4PositionX.
  ///
  /// In en, this message translates to:
  /// **'Finger 4 position X %'**
  String get varLabel_finger4PositionX;

  /// No description provided for @varLabel_finger4PositionY.
  ///
  /// In en, this message translates to:
  /// **'Finger 4 position Y %'**
  String get varLabel_finger4PositionY;

  /// No description provided for @varLabel_finger5Position.
  ///
  /// In en, this message translates to:
  /// **'Finger 5 position %'**
  String get varLabel_finger5Position;

  /// No description provided for @varLabel_finger5PositionX.
  ///
  /// In en, this message translates to:
  /// **'Finger 5 position X %'**
  String get varLabel_finger5PositionX;

  /// No description provided for @varLabel_finger5PositionY.
  ///
  /// In en, this message translates to:
  /// **'Finger 5 position Y %'**
  String get varLabel_finger5PositionY;

  /// No description provided for @varLabel_finger1InitialPosition.
  ///
  /// In en, this message translates to:
  /// **'Finger 1 initial position %'**
  String get varLabel_finger1InitialPosition;

  /// No description provided for @varLabel_finger1InitialPositionX.
  ///
  /// In en, this message translates to:
  /// **'Finger 1 initial position X %'**
  String get varLabel_finger1InitialPositionX;

  /// No description provided for @varLabel_finger1InitialPositionY.
  ///
  /// In en, this message translates to:
  /// **'Finger 1 initial position Y %'**
  String get varLabel_finger1InitialPositionY;

  /// No description provided for @varLabel_finger2InitialPosition.
  ///
  /// In en, this message translates to:
  /// **'Finger 2 initial position %'**
  String get varLabel_finger2InitialPosition;

  /// No description provided for @varLabel_finger2InitialPositionX.
  ///
  /// In en, this message translates to:
  /// **'Finger 2 initial position X %'**
  String get varLabel_finger2InitialPositionX;

  /// No description provided for @varLabel_finger2InitialPositionY.
  ///
  /// In en, this message translates to:
  /// **'Finger 2 initial position Y %'**
  String get varLabel_finger2InitialPositionY;

  /// No description provided for @varLabel_finger3InitialPosition.
  ///
  /// In en, this message translates to:
  /// **'Finger 3 initial position %'**
  String get varLabel_finger3InitialPosition;

  /// No description provided for @varLabel_finger3InitialPositionX.
  ///
  /// In en, this message translates to:
  /// **'Finger 3 initial position X %'**
  String get varLabel_finger3InitialPositionX;

  /// No description provided for @varLabel_finger3InitialPositionY.
  ///
  /// In en, this message translates to:
  /// **'Finger 3 initial position Y %'**
  String get varLabel_finger3InitialPositionY;

  /// No description provided for @varLabel_finger4InitialPosition.
  ///
  /// In en, this message translates to:
  /// **'Finger 4 initial position %'**
  String get varLabel_finger4InitialPosition;

  /// No description provided for @varLabel_finger4InitialPositionX.
  ///
  /// In en, this message translates to:
  /// **'Finger 4 initial position X %'**
  String get varLabel_finger4InitialPositionX;

  /// No description provided for @varLabel_finger4InitialPositionY.
  ///
  /// In en, this message translates to:
  /// **'Finger 4 initial position Y %'**
  String get varLabel_finger4InitialPositionY;

  /// No description provided for @varLabel_finger5InitialPosition.
  ///
  /// In en, this message translates to:
  /// **'Finger 5 initial position %'**
  String get varLabel_finger5InitialPosition;

  /// No description provided for @varLabel_finger5InitialPositionX.
  ///
  /// In en, this message translates to:
  /// **'Finger 5 initial position X %'**
  String get varLabel_finger5InitialPositionX;

  /// No description provided for @varLabel_finger5InitialPositionY.
  ///
  /// In en, this message translates to:
  /// **'Finger 5 initial position Y %'**
  String get varLabel_finger5InitialPositionY;

  /// No description provided for @varLabel_finger1Pressure.
  ///
  /// In en, this message translates to:
  /// **'Finger 1 pressure'**
  String get varLabel_finger1Pressure;

  /// No description provided for @varLabel_finger2Pressure.
  ///
  /// In en, this message translates to:
  /// **'Finger 2 pressure'**
  String get varLabel_finger2Pressure;

  /// No description provided for @varLabel_finger3Pressure.
  ///
  /// In en, this message translates to:
  /// **'Finger 3 pressure'**
  String get varLabel_finger3Pressure;

  /// No description provided for @varLabel_finger4Pressure.
  ///
  /// In en, this message translates to:
  /// **'Finger 4 pressure'**
  String get varLabel_finger4Pressure;

  /// No description provided for @varLabel_finger5Pressure.
  ///
  /// In en, this message translates to:
  /// **'Finger 5 pressure'**
  String get varLabel_finger5Pressure;

  /// No description provided for @varLabel_thumbPresent.
  ///
  /// In en, this message translates to:
  /// **'Thumb present'**
  String get varLabel_thumbPresent;

  /// No description provided for @varLabel_thumbPosition.
  ///
  /// In en, this message translates to:
  /// **'Thumb position %'**
  String get varLabel_thumbPosition;

  /// No description provided for @varLabel_thumbPositionX.
  ///
  /// In en, this message translates to:
  /// **'Thumb position X %'**
  String get varLabel_thumbPositionX;

  /// No description provided for @varLabel_thumbPositionY.
  ///
  /// In en, this message translates to:
  /// **'Thumb position Y %'**
  String get varLabel_thumbPositionY;

  /// No description provided for @varLabel_thumbInitialPosition.
  ///
  /// In en, this message translates to:
  /// **'Thumb initial position %'**
  String get varLabel_thumbInitialPosition;

  /// No description provided for @varLabel_thumbInitialPositionX.
  ///
  /// In en, this message translates to:
  /// **'Thumb initial position X %'**
  String get varLabel_thumbInitialPositionX;

  /// No description provided for @varLabel_thumbInitialPositionY.
  ///
  /// In en, this message translates to:
  /// **'Thumb initial position Y %'**
  String get varLabel_thumbInitialPositionY;

  /// No description provided for @varLabel_fingers.
  ///
  /// In en, this message translates to:
  /// **'Number of fingers'**
  String get varLabel_fingers;

  /// No description provided for @varLabel_keyboardModifiers.
  ///
  /// In en, this message translates to:
  /// **'Held modifier keys'**
  String get varLabel_keyboardModifiers;

  /// No description provided for @varLabel_cursorShape.
  ///
  /// In en, this message translates to:
  /// **'Cursor shape'**
  String get varLabel_cursorShape;

  /// No description provided for @varLabel_screenName.
  ///
  /// In en, this message translates to:
  /// **'Screen name'**
  String get varLabel_screenName;

  /// No description provided for @varLabel_plasmaOverviewActive.
  ///
  /// In en, this message translates to:
  /// **'Plasma overview active'**
  String get varLabel_plasmaOverviewActive;

  /// No description provided for @varLabel_lastTriggerId.
  ///
  /// In en, this message translates to:
  /// **'Last trigger ID'**
  String get varLabel_lastTriggerId;

  /// No description provided for @varLabel_timeSinceLastTrigger.
  ///
  /// In en, this message translates to:
  /// **'Time since last trigger'**
  String get varLabel_timeSinceLastTrigger;

  /// No description provided for @varLabel_deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device name'**
  String get varLabel_deviceName;

  /// No description provided for @varLabel_deviceTypes.
  ///
  /// In en, this message translates to:
  /// **'Device types'**
  String get varLabel_deviceTypes;

  /// No description provided for @varLabel_deviceIsKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Is keyboard'**
  String get varLabel_deviceIsKeyboard;

  /// No description provided for @varLabel_deviceIsMouse.
  ///
  /// In en, this message translates to:
  /// **'Is mouse'**
  String get varLabel_deviceIsMouse;

  /// No description provided for @varLabel_deviceIsTouchpad.
  ///
  /// In en, this message translates to:
  /// **'Is touchpad'**
  String get varLabel_deviceIsTouchpad;

  /// No description provided for @varLabel_deviceIsTouchscreen.
  ///
  /// In en, this message translates to:
  /// **'Is touchscreen'**
  String get varLabel_deviceIsTouchscreen;
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
