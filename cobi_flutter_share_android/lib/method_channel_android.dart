import "package:cobi_flutter_share_platform_interface/cobi_flutter_share_platform_interface.dart";

/// The default method channel implementation of [CobiFlutterSharePlatform]
class CobiFlutterShareAndroid extends CobiFlutterShareMethodChannelImpl {
  
  /// Registers this class as the default instance of [SharedPreferencesStorePlatform].
  static void registerWith() {
    CobiFlutterSharePlatform.instance = CobiFlutterShareMethodChannelImpl();
  }
}
