import 'dart:async';

import "package:cobi_flutter_share_platform_interface/cobi_flutter_share_platform_interface.dart";
import 'package:flutter/services.dart';

/// The default method channel implementation of [CobiFlutterSharePlatform]
class CobiFlutterShareMethodChannelImpl extends CobiFlutterSharePlatform {
  
  MethodChannel _methodChannel = MethodChannel("de.cobinja/ShareMethods", JSONMethodCodec());
  EventChannel _eventChannel = EventChannel("de.cobinja/ShareEvents", JSONMethodCodec());
  
  StreamController<ShareData> _streamControllerReceivedData = StreamController.broadcast();
  
  CobiFlutterShareMethodChannelImpl() {
    _eventChannel.receiveBroadcastStream()
    .listen((event) {
      if (event is Map<String, dynamic>) {
        _streamControllerReceivedData.sink.add(ShareData.fromJson(event));
      }
    });
  }
  
  @override
  Future<bool?> addShareTargets(List<ShareTarget> targets) async {
    return _methodChannel.invokeMethod<bool>("addShareTargets", {
      "targets": targets
    });
  }
  
  @override
  Stream<ShareData> get onShareReceived => _streamControllerReceivedData.stream;
  
  @override
  Future<bool?> removeShareTarget(String id) {
    return _methodChannel.invokeMethod("removeShareTarget", id);
  }
  
  @override
  Future<bool?> removeAllShareTargets() {
    return _methodChannel.invokeMethod("removeAllShareTargets");
  }
}
