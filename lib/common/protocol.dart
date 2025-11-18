import 'dart:io';
import 'package:win32_registry/win32_registry.dart';

class Protocol {
  static Protocol? _instance;

  Protocol._internal();

  factory Protocol() {
    _instance ??= Protocol._internal();
    return _instance!;
  }

  bool register(String scheme) {
    try {
      // 检查是否已经注册
      if (isRegistered(scheme)) {
        print('Protocol $scheme is already registered');
        return true;
      }

      String protocolRegKey = 'Software\\Classes\\$scheme';
      
      print('Registering protocol: $scheme');
      print('Executable path: ${Platform.resolvedExecutable}');
      
      // 1. 创建主协议键并设置 URL Protocol 标识
      final protocolKey = Registry.currentUser.createKey(protocolRegKey);
      protocolKey.createValue(RegistryValue.string(
        'URL Protocol', 
        '',  // 空字符串是标准做法
      ));
      
      // 2. 设置协议友好名称（可选）
      protocolKey.createValue(RegistryValue.string(
        '',  // 默认值
        'URL:$scheme Protocol',
      ));
      
      // 3. 创建命令结构
      final shellKey = Registry.currentUser.createKey('$protocolRegKey\\shell');
      final openKey = Registry.currentUser.createKey('$protocolRegKey\\shell\\open');
      final commandKey = Registry.currentUser.createKey('$protocolRegKey\\shell\\open\\command');
      
      // 4. 设置启动命令
      commandKey.createValue(RegistryValue.string(
        '',  // 默认值
        '"${Platform.resolvedExecutable}" "%1"',
      ));
      
      print('✅ Protocol $scheme registered successfully');
      return true;
    } catch (e) {
      print('❌ Error registering protocol $scheme: $e');
      return false;
    }
  }
  
  bool unregister(String scheme) {
    try {
      String protocolRegKey = 'Software\\Classes\\$scheme';
      
      // 使用 try-catch 来检查键是否存在，因为新版本中 openKey 可能已改变
      try {
        final key = Registry.currentUser.openKey(protocolRegKey);
        if (key != null) {
          Registry.currentUser.deleteKey(protocolRegKey, recursive: true);
          print('✅ Protocol $scheme unregistered successfully');
          return true;
        }
      } catch (e) {
        // 如果打开键失败，可能键不存在
      }
      
      print('ℹ️ Protocol $scheme was not registered');
      return true;
    } catch (e) {
      print('❌ Error unregistering protocol $scheme: $e');
      return false;
    }
  }
  
  bool isRegistered(String scheme) {
    try {
      String protocolRegKey = 'Software\\Classes\\$scheme';
      final key = Registry.currentUser.openKey(protocolRegKey);
      if (key == null) return false;
      
      // 检查必要的值是否存在
      final urlProtocolValue = key.getValue('URL Protocol');
      return urlProtocolValue != null;
    } catch (e) {
      return false;
    }
  }
}

final protocol = Protocol();
