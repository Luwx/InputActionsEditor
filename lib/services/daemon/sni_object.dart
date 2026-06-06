import 'package:dbus/dbus.dart';

// Implements the org.kde.StatusNotifierItem D-Bus interface (Plasma tray).
class SniObject extends DBusObject {
  SniObject({required this.onActivate})
    : super(DBusObjectPath('/StatusNotifierItem'));

  final void Function() onActivate;

  Map<String, DBusValue> get _props => {
    'Category': const DBusString('ApplicationStatus'),
    'Id': const DBusString('input-actions-ui'),
    'Title': const DBusString('Input Actions'),
    'Status': const DBusString('Active'),
    'WindowId': const DBusUint32(0),
    'IconName': const DBusString('input-gaming'),
    'IconPixmap': DBusArray(DBusSignature('(iiay)'), []),
    'OverlayIconName': const DBusString(''),
    'OverlayIconPixmap': DBusArray(DBusSignature('(iiay)'), []),
    'AttentionIconName': const DBusString(''),
    'AttentionIconPixmap': DBusArray(DBusSignature('(iiay)'), []),
    'AttentionMovieName': const DBusString(''),
    'ToolTip': DBusStruct([
      const DBusString(''),
      DBusArray(DBusSignature('(iiay)'), []),
      const DBusString('Input Actions'),
      const DBusString(''),
    ]),
    'ItemIsMenu': const DBusBoolean(false),
    'Menu': DBusObjectPath('/'),
  };

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    switch (methodCall.interface) {
      case 'org.kde.StatusNotifierItem':
        switch (methodCall.name) {
          case 'Activate':
          case 'SecondaryActivate':
            onActivate();
            return DBusMethodSuccessResponse();
          case 'ContextMenu':
          case 'Scroll':
            return DBusMethodSuccessResponse();
          default:
            return DBusMethodErrorResponse.unknownMethod();
        }

      case 'org.freedesktop.DBus.Properties':
        return _handleProperties(methodCall);

      default:
        return super.handleMethodCall(methodCall);
    }
  }

  DBusMethodResponse _handleProperties(DBusMethodCall call) {
    final iface = (call.values[0] as DBusString).value;
    switch (call.name) {
      case 'Get':
        if (iface != 'org.kde.StatusNotifierItem') {
          return DBusMethodErrorResponse.unknownInterface();
        }
        final prop = (call.values[1] as DBusString).value;
        final value = _props[prop];
        if (value == null) return DBusMethodErrorResponse.unknownMethod();
        return DBusMethodSuccessResponse([DBusVariant(value)]);

      case 'GetAll':
        if (iface != 'org.kde.StatusNotifierItem') {
          return DBusMethodSuccessResponse([
            DBusDict(DBusSignature('s'), DBusSignature('v'), {}),
          ]);
        }
        return DBusMethodSuccessResponse([
          DBusDict(
            DBusSignature('s'),
            DBusSignature('v'),
            {
              for (final e in _props.entries)
                DBusString(e.key): DBusVariant(e.value),
            },
          ),
        ]);

      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }

  @override
  List<DBusIntrospectInterface> introspect() => [
    DBusIntrospectInterface(
      'org.kde.StatusNotifierItem',
      methods: [
        DBusIntrospectMethod('Activate'),
        DBusIntrospectMethod('SecondaryActivate'),
        DBusIntrospectMethod('ContextMenu'),
        DBusIntrospectMethod('Scroll'),
      ],
      properties: [
        DBusIntrospectProperty(
          'Category',
          DBusSignature('s'),
          access: DBusPropertyAccess.read,
        ),
        DBusIntrospectProperty(
          'Id',
          DBusSignature('s'),
          access: DBusPropertyAccess.read,
        ),
        DBusIntrospectProperty(
          'Title',
          DBusSignature('s'),
          access: DBusPropertyAccess.read,
        ),
        DBusIntrospectProperty(
          'Status',
          DBusSignature('s'),
          access: DBusPropertyAccess.read,
        ),
        DBusIntrospectProperty(
          'WindowId',
          DBusSignature('u'),
          access: DBusPropertyAccess.read,
        ),
        DBusIntrospectProperty(
          'IconName',
          DBusSignature('s'),
          access: DBusPropertyAccess.read,
        ),
        DBusIntrospectProperty(
          'IconPixmap',
          DBusSignature('a(iiay)'),
          access: DBusPropertyAccess.read,
        ),
        DBusIntrospectProperty(
          'OverlayIconName',
          DBusSignature('s'),
          access: DBusPropertyAccess.read,
        ),
        DBusIntrospectProperty(
          'OverlayIconPixmap',
          DBusSignature('a(iiay)'),
          access: DBusPropertyAccess.read,
        ),
        DBusIntrospectProperty(
          'AttentionIconName',
          DBusSignature('s'),
          access: DBusPropertyAccess.read,
        ),
        DBusIntrospectProperty(
          'AttentionIconPixmap',
          DBusSignature('a(iiay)'),
          access: DBusPropertyAccess.read,
        ),
        DBusIntrospectProperty(
          'AttentionMovieName',
          DBusSignature('s'),
          access: DBusPropertyAccess.read,
        ),
        DBusIntrospectProperty(
          'ToolTip',
          DBusSignature('(sa(iiay)ss)'),
          access: DBusPropertyAccess.read,
        ),
        DBusIntrospectProperty(
          'ItemIsMenu',
          DBusSignature('b'),
          access: DBusPropertyAccess.read,
        ),
        DBusIntrospectProperty(
          'Menu',
          DBusSignature('o'),
          access: DBusPropertyAccess.read,
        ),
      ],
      signals: [
        DBusIntrospectSignal('NewTitle'),
        DBusIntrospectSignal('NewIcon'),
        DBusIntrospectSignal('NewStatus'),
        DBusIntrospectSignal('NewIconPixmap'),
        DBusIntrospectSignal('NewOverlayIcon'),
        DBusIntrospectSignal('NewAttentionIcon'),
        DBusIntrospectSignal('NewToolTip'),
      ],
    ),
  ];
}
