import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

class CoreController {
  static CoreController? _instance;
  late CoreHandlerInterface _interface;

  CoreController._internal() {
    if (system.isAndroid) {
      _interface = coreLib!;
    } else {
      _interface = coreService!;
    }
  }

  factory CoreController() {
    _instance ??= CoreController._internal();
    return _instance!;
  }

  bool get isCompleted => _interface.completer.isCompleted;

  Future<String> preload() {
    return _interface.preload();
  }

  static Future<void> initGeo() async {
    final homePath = await appPath.homeDirPath;
    final homeDir = Directory(homePath);
    final isExists = await homeDir.exists();
    if (!isExists) {
      await homeDir.create(recursive: true);
    }
    const geoFileNameList = [MMDB, GEOIP, GEOSITE, ASN];
    try {
      for (final geoFileName in geoFileNameList) {
        final geoFile = File(join(homePath, geoFileName));
        final isExists = await geoFile.exists();
        if (isExists) {
          continue;
        }
        try {
          final data = await rootBundle.load('assets/data/$geoFileName');
          List<int> bytes = data.buffer.asUint8List();
          await geoFile.writeAsBytes(bytes, flush: true);
        } catch (bundleError) {
          commonPrint.log('Failed to load geo file from assets: $geoFileName, error: $bundleError', logLevel: LogLevel.warning);
        }
      }
    } catch (e) {
      commonPrint.log('Failed to initialize geo files: $e', logLevel: LogLevel.error);
      // 不要退出应用，而是记录错误并继续
    }
  }

  Future<bool> init(int version) async {
    await initGeo();
    final homeDirPath = await appPath.homeDirPath;
    
    // 确保配置目录存在
    final homeDir = Directory(homeDirPath);
    if (!await homeDir.exists()) {
      await homeDir.create(recursive: true);
    }
    
    // 确保配置文件存在，如果不存在则创建默认配置
    final configFile = File(join(homeDirPath, 'config.json'));
    if (!await configFile.exists()) {
      await configFile.writeAsString('{}');
    }
    
    try {
      return await _interface.init(
        InitParams(homeDir: homeDirPath, version: version),
      );
    } catch (e) {
      // 如果初始化失败，可能是由于路径问题，记录错误但不阻止应用启动
      commonPrint.log('Core initialization failed: $e', logLevel: LogLevel.error);
      return false;
    }
  }

  Future<void> shutdown() async {
    await _interface.shutdown();
  }

  FutureOr<bool> get isInit => _interface.isInit;

  Future<String> validateConfig(String data) async {
    final path = await appPath.validateFilePath;
    await globalState.genValidateFile(path, data);
    final res = await _interface.validateConfig(path);
    await File(path).delete();
    return res;
  }

  Future<String> validateConfigFormBytes(Uint8List bytes) async {
    final path = await appPath.validateFilePath;
    await globalState.genValidateFileFormBytes(path, bytes);
    final res = await _interface.validateConfig(path);
    await File(path).delete();
    return res;
  }

  Future<String> updateConfig(UpdateParams updateParams) async {
    return await _interface.updateConfig(updateParams);
  }

  Future<String> setupConfig(
    ClashConfig clashConfig, {
    VoidCallback? preloadInvoke,
  }) async {
    await globalState.genConfigFile(clashConfig);
    final params = await globalState.getSetupParams();
    final res = _interface.setupConfig(params);
    if (preloadInvoke != null) {
      preloadInvoke();
    }
    return res;
  }

  Future<List<Group>> getProxiesGroups({
    required ProxiesSortType sortType,
    required DelayMap delayMap,
    required SelectedMap selectedMap,
    required String defaultTestUrl,
  }) async {
    try {
      final proxies = await _interface.getProxies();
      return Isolate.run<List<Group>>(() {
        if (proxies.isEmpty) {
          commonPrint.log('No proxies available from core', logLevel: LogLevel.warning);
          return [];
        }
        
        // 添加调试日志以便排查问题
        commonPrint.log('Available proxies keys: ${proxies.keys.toList()}');
        
        // 检查 GLOBAL 组是否存在，如果不存在尝试使用第一个可用组
        String primaryGroupName = UsedProxy.GLOBAL.name;
        if (!proxies.containsKey(primaryGroupName)) {
          // 尝试找到第一个有效的代理组
          final availableGroups = proxies.keys.where((key) {
            final group = proxies[key];
            return group != null && 
                   group['all'] != null && 
                   (group['all'] as List).isNotEmpty &&
                   GroupTypeExtension.valueList.contains(group['type']);
          }).toList();
          
          if (availableGroups.isEmpty) {
            commonPrint.log('No valid proxy groups found, available groups: ${proxies.keys.toList()}', logLevel: LogLevel.error);
            return [];
          }
          
          primaryGroupName = availableGroups.first;
          commonPrint.log('Using alternative primary group: $primaryGroupName', logLevel: LogLevel.info);
        }
        
        final globalGroup = proxies[primaryGroupName];
        if (globalGroup == null || globalGroup['all'] == null) {
          commonPrint.log('Primary group $primaryGroupName is null or has no proxies', logLevel: LogLevel.error);
          return [];
        }
        
        final globalAll = globalGroup['all'] as List?;
        if (globalAll == null || globalAll.isEmpty) {
          commonPrint.log('Primary group $primaryGroupName has no proxy items', logLevel: LogLevel.warning);
          // 即使没有子代理，也返回主组本身
          globalAll ??= [];
        }
        
        final groupNames = [
          primaryGroupName,
          ...globalAll.where((e) {
            if (e == null || e == primaryGroupName) return false;
            final proxy = proxies[e] ?? {};
            final isValidType = proxy['type'] == null || 
                               GroupTypeExtension.valueList.contains(proxy['type']);
            if (!isValidType) {
              commonPrint.log('Skipping proxy $e due to invalid type: ${proxy['type']}');
            }
            return isValidType;
          }),
        ];
        
        commonPrint.log('Filtered group names: $groupNames');
        
        final groupsRaw = groupNames.map((groupName) {
          final group = proxies[groupName];
          if (group == null) {
            commonPrint.log('Group $groupName is null, skipping', logLevel: LogLevel.warning);
            return null;
          }
          
          try {
            final allProxies = ((group['all'] ?? []) as List)
                .map((name) {
                  if (name == null) return null;
                  final proxy = proxies[name.toString()];
                  if (proxy == null) {
                    commonPrint.log('Proxy $name not found in group $groupName', logLevel: LogLevel.warning);
                  }
                  return proxy;
                })
                .where((proxy) => proxy != null)
                .cast<Map<String, dynamic>>()
                .toList();
                
            // 创建新的组映射，确保数据完整性
            final processedGroup = Map<String, dynamic>.from(group);
            processedGroup['all'] = allProxies;
            processedGroup['name'] = groupName;
            
            return processedGroup;
          } catch (e) {
            commonPrint.log('Error processing group $groupName: $e', logLevel: LogLevel.error);
            return null;
          }
        }).where((group) => group != null).cast<Map<String, dynamic>>().toList();
        
        if (groupsRaw.isEmpty) {
          commonPrint.log('No valid groups found after processing', logLevel: LogLevel.error);
          return [];
        }
        
        try {
          final groups = groupsRaw.map((e) => Group.fromJson(e)).toList();
          commonPrint.log('Successfully parsed ${groups.length} groups');
          
          return computeSort(
            groups: groups,
            sortType: sortType,
            delayMap: delayMap,
            selectedMap: selectedMap,
            defaultTestUrl: defaultTestUrl,
          );
        } catch (e) {
          commonPrint.log('Error parsing groups: $e', logLevel: LogLevel.error);
          commonPrint.log('Raw groups data: ${groupsRaw.take(2).toList()}', logLevel: LogLevel.debug);
          return [];
        }
      });
    } catch (e) {
      commonPrint.log('Critical error in getProxiesGroups: $e', logLevel: LogLevel.error);
      return [];
    }
  }

  FutureOr<String> changeProxy(ChangeProxyParams changeProxyParams) async {
    return await _interface.changeProxy(changeProxyParams);
  }

  Future<List<TrackerInfo>> getConnections() async {
    final res = await _interface.getConnections();
    final connectionsData = json.decode(res) as Map;
    final connectionsRaw = connectionsData['connections'] as List? ?? [];
    return connectionsRaw.map((e) => TrackerInfo.fromJson(e)).toList();
  }

  void closeConnection(String id) {
    _interface.closeConnection(id);
  }

  void closeConnections() {
    _interface.closeConnections();
  }

  void resetConnections() {
    _interface.resetConnections();
  }

  Future<List<ExternalProvider>> getExternalProviders() async {
    final externalProvidersRawString = await _interface.getExternalProviders();
    if (externalProvidersRawString.isEmpty) {
      return [];
    }
    return Isolate.run<List<ExternalProvider>>(() {
      final externalProviders =
          (json.decode(externalProvidersRawString) as List<dynamic>)
              .map((item) => ExternalProvider.fromJson(item))
              .toList();
      return externalProviders;
    });
  }

  Future<ExternalProvider?> getExternalProvider(
    String externalProviderName,
  ) async {
    final externalProvidersRawString = await _interface.getExternalProvider(
      externalProviderName,
    );
    if (externalProvidersRawString.isEmpty) {
      return null;
    }
    return ExternalProvider.fromJson(json.decode(externalProvidersRawString));
  }

  Future<String> updateGeoData(UpdateGeoDataParams params) {
    return _interface.updateGeoData(params);
  }

  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  }) {
    return _interface.sideLoadExternalProvider(
      providerName: providerName,
      data: data,
    );
  }

  Future<String> updateExternalProvider({required String providerName}) async {
    return _interface.updateExternalProvider(providerName);
  }

  Future<bool> startListener() async {
    return await _interface.startListener();
  }

  Future<bool> stopListener() async {
    return await _interface.stopListener();
  }

  Future<Delay> getDelay(String url, String proxyName) async {
    final data = await _interface.asyncTestDelay(url, proxyName);
    return Delay.fromJson(json.decode(data));
  }

  Future<Map<String, dynamic>> getConfig(String id) async {
    final profilePath = await appPath.getProfilePath(id);
    final res = await _interface.getConfig(profilePath);
    if (res.isSuccess) {
      return res.data;
    } else {
      throw res.message;
    }
  }

  Future<Traffic> getTraffic(bool onlyStatisticsProxy) async {
    final trafficString = await _interface.getTraffic(onlyStatisticsProxy);
    if (trafficString.isEmpty) {
      return Traffic();
    }
    return Traffic.fromJson(json.decode(trafficString));
  }

  Future<IpInfo?> getCountryCode(String ip) async {
    final countryCode = await _interface.getCountryCode(ip);
    if (countryCode.isEmpty) {
      return null;
    }
    return IpInfo(ip: ip, countryCode: countryCode);
  }

  Future<Traffic> getTotalTraffic(bool onlyStatisticsProxy) async {
    final totalTrafficString = await _interface.getTotalTraffic(
      onlyStatisticsProxy,
    );
    if (totalTrafficString.isEmpty) {
      return Traffic();
    }
    return Traffic.fromJson(json.decode(totalTrafficString));
  }

  Future<int> getMemory() async {
    final value = await _interface.getMemory();
    if (value.isEmpty) {
      return 0;
    }
    return int.parse(value);
  }

  void resetTraffic() {
    _interface.resetTraffic();
  }

  void startLog() {
    _interface.startLog();
  }

  void stopLog() {
    _interface.stopLog();
  }

  Future<void> requestGc() async {
    await _interface.forceGc();
  }

  Future<void> destroy() async {
    await _interface.destroy();
  }

  Future<void> crash() async {
    await _interface.crash();
  }

  Future<String> deleteFile(String path) async {
    return await _interface.deleteFile(path);
  }
}

final coreController = CoreController();
