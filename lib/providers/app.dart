import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app.g.dart';

@riverpod
class RealTunEnable extends _$RealTunEnable {
  @override
  bool build() {
    return globalState.appState.realTunEnable;
  }

  void update(bool value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(realTunEnable: value);
  }
}

@riverpod
class Logs extends _$Logs {
  @override
  FixedList<Log> build() {
    return globalState.appState.logs;
  }

  void addLog(Log value) {
    state = state.copyWith()..add(value);
    globalState.appState = globalState.appState.copyWith(logs: state);
  }

  void update(FixedList<Log> value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(logs: value);
  }
}

@riverpod
class Requests extends _$Requests {
  @override
  FixedList<TrackerInfo> build() {
    return globalState.appState.requests;
  }

  void addRequest(TrackerInfo value) {
    state = state.copyWith()..add(value);
    globalState.appState = globalState.appState.copyWith(requests: state);
  }

  void update(FixedList<TrackerInfo> value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(requests: value);
  }
}

@riverpod
class Providers extends _$Providers {
  @override
  List<ExternalProvider> build() {
    return globalState.appState.providers;
  }

  void setProvider(ExternalProvider? provider) {
    if (provider == null) return;
    final index = state.indexWhere((item) => item.name == provider.name);
    if (index == -1) return;
    final newState = List<ExternalProvider>.from(state)..[index] = provider;
    state = newState;
    globalState.appState = globalState.appState.copyWith(providers: newState);
  }

  void update(List<ExternalProvider> value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(providers: value);
  }
}

@riverpod
class Packages extends _$Packages {
  @override
  List<Package> build() {
    return globalState.appState.packages;
  }

  void update(List<Package> value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(packages: value);
  }
}

@riverpod
class SystemBrightness extends _$SystemBrightness {
  @override
  Brightness build() {
    return globalState.appState.brightness;
  }

  void setState(Brightness value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(brightness: value);
  }
}

@riverpod
class Traffics extends _$Traffics {
  @override
  FixedList<Traffic> build() {
    return globalState.appState.traffics;
  }

  void addTraffic(Traffic value) {
    state = state.copyWith()..add(value);
    globalState.appState = globalState.appState.copyWith(traffics: state);
  }

  void clear() {
    state = state.copyWith()..clear();
    globalState.appState = globalState.appState.copyWith(traffics: state);
  }

  void update(FixedList<Traffic> value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(traffics: value);
  }
}

@riverpod
class TotalTraffic extends _$TotalTraffic {
  @override
  Traffic build() {
    return globalState.appState.totalTraffic;
  }

  void update(Traffic value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(totalTraffic: value);
  }
}

@riverpod
class LocalIp extends _$LocalIp {
  @override
  String? build() {
    return globalState.appState.localIp;
  }

  void update(String? value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(localIp: value);
  }
}

@riverpod
class RunTime extends _$RunTime {
  @override
  int? build() {
    return globalState.appState.runTime;
  }

  void update(int? value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(runTime: value);
  }
}

@riverpod
class ViewSize extends _$ViewSize {
  @override
  Size build() {
    return globalState.appState.viewSize;
  }

  void update(Size value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(viewSize: value);
  }
}

@riverpod
class SideWidth extends _$SideWidth {
  @override
  double build() {
    return globalState.appState.sideWidth;
  }
  
  void update(double value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(sideWidth: value);
  }
}

@riverpod
double viewWidth(Ref ref) {
  return ref.watch(viewSizeProvider).width;
}

@riverpod
ViewMode viewMode(Ref ref) {
  return utils.getViewMode(ref.watch(viewWidthProvider));
}

@riverpod
bool isMobileView(Ref ref) {
  return ref.watch(viewModeProvider) == ViewMode.mobile;
}

@riverpod
double viewHeight(Ref ref) {
  return ref.watch(viewSizeProvider).height;
}

@riverpod
class Init extends _$Init {
  @override
  bool build() {
    return globalState.appState.isInit;
  }

  void update(bool value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(isInit: value);
  }
}

@riverpod
class CurrentPageLabel extends _$CurrentPageLabel {
  @override
  PageLabel build() {
    return globalState.appState.pageLabel;
  }

  void update(PageLabel value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(pageLabel: value);
  }
}

@riverpod
class SortNum extends _$SortNum {
  @override
  int build() {
    return globalState.appState.sortNum;
  }

  int add() {
    state++;
    globalState.appState = globalState.appState.copyWith(sortNum: state);
    return state;
  }

  void update(int value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(sortNum: value);
  }
}

@riverpod
class CheckIpNum extends _$CheckIpNum {
  @override
  int build() {
    return globalState.appState.checkIpNum;
  }

  int add() {
    state++;
    globalState.appState = globalState.appState.copyWith(checkIpNum: state);
    return state;
  }

  void update(int value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(checkIpNum: value);
  }
}

@riverpod
class BackBlock extends _$BackBlock {
  @override
  bool build() {
    return globalState.appState.backBlock;
  }

  void update(bool value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(backBlock: value);
  }
}

@riverpod
class Loading extends _$Loading {
  @override
  bool build() {
    return globalState.appState.loading;
  }

  void update(bool value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(loading: value);
  }
}

@riverpod
class Version extends _$Version {
  @override
  int build() {
    return globalState.appState.version;
  }

  void update(int value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(version: value);
  }
}

@riverpod
class Groups extends _$Groups {
  @override
  List<Group> build() {
    return globalState.appState.groups;
  }

  void update(List<Group> value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(groups: value);
  }
}

@riverpod
class DelayDataSource extends _$DelayDataSource {
  @override
  DelayMap build() {
    return globalState.appState.delayMap;
  }

  void setDelay(Delay delay) {
    if (state[delay.url]?[delay.name] != delay.value) {
      final DelayMap newDelayMap = Map.from(state);
      if (newDelayMap[delay.url] == null) {
        newDelayMap[delay.url] = {};
      }
      newDelayMap[delay.url]![delay.name] = delay.value;
      state = newDelayMap;
      globalState.appState = globalState.appState.copyWith(delayMap: newDelayMap);
    }
  }

  void update(DelayMap value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(delayMap: value);
  }
}

@riverpod
class SystemUiOverlayStyleState extends _$SystemUiOverlayStyleState {
  @override
  SystemUiOverlayStyle build() {
    return globalState.appState.systemUiOverlayStyle;
  }

  void update(SystemUiOverlayStyle value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(
      systemUiOverlayStyle: value,
    );
  }
}

@riverpod
class ProfileOverrideState extends _$ProfileOverrideState {
  @override
  ProfileOverrideModel? build() {
    return globalState.appState.profileOverrideModel;
  }

  void updateState(
    ProfileOverrideModel? Function(ProfileOverrideModel? state) builder,
  ) {
    final value = builder(state);
    if (value == null) {
      return;
    }
    state = value;
    globalState.appState = globalState.appState.copyWith(
      profileOverrideModel: value,
    );
  }

  void update(ProfileOverrideModel? value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(
      profileOverrideModel: value,
    );
  }
}

@riverpod
class CoreStatusProvider extends _$CoreStatusProvider {
  @override
  CoreStatus build() {
    ref.onDispose(() {
      // Clean up if needed
    });
    return globalState.appState.coreStatus;
  }
  
  void update(CoreStatus status) {
    state = status;
    globalState.appState = globalState.appState.copyWith(coreStatus: status);
  }
}

@riverpod
class QueryMap extends _$QueryMap {
  @override
  Map<QueryTag, String> build() => globalState.appState.queryMap;

  void updateQuery(QueryTag tag, String value) {
    final newMap = Map<QueryTag, String>.from(state)..[tag] = value;
    state = newMap;
    globalState.appState = globalState.appState.copyWith(queryMap: newMap);
  }

  void update(Map<QueryTag, String> value) {
    state = value;
    globalState.appState = globalState.appState.copyWith(queryMap: value);
  }
}
