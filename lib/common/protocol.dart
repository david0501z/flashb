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
    
    // 创建主协议键
    final protocolKey = Registry.currentUser.createKey(protocolRegKey);
    
    // 设置 URL Protocol 值 - 使用 setValue 方法
    protocolKey.setValue(
      'URL Protocol',
      RegistryValueType.string,
      '',
    );
    
    // 可选：设置默认值（协议描述）
    protocolKey.setValue(
      '',  // 默认值名称
      RegistryValueType.string,
      'URL:$scheme Protocol',  // 协议描述
    );
    
    // 创建命令键并设置命令值
    final commandKey = Registry.currentUser.createKey(protocolCmdRegKey);
    commandKey.setValue(
      '',  // 默认值名称
      RegistryValueType.string,
      '"${Platform.resolvedExecutable}" "%1"',
    );
  }
}

final protocol = Protocol();
