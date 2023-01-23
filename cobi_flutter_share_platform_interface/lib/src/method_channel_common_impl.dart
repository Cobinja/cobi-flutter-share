import 'dart:async';

import "package:cobi_flutter_share_platform_interface/cobi_flutter_share_platform_interface.dart";
import 'package:flutter/services.dart';

/// The default method channel implementation of [CobiFlutterSharePlatform]
class CobiFlutterShareMethodChannelImpl extends CobiFlutterSharePlatform {
  
  MethodChannel _methodChannel = MethodChannel("de.cobinja/ShareMethods", JSONMethodCodec());
  EventChannel _eventChannel = EventChannel("de.cobinja/ShareEvents");
  
  StreamController<ShareData> _streamControllerReceivedData = StreamController.broadcast();
  
  Map<String, StreamController<ShareItemChunk>> _fileContentStreamControllers = {};
  
  CobiFlutterShareMethodChannelImpl();
  
  void initialize() {
    _eventChannel.receiveBroadcastStream()
    .listen((event) async {
      if (event is Map) {
        Map<String, dynamic> ev = Map<String, dynamic>.from(event);
        if (ev.containsKey("eventType")) {
          if (ev["eventType"] == "receivedShare") {
            _streamControllerReceivedData.sink.add(ShareData.fromJson(ev));
          }
          else if (ev["eventType"] == "fileContents") {
            String uri = ev["uri"];
            if (!_fileContentStreamControllers.containsKey(uri)) {
              return;
            }
            List<int> intList = ev["chunk"].cast<int>().toList();
            Uint8List chunkData = Uint8List.fromList(intList);
            ev["chunk"] = chunkData;
            ShareItemChunk chunk = ShareItemChunk.fromJson(ev);
            _fileContentStreamControllers[uri]!.sink.add(chunk);
            if (ev.containsKey("done") && ev["done"] == "true") {
              _fileContentStreamControllers[uri]!.close();
              _fileContentStreamControllers.remove(uri);
            }
            else {
              _methodChannel.invokeMethod("continueFetch", {"uri": uri});
            }
          }
        }
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
  Future<bool?> removeShareTargets(List<String> ids) {
    return _methodChannel.invokeMethod("removeShareTargets", ids);
  }
  
  @override
  Future<bool?> removeAllShareTargets() {
    return _methodChannel.invokeMethod("removeAllShareTargets");
  }
  
  Stream<ShareItemChunk>? fetchContents(String uri, [int? chunkSize]) {
    if (_fileContentStreamControllers.containsKey(uri)) {
      return null;
    }
    
    StreamController<ShareItemChunk> ctrl = StreamController(
      onListen: () {
        Map<String, dynamic> args = {
          "uri": uri,
          "chunkSize": chunkSize ?? 10 * 1024 * 1024,
        };
        _methodChannel.invokeMethod("fetchContents", args);
      },
      onCancel: () {
        _fileContentStreamControllers[uri]?.sink.close();
        _fileContentStreamControllers.remove(uri);
      },
    );
    _fileContentStreamControllers[uri] = ctrl;
    
    return ctrl.stream;
  }
  
  @override
  Future<void> pauseFetch(String uri) {
    return _methodChannel.invokeMethod("pauseFetch", {"uri": uri});
  }
  
  @override
  Future<void> continueFetch(String uri) {
    return _methodChannel.invokeMethod("continueFetch", {"uri": uri});
  }
  
  @override
  Future<void> abortFetch(String uri) {
    return _methodChannel.invokeMethod("abortFetch", {"uri": uri});
  }
}
