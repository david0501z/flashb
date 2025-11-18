import 'dart:io';

import 'package:win32_registry/win32_registry.dart';

class Protocol {
  static Protocol? _instance;

  Protocol._internal();

  factory Protocol() {
    _instance ??= Protocol._internal();
    return _instance!;
  }

  void register(String scheme) {
    String protocolRegKey = 'Software\\Classes\\$scheme';
    RegistryValue protocolRegValue = RegistryValue(
      name: 'URL Protocol',
      type: RegistryValueType.string,
      data: '',
    );
    String protocolCmdRegKey = 'shell\\open\\command';
    RegistryValue protocolCmdRegValue = RegistryValue(
      name: '',
      type: RegistryValueType.string,
      data: '"${Platform.resolvedExecutable}" "%1"',
    );
    final regKey = Registry.currentUser.createKey(protocolRegKey);
    regKey.createValue(protocolRegValue);
    regKey.createKey(protocolCmdRegKey).createValue(protocolCmdRegValue);
  }
}

final protocol = Protocol();
