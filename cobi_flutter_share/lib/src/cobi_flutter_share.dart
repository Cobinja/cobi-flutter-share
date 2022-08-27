import 'package:cobi_flutter_share_platform_interface/cobi_flutter_share_platform_interface.dart';

/// The main class for receiving shared data
class CobiFlutterShare {
  
  CobiFlutterShare._() {
    
    _platform = CobiFlutterSharePlatform.instance;
  }
  
  static CobiFlutterShare? _instance;
  
  /// This returns a singleton that controls share targets and received shared data
  static CobiFlutterShare get instance => _getInstance();
  
  late CobiFlutterSharePlatform _platform;
  
  static CobiFlutterShare _getInstance() {
    if (_instance != null) {
      return _instance!;
    }
    
    _instance = CobiFlutterShare._();
    return _instance!;
  }
  
  /// This method adds a share target defined with [ShareTarget]
  /// The returned future resolves to false if the target could not be added.
  /// If you want to update an existing share target, re-add it with the same [ShareTarget.id].
  Future<bool?> addShareTarget(ShareTarget target) {
    return addShareTargets([target]);
  }
  
  /// This adds multiple share targets in one go.
  /// The returned future resolves to false if the target could not be added.
  /// If you want to update an existing share target, re-add it with the same [ShareTarget.id].
  Future<bool?> addShareTargets(List<ShareTarget> targets) {
    return _platform.addShareTargets(targets);
  }
  
  /// This removes the share target identified by [id].
  /// If anything goes wrong when removing it the returned future resolves to false.
  Future<bool?> removeShareTarget(String id) {
    return _platform.removeShareTarget(id);
  }
  
  /// This removes all share targets.
  /// It does not remove the general share target for the app.
  /// If anything goes wrong when removing them the returned future resolves to false.
  Future<bool?> removeAllShareTargets() {
    return _platform.removeAllShareTargets();
  }
  
  /// This [Stream] is a broadcast stream that informs you about incoming shared data.
  Stream<ShareData> get onShareReceived => _platform.onShareReceived;
}
