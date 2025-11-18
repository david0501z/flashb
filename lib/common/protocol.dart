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
    String protocolCmdRegKey = '$protocolRegKey\\shell\\open\\command';
    
    // 创建主协议键并设置值
    final protocolKey = Registry.currentUser.createKey(protocolRegKey);
    protocolKey.createValue(RegistryStringValue(
      protocolKey.path,
      'URL Protocol',
      '',
    ));
    
    // 创建命令键并设置值
    final commandKey = Registry.currentUser.createKey(protocolCmdRegKey);
    commandKey.createValue(RegistryStringValue(
      commandKey.path,
      '',  // 默认值名称
      '"${Platform.resolvedExecutable}" "%1"',
    ));
  }
}

final protocol = Protocol();
