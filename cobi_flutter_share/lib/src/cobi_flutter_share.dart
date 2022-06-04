import 'package:cobi_flutter_share_platform_interface/cobi_flutter_share_platform_interface.dart';

/// The main class for receiving shared data
class CobiFlutterShare {
  
  CobiFlutterShare._() {
    
    _platform = CobiFlutterSharePlatform.instance;
  }
  
  static CobiFlutterShare? _instance;
  
  /// This returns a singleton that controls direct share targets and received shared data
  static CobiFlutterShare get instance => _getInstance();
  
  late CobiFlutterSharePlatform _platform;
  
  static CobiFlutterShare _getInstance() {
    if (_instance != null) {
      return _instance!;
    }
    
    _instance = CobiFlutterShare._();
    return _instance!;
  }
  
  /// This method adds a direct share target defined with [DirectShareTarget]
  /// The returned future resolves to false if the target could not be added.
  /// If you want to update an existing share target, re-add it with the same [DirectShareTarget.id].
  Future<bool?> addDirectShareTarget(DirectShareTarget target) {
    return _platform.addDirectShareTarget(target);
  }
  
  /// This removes the direct share target identified by [id]
  /// If anything goes wrong when removing it the returned future resolves to false.
  Future<bool?> removeShareTarget(String id) {
    return _platform.removeDirectShareTarget(id);
  }
  
  /// This [Stream] is a broadcast stream that informs you about incoming shared data
  Stream<ShareData> get onShareReceived => _platform.onShareReceived;
}
