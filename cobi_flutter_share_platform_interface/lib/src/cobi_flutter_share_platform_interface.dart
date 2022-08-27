import 'package:flutter/foundation.dart';
import "package:plugin_platform_interface/plugin_platform_interface.dart";

import "./method_channel_common_impl.dart";
import "./types.dart";

/// The interface that implementations of cobi_flutter_share must implement.
///
/// Platform implementations should extend this class rather than implement it as `cobi_flutter_share`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [CobiFlutterSharePlatform] methods.
abstract class CobiFlutterSharePlatform extends PlatformInterface {
  /// Constructs a CobiFlutterSharePlatform.
  CobiFlutterSharePlatform() : super(token: _token);

  static final Object _token = Object();

  static CobiFlutterSharePlatform _instance = new CobiFlutterShareMethodChannelImpl();

  /// The default instance of [CobiFlutterSharePlatform] to use,
  /// defaults to [CobiFlutterSharePlatformUnsupported].
  static CobiFlutterSharePlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [CobiFlutterSharePlatform] when they register themselves.
  static set instance(CobiFlutterSharePlatform value) {
    if (!value.isMock) {
      try {
        value._verifyProvidesDefaultImplementations();
      } on NoSuchMethodError catch (_) {
        throw AssertionError('Platform interfaces must not be implemented with `implements`');
      }
    }
    _instance = value;
  }
  
  /// Only mock implementations should set this to true.
  ///
  /// Mockito mocks are implementing this class with `implements` which is forbidden for anything
  /// other than mocks (see class docs). This property provides a backdoor for mockito mocks to
  /// skip the verification that the class isn't implemented with `implements`.
  @visibleForTesting
  bool get isMock => false;
  
  void _verifyProvidesDefaultImplementations() {}
  
  /// This adds multiple share targets.
  /// The returned future resolves to false if at least one of the targets could not be added.
  Future<bool?> addShareTargets(List<ShareTarget> targets);
  /// This removes the share target with given identifier.
  /// If the share target couldn't be removed or did not exist the returned future resolves to false.
  Future<bool?> removeShareTarget(String id);
  
  Future<bool?> removeAllShareTargets();
  
  Stream<ShareData> get onShareReceived;
}
