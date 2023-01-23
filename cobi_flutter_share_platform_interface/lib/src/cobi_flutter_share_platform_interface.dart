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
  static set instance(CobiFlutterSharePlatform instance) {
    if (!instance.isMock) {
      PlatformInterface.verify(instance, _token);
    }
    _instance = instance;
  }
  
  /// Only mock implementations should set this to true.
  ///
  /// Mockito mocks are implementing this class with `implements` which is forbidden for anything
  /// other than mocks (see class docs). This property provides a backdoor for mockito mocks to
  /// skip the verification that the class isn't implemented with `implements`.
  @visibleForTesting
  @Deprecated('Use MockPlatformInterfaceMixin instead')
  bool get isMock => false;
  
  /// This adds multiple share targets.
  /// The returned future resolves to false if at least one of the targets could not be added.
  Future<bool?> addShareTargets(List<ShareTarget> targets);
  /// This removes the share target with given identifier.
  /// If any of the share targets couldn't be removed the returned future resolves to false.
  Future<bool?> removeShareTargets(List<String> ids);
  
  /// This removes all specific share targets.
  /// If anythign goes wrong, the returned future resolves to false.
  Future<bool?> removeAllShareTargets();
  
  Stream<ShareData> get onShareReceived;
  
  Stream<ShareItemChunk>? fetchContents(String uri, [int? chunkSize]);
  Future<void> pauseFetch(String uri);
  Future<void> continueFetch(String uri);
  Future<void> abortFetch(String uri);
  
  void initialize();
}
